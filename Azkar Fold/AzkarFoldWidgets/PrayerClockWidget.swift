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
            case .accessoryCircular:
                // Lock Screen circular slot is fixed by Apple — fill every pixel of it.
                WidgetPrayerClockDialView(
                    schedule: entry.schedule,
                    activePeriod: entry.activePeriod,
                    minutesFromMidnight: entry.minutesFromMidnight,
                    showHourLabels: true,
                    showCenterStatus: true,
                    compactCenter: true,
                    dense: true
                )
                .expandIntoWidgetMargins()
                .widgetBackground { EmptyView() }

            case .accessoryRectangular:
                // Wider Lock Screen slot — dial fills height (largest Lock Screen option).
                HStack(spacing: 6) {
                    WidgetPrayerClockDialView(
                        schedule: entry.schedule,
                        activePeriod: entry.activePeriod,
                        minutesFromMidnight: entry.minutesFromMidnight,
                        showHourLabels: true,
                        showCenterStatus: false,
                        compactCenter: true,
                        dense: true
                    )
                    .aspectRatio(1, contentMode: .fit)

                    periodSummary(compact: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .expandIntoWidgetMargins()
                .widgetBackground { AccessoryWidgetBackground() }

            case .accessoryInline:
                Text("\(entry.activePeriod.localizedName()) \(entry.schedule.hhmm(entry.schedule.startMinutes(for: entry.activePeriod))) · \(WidgetCountdown.text(minutes: entry.minutesUntilNext))")
                    .widgetBackground { EmptyView() }

            case .systemSmall, .systemMedium, .systemLarge:
                clockOnlyDial
                    .padding(family == .systemLarge ? 8 : 2)
                    .widgetBackground { cream }

            default:
                clockOnlyDial
                    .padding(2)
                    .widgetBackground { cream }
            }
        }
        .widgetURL(URL(string: "azkarfold://prayer"))
    }

    /// Home Screen: dial only — full center status + hour numbers.
    private var clockOnlyDial: some View {
        WidgetPrayerClockDialView(
            schedule: entry.schedule,
            activePeriod: entry.activePeriod,
            minutesFromMidnight: entry.minutesFromMidnight,
            showHourLabels: true,
            showCenterStatus: true,
            compactCenter: false,
            dense: false
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func periodSummary(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Image(systemName: entry.activePeriod.systemImage)
                .font(compact ? .title3 : .body)
            Text(entry.activePeriod.localizedName())
                .font(compact ? .headline : .subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(entry.schedule.hhmm(entry.schedule.startMinutes(for: entry.activePeriod)))
                .font(.caption.monospacedDigit())
                .opacity(0.8)
            Text(WidgetCountdown.text(minutes: entry.minutesUntilNext))
                .font(.caption2.monospacedDigit())
                .opacity(0.7)
        }
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

    /// Pulls content into system widget margins so Lock Screen dials read larger (iOS 17+).
    @ViewBuilder
    func expandIntoWidgetMargins() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            modifier(_ExpandIntoWidgetMargins())
        } else {
            self
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
private struct _ExpandIntoWidgetMargins: ViewModifier {
    @Environment(\.widgetContentMargins) private var margins

    func body(content: Content) -> some View {
        content.padding(-margins)
    }
}

struct PrayerClockWidget: Widget {
    let kind = "PrayerClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerClockProvider()) { entry in
            PrayerClockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Clock")
        .description("Prayer periods clock. Prefer Medium or Large on the Home Screen for a bigger dial.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
