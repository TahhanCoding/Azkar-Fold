//
//  PrayerClockWidget.swift
//  AzkarFoldWidgets
//

import WidgetKit
import SwiftUI

struct PrayerClockEntry: TimelineEntry {
    let date: Date
    let locationName: String
    let schedule: WidgetPrayerSchedule
    let activePeriod: WidgetPrayerPeriod
    let minutesUntilNext: Int
    let minutesFromMidnight: Int
}

struct PrayerClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerClockEntry {
        makeEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerClockEntry) -> Void) {
        completion(makeEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerClockEntry>) -> Void) {
        let now = Date()
        let location = WidgetPrayerLocation.load()
        let schedule = WidgetPrayerSchedule.calculate(for: location, on: now)
        var entries: [PrayerClockEntry] = []
        var cursor = now

        // Entries at now and at each upcoming period boundary for the next ~24h
        for _ in 0..<8 {
            let entry = makeEntry(at: cursor, location: location, schedule: schedule)
            entries.append(entry)
            let remaining = entry.minutesUntilNext
            let nextDate = cursor.addingTimeInterval(TimeInterval(max(remaining, 1) * 60))
            cursor = nextDate
            if nextDate.timeIntervalSince(now) > 24 * 60 * 60 {
                break
            }
        }

        // Also add periodic refresh entries every 15 minutes for the next 2 hours
        for offset in stride(from: 15, through: 120, by: 15) {
            let date = now.addingTimeInterval(TimeInterval(offset * 60))
            entries.append(makeEntry(at: date, location: location))
        }

        entries.sort { $0.date < $1.date }
        let refresh = now.addingTimeInterval(30 * 60)
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }

    private func makeEntry(
        at date: Date,
        location: WidgetPrayerLocation = .load(),
        schedule: WidgetPrayerSchedule? = nil
    ) -> PrayerClockEntry {
        let resolvedSchedule = schedule ?? WidgetPrayerSchedule.calculate(for: location, on: date)
        let minutes = WidgetPrayerSchedule.minutesFromMidnight(date: date, timeZone: resolvedSchedule.timeZone)
        let active = resolvedSchedule.activePeriod(at: minutes)
        let remaining = resolvedSchedule.minutesUntilEnd(of: active, from: minutes)
        return PrayerClockEntry(
            date: date,
            locationName: location.displayName,
            schedule: resolvedSchedule,
            activePeriod: active,
            minutesUntilNext: remaining,
            minutesFromMidnight: minutes
        )
    }
}

struct PrayerClockWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: PrayerClockEntry

    private let cream = Color(red: 0.996, green: 0.996, blue: 0.969)

    var body: some View {
        Group {
            switch family {
            case .systemLarge:
                clockOnlyDial(showHourLabels: true, shortCountdown: false)
                    .padding(8)
                    .widgetBackground { cream }

            case .systemSmall, .systemMedium:
                clockOnlyDial(showHourLabels: false, shortCountdown: true)
                    .padding(2)
                    .widgetBackground { cream }

            default:
                clockOnlyDial(showHourLabels: false, shortCountdown: true)
                    .padding(2)
                    .widgetBackground { cream }
            }
        }
        .widgetURL(URL(string: "azkarfold://prayer"))
    }

    /// Home Screen: dial only. Hour numbers + “Next in” only on Large.
    private func clockOnlyDial(showHourLabels: Bool, shortCountdown: Bool) -> some View {
        WidgetPrayerClockDialView(
            schedule: entry.schedule,
            activePeriod: entry.activePeriod,
            minutesFromMidnight: entry.minutesFromMidnight,
            showHourLabels: showHourLabels,
            showCenterStatus: true,
            compactCenter: false,
            shortCountdown: shortCountdown,
            dense: false
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension View {
    @ViewBuilder
    func widgetBackground<Background: View>(
        @ViewBuilder background: () -> Background
    ) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget, content: background)
        } else {
            self.background(background())
        }
    }
}

struct PrayerClockWidget: Widget {
    let kind = "PrayerClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerClockProvider()) { entry in
            PrayerClockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Clock")
        .description("Prayer periods clock for the Home Screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}
