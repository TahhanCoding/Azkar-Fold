import Foundation
import UIKit
import Combine

class SunnahProgressStore: ObservableObject {
    @Published var morningAzkarCompleted: [String: Bool] = [:]
    @Published var eveningAzkarCompleted: [String: Bool] = [:]
    @Published var morningAzkarProgress: [String: Int] = [:]
    @Published var eveningAzkarProgress: [String: Int] = [:]
    @Published var selectedSunnahCategories: Set<SunnahAzkarCategory> = Set(SunnahAzkarCategory.allCases)
    @Published var lastResetDate: Date? = nil
    
    private let morningAzkarCompletedKey = "morningAzkarCompletedKey"
    private let eveningAzkarCompletedKey = "eveningAzkarCompletedKey"
    private let morningAzkarProgressKey = "morningAzkarProgressKey"
    private let eveningAzkarProgressKey = "eveningAzkarProgressKey"
    private let lastResetDateKey = "lastResetDateKey"
    private let selectedCategoriesKey = "selectedSunnahCategories"
    
    init() {
        loadSelectedCategories()
        loadProgress()
        resetDailyProgressIfNeeded()
        // Listen for app becoming active to re-check daily reset
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        switch category {
        case .morning:
            morningAzkarCompleted[zekrId] = true
            morningAzkarProgress[zekrId] = zekr.repeat // Set to max when completed
        case .evening:
            eveningAzkarCompleted[zekrId] = true
            eveningAzkarProgress[zekrId] = zekr.repeat // Set to max when completed
        }
        saveProgress()
    }
    
    func isCompleted(zekr: SunnahZekrItem, category: SunnahAzkarCategory) -> Bool {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        
        switch category {
        case .morning:
            return morningAzkarCompleted[zekrId] ?? false
        case .evening:
            return eveningAzkarCompleted[zekrId] ?? false
        }
    }
    
    func savePartialProgress(zekr: SunnahZekrItem, category: SunnahAzkarCategory, currentRepetition: Int) {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        
        switch category {
        case .morning:
            morningAzkarProgress[zekrId] = currentRepetition
        case .evening:
            eveningAzkarProgress[zekrId] = currentRepetition
        }
        saveProgress()
    }
    
    func getPartialProgress(zekr: SunnahZekrItem, category: SunnahAzkarCategory) -> Int {
        let zekrId = "\(category.rawValue)_\(zekr.zekr)"
        
        switch category {
        case .morning:
            return morningAzkarProgress[zekrId] ?? 0
        case .evening:
            return eveningAzkarProgress[zekrId] ?? 0
        }
    }
    
    
    func getCompletionPercentage(for category: SunnahAzkarCategory, azkarList: [SunnahZekrItem]) -> Double {
        guard !azkarList.isEmpty else { return 0.0 }
        
        let completedCount = azkarList.filter { zekr in
            isCompleted(zekr: zekr, category: category)
        }.count
        
        return Double(completedCount) / Double(azkarList.count)
    }
    
    // MARK: - Daily Progress Reset
    @objc func appDidBecomeActive() {
        resetDailyProgressIfNeeded()
    }
    
    func hardReset() {
        morningAzkarCompleted.removeAll()
        eveningAzkarCompleted.removeAll()
        morningAzkarProgress.removeAll()
        eveningAzkarProgress.removeAll()
        self.lastResetDate = Date()
        saveProgress()
        print("Daily Sunnah Azkar progress has been reset.")
    }
    
    // Add this to your SunnahProgressStore class
    func isCategoryFullyCompleted(category: SunnahAzkarCategory, totalAzkarCount: Int) -> Bool {
        guard totalAzkarCount > 0 else { return false }
        
        let completedCount: Int
        switch category {
        case .morning:
            completedCount = morningAzkarCompleted.values.filter { $0 }.count
        case .evening:
            completedCount = eveningAzkarCompleted.values.filter { $0 }.count
        }
        
        return completedCount == totalAzkarCount
    }
    
    func resetDailyProgressIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        if let lastReset = lastResetDate {
            if !calendar.isDateInToday(lastReset) {
                morningAzkarCompleted.removeAll()
                eveningAzkarCompleted.removeAll()
                morningAzkarProgress.removeAll()
                eveningAzkarProgress.removeAll()
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
    
    // MARK: - Persistence
    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(morningAzkarCompleted, forKey: morningAzkarCompletedKey)
        defaults.set(eveningAzkarCompleted, forKey: eveningAzkarCompletedKey)
        defaults.set(morningAzkarProgress, forKey: morningAzkarProgressKey)
        defaults.set(eveningAzkarProgress, forKey: eveningAzkarProgressKey)
        defaults.set(lastResetDate, forKey: lastResetDateKey)
        objectWillChange.send()
    }
    
    private func loadProgress() {
        let defaults = UserDefaults.standard
        if let morningSaved = defaults.dictionary(forKey: morningAzkarCompletedKey) as? [String: Bool] {
            morningAzkarCompleted = morningSaved
        }
        if let eveningSaved = defaults.dictionary(forKey: eveningAzkarCompletedKey) as? [String: Bool] {
            eveningAzkarCompleted = eveningSaved
        }
        if let morningProgressSaved = defaults.dictionary(forKey: morningAzkarProgressKey) as? [String: Int] {
            morningAzkarProgress = morningProgressSaved
        }
        if let eveningProgressSaved = defaults.dictionary(forKey: eveningAzkarProgressKey) as? [String: Int] {
            eveningAzkarProgress = eveningProgressSaved
        }
        if let dateSaved = defaults.object(forKey: lastResetDateKey) as? Date {
            lastResetDate = dateSaved
        }
    }
    
}
