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

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circularContent
                    .widgetBackground { AccessoryWidgetBackground() }
            case .accessoryRectangular:
                rectangularContent
                    .widgetBackground { AccessoryWidgetBackground() }
            case .accessoryInline:
                inlineView
                    .widgetBackground { EmptyView() }
            case .systemSmall:
                homeSmallContent
                    .widgetBackground { Color(.systemBackground) }
            default:
                homeSmallContent
                    .widgetBackground { Color(.systemBackground) }
            }
        }
        .widgetURL(URL(string: "azkarfold://prayer"))
    }

    private var circularContent: some View {
        MiniPrayerDialView(
            schedule: entry.schedule,
            activePeriod: entry.activePeriod,
            minutesFromMidnight: entry.minutesFromMidnight
        )
        .padding(4)
    }

    private var rectangularContent: some View {
        periodSummary(compact: true)
            .padding(.horizontal, 4)
    }

    private var inlineView: some View {
        Text("\(entry.activePeriod.localizedName()) \(entry.schedule.hhmm(entry.schedule.startMinutes(for: entry.activePeriod))) · \(WidgetCountdown.text(minutes: entry.minutesUntilNext))")
    }

    private var homeSmallContent: some View {
        VStack(spacing: 8) {
            MiniPrayerDialView(
                schedule: entry.schedule,
                activePeriod: entry.activePeriod,
                minutesFromMidnight: entry.minutesFromMidnight
            )
            .frame(width: 72, height: 72)

            periodSummary(compact: false)
        }
        .padding(12)
    }

    private func periodSummary(compact: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: entry.activePeriod.systemImage)
                .font(compact ? .title3 : .body)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.activePeriod.localizedName())
                    .font(compact ? .headline : .subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(entry.schedule.hhmm(entry.schedule.startMinutes(for: entry.activePeriod)))
                    .font(.caption.monospacedDigit())
                    .opacity(0.8)
                Text(WidgetCountdown.text(minutes: entry.minutesUntilNext))
                    .font(.caption2.monospacedDigit())
                    .opacity(0.7)
            }
            Spacer(minLength: 0)
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
}

struct MiniPrayerDialView: View {
    let schedule: WidgetPrayerSchedule
    let activePeriod: WidgetPrayerPeriod
    let minutesFromMidnight: Int

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 1
            let lineWidth = max(4, radius * 0.22)

            for period in WidgetPrayerPeriod.allCases {
                let isActive = period == activePeriod
                drawArc(
                    context: context,
                    center: center,
                    radius: radius - lineWidth / 2,
                    start: periodStart(period),
                    end: periodEnd(period),
                    color: period.color.opacity(isActive ? 1 : (period == .shuruq ? 0.25 : 0.55)),
                    lineWidth: isActive ? lineWidth + 1.5 : lineWidth
                )
            }

            let nowAngle = Double(minutesFromMidnight) / Double(24 * 60) * 360
            let tip = point(center: center, radius: radius - 1, angle: nowAngle)
            let hub = point(center: center, radius: radius - lineWidth - 2, angle: nowAngle)
            var hand = Path()
            hand.move(to: hub)
            hand.addLine(to: tip)
            context.stroke(hand, with: .color(.primary), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }
    }

    private func periodStart(_ period: WidgetPrayerPeriod) -> Double {
        schedule.startAngle(for: period)
    }

    private func periodEnd(_ period: WidgetPrayerPeriod) -> Double {
        schedule.endAngle(for: period)
    }

    private func drawArc(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        start: Double,
        end: Double,
        color: Color,
        lineWidth: CGFloat
    ) {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(start - 90),
            endAngle: .degrees(end - 90),
            clockwise: false
        )
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let radians = (angle - 90) * .pi / 180
        return CGPoint(
            x: center.x + radius * CGFloat(cos(radians)),
            y: center.y + radius * CGFloat(sin(radians))
        )
    }
}

struct PrayerClockWidget: Widget {
    let kind = "PrayerClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerClockProvider()) { entry in
            PrayerClockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Clock")
        .description("Shows today’s prayer periods on the Home and Lock Screen.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
