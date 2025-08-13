//
//  PurchaseManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 19/07/2025.
//

import StoreKit
import Foundation


final class PurchaseManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var error: Error? = nil
    @Published var isProcessingPurchase = false
    @Published var showPayWall = false
    @Published private(set) var isOffline = false
    
    // MARK: - Product IDs
    private let productIDs: Set<String> = [
        "com.Tahhan.azkarfold.monthly",
        "com.Tahhan.azkarfold.annually"
    ]
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let isPremium = "isPremium"
        static let lastEntitlementCheck = "lastEntitlementCheck"
        static let purchasedProductIDs = "purchasedProductIDs"
        static let subscriptionExpiryDate = "subscriptionExpiryDate"
    }
    
    // MARK: - Helper Properties
    var hasPremiumAccess: Bool {
        return isPremium
    }
    
    /// Main premium status - combines online verification with offline fallback
    var isPremium: Bool {
        // If we have current online data, use it
        if !purchasedProductIDs.isEmpty {
            return true
        }
        
        // Offline fallback logic
        return hasValidOfflinePremiumStatus()
    }
    
    // MARK: - Initialization
    private var updates: Task<Void, Never>? = nil
    
    init() {
        // Load cached state immediately
        loadCachedEntitlements()
        
        // Start transaction listener
        updates = listenForTransactions()
        
        // Attempt to load products and update entitlements
        Task {
            await checkConnectivityAndUpdate()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Public Methods
    
    func loadProducts() async {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        do {
            let loadedProducts = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
            
            await MainActor.run {
                products = loadedProducts
                isOffline = false
            }
            
            print("✅ Successfully loaded products")
        } catch {
            await MainActor.run {
                self.error = error
                isOffline = true
            }
            print("❌ Failed to load products (likely offline): \(error.localizedDescription)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        await MainActor.run { isProcessingPurchase = true }
        defer { Task { @MainActor in isProcessingPurchase = false } }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await handlePurchased(transaction: transaction)
            }
        case .userCancelled:
            throw PurchaseError.purchaseCancelled
        case .pending:
            throw PurchaseError.pendingApproval
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    func restorePurchases() async throws {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        do {
            try await AppStore.sync()
            try await updateEntitlements()
            
            if purchasedProductIDs.isEmpty && !hasValidOfflinePremiumStatus() {
                throw PurchaseError.noPurchasesToRestore
            }
        } catch {
            // If restore fails due to network, check offline cache
            if hasValidOfflinePremiumStatus() {
                print("🔄 Using cached premium status during offline restore")
                return // Don't throw error if we have valid offline data
            }
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func checkConnectivityAndUpdate() async {
        do {
            try await updateEntitlements()
            await loadProducts()
        } catch {
            await MainActor.run {
                isOffline = true
            }
            print("🔄 App started offline, using cached entitlements")
        }
    }
    
    private func loadCachedEntitlements() {
        // Load previously cached purchased product IDs
        if let cachedIDs = UserDefaults.standard.array(forKey: UserDefaultsKeys.purchasedProductIDs) as? [String] {
            purchasedProductIDs = Set(cachedIDs)
            print("🔄 Loaded cached entitlements: \(cachedIDs)")
        }
    }
    
    private func hasValidOfflinePremiumStatus() -> Bool {
        // Check basic premium flag
        let hasPremiumFlag = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isPremium)
        
        // Check if we have a recent successful entitlement check
        let lastCheck = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastEntitlementCheck) as? Date
        let daysSinceLastCheck = lastCheck?.timeIntervalSinceNow ?? -TimeInterval.infinity
        let isRecentCheck = daysSinceLastCheck > -7 * 24 * 60 * 60 // Within last 7 days
        
        // Check subscription expiry if available
        if let expiryDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.subscriptionExpiryDate) as? Date {
            let isNotExpired = expiryDate > Date()
            return hasPremiumFlag && isNotExpired
        }
        
        // Fallback: use premium flag with recent check requirement
        return hasPremiumFlag && isRecentCheck
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await verification in Transaction.updates {
                guard let self = self else { continue }
                
                if case .verified(let transaction) = verification {
                    await self.handlePurchased(transaction: transaction)
                }
            }
        }
    }
    
    private func handlePurchased(transaction: Transaction) async {
        guard !transaction.isUpgraded else { return }
        
        await MainActor.run {
            purchasedProductIDs.insert(transaction.productID)
            isOffline = false
        }
        
        // Cache the purchase data
        cachePurchaseData(transaction: transaction)
        
        await transaction.finish()
        print("🎉 Purchase verified: \(transaction.productID)")
    }
    
    func updateEntitlements() async throws {
        var purchasedIDs = Set<String>()
        var latestExpiryDate: Date?
        
        do {
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else { continue }
                
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                    
                    // Track subscription expiry date if available
                    if let expiryDate = transaction.expirationDate {
                        if latestExpiryDate == nil || expiryDate > latestExpiryDate! {
                            latestExpiryDate = expiryDate
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.purchasedProductIDs = purchasedIDs
                isOffline = false
            }
            
            // Cache the entitlements data
            cacheEntitlements(purchasedIDs: purchasedIDs, expiryDate: latestExpiryDate)
            
            print("🔄 Updated entitlements: \(purchasedIDs)")
            
        } catch {
            await MainActor.run {
                isOffline = true
            }
            print("❌ Failed to update entitlements (offline): \(error)")
            throw error
        }
    }
    
    private func cachePurchaseData(transaction: Transaction) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isPremium)
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastEntitlementCheck)
        
        if let expiryDate = transaction.expirationDate {
            UserDefaults.standard.set(expiryDate, forKey: UserDefaultsKeys.subscriptionExpiryDate)
        }
        
        // Cache purchased product IDs
        let currentIDs = Array(purchasedProductIDs)
        UserDefaults.standard.set(currentIDs, forKey: UserDefaultsKeys.purchasedProductIDs)
    }
    
    private func cacheEntitlements(purchasedIDs: Set<String>, expiryDate: Date?) {
        UserDefaults.standard.set(!purchasedIDs.isEmpty, forKey: UserDefaultsKeys.isPremium)
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastEntitlementCheck)
        UserDefaults.standard.set(Array(purchasedIDs), forKey: UserDefaultsKeys.purchasedProductIDs)
        
        if let expiryDate = expiryDate {
            UserDefaults.standard.set(expiryDate, forKey: UserDefaultsKeys.subscriptionExpiryDate)
        }
    }
    
    // MARK: - Debug Methods
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isPremium)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastEntitlementCheck)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.purchasedProductIDs)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.subscriptionExpiryDate)
        
        purchasedProductIDs.removeAll()
        print("🗑️ Cleared all cached purchase data")
    }
}

// MARK: - Error Handling
extension PurchaseManager {
    enum PurchaseError: LocalizedError {
        case purchaseCancelled
        case pendingApproval
        case noPurchasesToRestore
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .purchaseCancelled:
                return "Purchase was cancelled"
            case .pendingApproval:
                return "Purchase pending approval"
            case .noPurchasesToRestore:
                return "No previous purchases found"
            case .unknown:
                return "Unknown error occurred"
            }
        }
    }
}

// MARK: - Product Extension
extension Product {
    /// Simplified price formatting
    var displayPrice: String {
        priceFormatStyle.format(price)
    }
    
    /// Short duration description
    var durationDescription: String {
        guard let subscription = subscription else { return "One-time purchase" }
        
        let unit: String
        switch subscription.subscriptionPeriod.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "period"
        }
        
        return "\(subscription.subscriptionPeriod.value) \(unit)"
    }
}
