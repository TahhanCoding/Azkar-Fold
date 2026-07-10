//
//  TabPreferencesStore.swift
//  Azkar Fold
//

import Foundation
import Combine

class TabPreferencesStore: ObservableObject {
    static let shared = TabPreferencesStore()

    private enum Keys {
        static let prayerVisible = "tab_prayer_visible"
        static let tabOrder = "tab_order"
        static let startupTab = "tab_startup"
    }

    @Published private(set) var isPrayerVisible: Bool
    @Published private(set) var tabOrder: [MainTab]
    @Published private(set) var startupTab: MainTab

    var visibleTabs: [MainTab] {
        tabOrder.filter { tab in
            if tab == .prayer {
                return isPrayerVisible
            }
            return true
        }
    }

    private init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: Keys.prayerVisible) == nil {
            isPrayerVisible = true
        } else {
            isPrayerVisible = defaults.bool(forKey: Keys.prayerVisible)
        }

        if let savedOrder = defaults.array(forKey: Keys.tabOrder) as? [String] {
            let parsed = savedOrder.compactMap(MainTab.init(rawValue:))
            tabOrder = Self.normalizedOrder(parsed)
        } else {
            tabOrder = MainTab.defaultOrder
        }

        if let savedStartup = defaults.string(forKey: Keys.startupTab),
           let tab = MainTab(rawValue: savedStartup) {
            startupTab = tab
        } else {
            startupTab = .azkary
        }

        ensureValidStartupTab()
    }

    func setPrayerVisible(_ visible: Bool) {
        guard isPrayerVisible != visible else { return }
        isPrayerVisible = visible
        UserDefaults.standard.set(visible, forKey: Keys.prayerVisible)
        ensureValidStartupTab()
    }

    func moveTabs(from source: IndexSet, to destination: Int) {
        var order = tabOrder
        order.move(fromOffsets: source, toOffset: destination)
        tabOrder = order
        UserDefaults.standard.set(order.map(\.rawValue), forKey: Keys.tabOrder)
    }

    func setStartupTab(_ tab: MainTab) {
        guard visibleTabs.contains(tab) else { return }
        guard startupTab != tab else { return }
        startupTab = tab
        UserDefaults.standard.set(tab.rawValue, forKey: Keys.startupTab)
    }

    func resolvedStartupTab() -> MainTab {
        if visibleTabs.contains(startupTab) {
            return startupTab
        }
        return visibleTabs.first ?? .azkary
    }

    private func ensureValidStartupTab() {
        guard !visibleTabs.contains(startupTab) else { return }
        let fallback = visibleTabs.first ?? .azkary
        startupTab = fallback
        UserDefaults.standard.set(fallback.rawValue, forKey: Keys.startupTab)
    }

    private static func normalizedOrder(_ order: [MainTab]) -> [MainTab] {
        var result = order
        for tab in MainTab.defaultOrder where !result.contains(tab) {
            result.append(tab)
        }
        result = result.filter { MainTab.allCases.contains($0) }
        var seen = Set<MainTab>()
        result = result.filter { seen.insert($0).inserted }
        return result.isEmpty ? MainTab.defaultOrder : result
    }
}
