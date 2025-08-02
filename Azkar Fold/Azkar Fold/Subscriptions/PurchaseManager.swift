//
//  PurchaseManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 19/07/2025.
//

import StoreKit
import Foundation

@MainActor
final class PurchaseManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var error: Error? = nil
    @Published var isProcessingPurchase = false
    @Published var showPayWall = false

    
    // MARK: - Product IDs (Must match App Store Connect)
    private let productIDs: Set<String> = [
        "com.Tahhan.azkarfold.monthly",
        "com.Tahhan.azkarfold.annually"
    ]
    
    // MARK: - Helper Properties
    
    /// Check if user has any active subscription
    var hasPremiumAccess: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    /// Get the premium status for SwiftUI views
    @Published var isPremium: Bool = UserDefaults.standard.bool(forKey: "isPremium")

    
    // MARK: - Initialization
    private var updates: Task<Void, Never>? = nil
    
    init() {
        // Start transaction listener on initialization
        updates = listenForTransactions()
        
        // Load initial entitlements
        Task {
            await updateEntitlements()
            await loadProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price } // Sort by price
            print("✅ Successfully loaded products: \(products)")

            print("✅ Successfully loaded products: \(products.map { $0.displayName })")
        } catch {
            self.error = error
            print("❌ Failed to load products: \(error.localizedDescription)")
        }
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async throws {
        isProcessingPurchase = true
        defer { isProcessingPurchase = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await handlePurchased(transaction: transaction)
            }
        case .userCancelled:
            print("🚫 Purchase cancelled by user")
            throw PurchaseError.purchaseCancelled
        case .pending:
            print("⏳ Purchase pending (requires parental approval)")
            throw PurchaseError.pendingApproval
        @unknown default:
            print("⚠️ Unknown purchase result")
            throw PurchaseError.unknown
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        await updateEntitlements()
        
        if purchasedProductIDs.isEmpty {
            throw PurchaseError.noPurchasesToRestore
        }
    }
    
    // MARK: - Private Methods
    
    /// Continuously listen for transaction updates
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await verification in Transaction.updates {
                guard let self = self else { continue }
                
                do {
                    if case .verified(let transaction) = verification {
                        await self.handlePurchased(transaction: transaction)
                    }
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }
    
    /// Handle successful purchase
    private func handlePurchased(transaction: Transaction) async {
        guard !transaction.isUpgraded else { return }
        
        // Add to purchased products
        purchasedProductIDs.insert(transaction.productID)
        
        // Update user defaults
        UserDefaults.standard.set(true, forKey: "isPremium")
        
        // Finish transaction
        await transaction.finish()
        
        print("🎉 Purchase verified: \(transaction.productID)")
    }
    
    /// Check current entitlements
    func updateEntitlements() async {
        var purchasedIDs = Set<String>()
        
        // Check all current transactions
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            } else {
                purchasedIDs.remove(transaction.productID)
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
        UserDefaults.standard.set(!purchasedIDs.isEmpty, forKey: "isPremium")
        
        print("🔄 Updated entitlements: \(purchasedIDs)")
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
