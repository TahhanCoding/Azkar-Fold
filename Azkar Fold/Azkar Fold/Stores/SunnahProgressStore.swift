import Foundation
import UIKit
import Combine

class SunnahProgressStore: ObservableObject {
    @Published var azkarCompleted: [SunnahAzkarCategory: [String: Bool]] = [:]
    @Published var azkarProgress: [SunnahAzkarCategory: [String: Int]] = [:]
    @Published var selectedSunnahCategories: Set<SunnahAzkarCategory> = Set(SunnahAzkarCategory.allCases)
    @Published var lastResetDate: Date? = nil
    
    private let azkarCompletedKeyPrefix = "azkarCompleted_"
    private let azkarProgressKeyPrefix = "azkarProgress_"
    private let lastResetDateKey = "lastResetDateKey"
    private let selectedCategoriesKey = "selectedSunnahCategories"
    
    init() {
        initializeCategories()
        loadSelectedCategories()
        loadProgress()
        resetDailyProgressIfNeeded()
        // Listen for app becoming active to re-check daily reset
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Initialize Categories
    private func initializeCategories() {
        for category in SunnahAzkarCategory.allCases {
            if azkarCompleted[category] == nil {
                azkarCompleted[category] = [:]
            }
            if azkarProgress[category] == nil {
                azkarProgress[category] = [:]
            }
        }
    }
    
    // MARK: - Selected Categories Management
    func saveSelectedCategories() {
        let rawValues = selectedSunnahCategories.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: selectedCategoriesKey)
        objectWillChange.send() // Notify views of change
    }
    
    func loadSelectedCategories() {
        if let rawValues = UserDefaults.standard.array(forKey: selectedCategoriesKey) as? [String] {
            selectedSunnahCategories = Set(rawValues.compactMap { SunnahAzkarCategory(rawValue: $0) })
        } else {
            // Default to all categories if nothing is saved
            selectedSunnahCategories = Set(SunnahAzkarCategory.allCases)
        }
    }
    
    func toggleCategorySelection(_ category: SunnahAzkarCategory) {
        if selectedSunnahCategories.contains(category) {
            selectedSunnahCategories.remove(category)
        } else {
            selectedSunnahCategories.insert(category)
        }
        // Note: We will call saveSelectedCategories() explicitly when 'Save' is tapped in the UI
        objectWillChange.send() // Notify views of change
    }
    
    // MARK: - Azkar Completion Progress
    func markAsCompleted(zekr: SunnahZekrItem, category: SunnahAzkarCategory) {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        
        azkarCompleted[category]?[zekrId] = true
        azkarProgress[category]?[zekrId] = zekr.repeat // Set to max when completed
        saveProgress()
    }
    
    func isCompleted(zekr: SunnahZekrItem, category: SunnahAzkarCategory) -> Bool {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        return azkarCompleted[category]?[zekrId] ?? false
    }
    
    func savePartialProgress(zekr: SunnahZekrItem, category: SunnahAzkarCategory, currentRepetition: Int) {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        azkarProgress[category]?[zekrId] = currentRepetition
        saveProgress()
    }
    
    func getPartialProgress(zekr: SunnahZekrItem, category: SunnahAzkarCategory) -> Int {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        return azkarProgress[category]?[zekrId] ?? 0
    }
    
    func getCompletionPercentage(for category: SunnahAzkarCategory, azkarList: [SunnahZekrItem]) -> Double {
        guard !azkarList.isEmpty else { return 0.0 }
        
        let completedCount = azkarList.filter { zekr in
            isCompleted(zekr: zekr, category: category)
        }.count
        
        return Double(completedCount) / Double(azkarList.count)
    }
    
    func isCategoryFullyCompleted(category: SunnahAzkarCategory, totalAzkarCount: Int) -> Bool {
        guard totalAzkarCount > 0 else { return false }
        
        let completedCount = azkarCompleted[category]?.values.filter { $0 }.count ?? 0
        return completedCount == totalAzkarCount
    }
    
    // MARK: - Daily Progress Reset
    @objc func appDidBecomeActive() {
        resetDailyProgressIfNeeded()
    }
    
    func hardReset() {
        for category in SunnahAzkarCategory.allCases {
            azkarCompleted[category]?.removeAll()
            azkarProgress[category]?.removeAll()
        }
        self.lastResetDate = Date()
        saveProgress()
        print("Daily Sunnah Azkar progress has been reset.")
    }
    
    func resetDailyProgressIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        if let lastReset = lastResetDate {
            if !calendar.isDateInToday(lastReset) {
                for category in SunnahAzkarCategory.allCases {
                    azkarCompleted[category]?.removeAll()
                    azkarProgress[category]?.removeAll()
                }
                self.lastResetDate = now
                saveProgress()
                print("Daily Sunnah Azkar progress has been reset.")
            }
        } else {
            self.lastResetDate = now
            saveProgress()
            print("Initialized Sunnah Azkar progress for the first time.")
        }
    }
    
    // MARK: - Category-specific Helper Methods
    func getCategoryCompletedCount(category: SunnahAzkarCategory) -> Int {
        return azkarCompleted[category]?.values.filter { $0 }.count ?? 0
    }
    
    func getCategoryProgressCount(category: SunnahAzkarCategory) -> Int {
        return azkarProgress[category]?.values.reduce(0, +) ?? 0
    }
    
    func resetCategoryProgress(category: SunnahAzkarCategory) {
        azkarCompleted[category]?.removeAll()
        azkarProgress[category]?.removeAll()
        saveProgress()
        print("\(category.title) progress has been reset.")
    }
    
    // MARK: - Persistence
    private func saveProgress() {
        let defaults = UserDefaults.standard
        
        // Save completion status for each category
        for category in SunnahAzkarCategory.allCases {
            let completedKey = azkarCompletedKeyPrefix + category.rawValue
            let progressKey = azkarProgressKeyPrefix + category.rawValue
            
            defaults.set(azkarCompleted[category], forKey: completedKey)
            defaults.set(azkarProgress[category], forKey: progressKey)
        }
        
        defaults.set(lastResetDate, forKey: lastResetDateKey)
        objectWillChange.send()
    }
    
    private func loadProgress() {
        let defaults = UserDefaults.standard
        
        // Load completion status for each category
        for category in SunnahAzkarCategory.allCases {
            let completedKey = azkarCompletedKeyPrefix + category.rawValue
            let progressKey = azkarProgressKeyPrefix + category.rawValue
            
            if let completedSaved = defaults.dictionary(forKey: completedKey) as? [String: Bool] {
                azkarCompleted[category] = completedSaved
            }
            
            if let progressSaved = defaults.dictionary(forKey: progressKey) as? [String: Int] {
                azkarProgress[category] = progressSaved
            }
        }
        
        if let dateSaved = defaults.object(forKey: lastResetDateKey) as? Date {
            lastResetDate = dateSaved
        }
    }
}
