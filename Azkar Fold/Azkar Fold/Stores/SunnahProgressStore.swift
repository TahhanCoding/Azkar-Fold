import Foundation
import UIKit
import Combine

class SunnahProgressStore: ObservableObject {
    @Published var morningAzkarCompleted: [String: Bool] = [:]
    @Published var eveningAzkarCompleted: [String: Bool] = [:]
    @Published var selectedSunnahCategories: Set<SunnahAzkarCategory> = Set(SunnahAzkarCategory.allCases)
    @Published var lastResetDate: Date? = nil

    private let morningAzkarCompletedKey = "morningAzkarCompletedKey"
    private let eveningAzkarCompletedKey = "eveningAzkarCompletedKey"
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
        let zekrId = zekr.zekr // Using zekr text as ID
        switch category {
        case .morning:
            morningAzkarCompleted[zekrId] = true
        case .evening:
            eveningAzkarCompleted[zekrId] = true
        }
        saveProgress()
    }

    func isCompleted(zekr: SunnahZekrItem, category: SunnahAzkarCategory) -> Bool {
        let zekrId = zekr.zekr
        switch category {
        case .morning:
            return morningAzkarCompleted[zekrId] ?? false
        case .evening:
            return eveningAzkarCompleted[zekrId] ?? false
        }
    }

    func getCompletionPercentage(for category: SunnahAzkarCategory, totalAzkar: Int) -> Double {
        guard totalAzkar > 0 else { return 0.0 }
        let completedCount: Int
        switch category {
        case .morning:
            completedCount = morningAzkarCompleted.values.filter { $0 }.count
        case .evening:
            completedCount = eveningAzkarCompleted.values.filter { $0 }.count
        }
        return Double(completedCount) / Double(totalAzkar)
    }

    // MARK: - Daily Progress Reset
    @objc func appDidBecomeActive() {
        resetDailyProgressIfNeeded()
    }
    
    func resetDailyProgressIfNeeded() {
        let calendar = Calendar.current
        let now = Date()

        if let lastReset = lastResetDate {
            if !calendar.isDateInToday(lastReset) {
                // Reset progress if the last reset was not today
                morningAzkarCompleted.removeAll()
                eveningAzkarCompleted.removeAll()
                self.lastResetDate = now
                saveProgress() // Save the reset state and new date
                print("Daily Sunnah Azkar progress has been reset.")
            }
        } else {
            // First time launch or no reset date found, set it to now
            self.lastResetDate = now
            saveProgress() // Save the initial date
            print("Initialized Sunnah Azkar progress for the first time.")
        }
    }

    // MARK: - Persistence
    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(morningAzkarCompleted, forKey: morningAzkarCompletedKey)
        defaults.set(eveningAzkarCompleted, forKey: eveningAzkarCompletedKey)
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
        if let dateSaved = defaults.object(forKey: lastResetDateKey) as? Date {
            lastResetDate = dateSaved
        }
    }
}
