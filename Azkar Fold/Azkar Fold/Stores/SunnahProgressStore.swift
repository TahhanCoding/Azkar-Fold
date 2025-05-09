import Foundation
import Combine

class SunnahProgressStore: ObservableObject {
    @Published var morningAzkarCompleted: [String: Bool] = [:]
    @Published var eveningAzkarCompleted: [String: Bool] = [:]
    @Published var lastResetDate: Date? = nil

    private let morningAzkarCompletedKey = "morningAzkarCompletedKey"
    private let eveningAzkarCompletedKey = "eveningAzkarCompletedKey"
    private let lastResetDateKey = "lastResetDateKey"

    init() {
        loadProgress()
        resetDailyProgressIfNeeded()
    }

    func markAsCompleted(zekr: SunnahZekrItem, category: SunnahAzkarCategory) {
        let zekrId = zekr.zekr // Using zekr text as ID, ensure it's unique enough or use zekr.id.uuidString if available and stable
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
        let completedCount:
        Int
        switch category {
        case .morning:
            completedCount = morningAzkarCompleted.values.filter { $0 }.count
        case .evening:
            completedCount = eveningAzkarCompleted.values.filter { $0 }.count
        }
        return Double(completedCount) / Double(totalAzkar)
    }

    func resetDailyProgressIfNeeded() {
        let calendar = Calendar.current
        let now = Date()

        if let lastReset = lastResetDate {
            if !calendar.isDate(lastReset, inSameDayAs: now) {
                // It's a new day, reset progress
                morningAzkarCompleted = [:]
                eveningAzkarCompleted = [:]
                self.lastResetDate = now
                saveProgress()
                print("Daily Sunnah Azkar progress has been reset.")
            }
        } else {
            // First time launch or no reset date found, set it to now
            self.lastResetDate = now
            saveProgress()
            print("Initialized Sunnah Azkar progress for the first time.")
        }
    }

    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(morningAzkarCompleted, forKey: morningAzkarCompletedKey)
        defaults.set(eveningAzkarCompleted, forKey: eveningAzkarCompletedKey)
        defaults.set(lastResetDate, forKey: lastResetDateKey)
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
    
    // Call this method when the app becomes active to ensure daily reset logic is triggered.
    func appDidBecomeActive() {
        resetDailyProgressIfNeeded()
    }
}