//
//  PrayerClockView.swift
//  Azkar Fold
//

import SwiftUI

struct PrayerClockView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    let state: PrayerClockState

    private let dialSize: CGFloat = 280

    var body: some View {
        ZStack {
            dial
            centerStatus
        }
        .frame(width: dialSize, height: dialSize)
    }

    private var dial: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 8
            let trackWidth: CGFloat = 28
            let activeWidth: CGFloat = 34

            let plateRect = CGRect(
                x: center.x - radius - 6,
                y: center.y - radius - 6,
                width: (radius + 6) * 2,
                height: (radius + 6) * 2
            )
            context.fill(
                Path(ellipseIn: plateRect),
                with: .color(theme.currentTheme.cardBackground.opacity(0.92))
            )

            var track = Path()
            track.addArc(
                center: center,
                radius: radius - trackWidth / 2,
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
            context.stroke(
                track,
                with: .color(theme.currentTheme.text.opacity(0.08)),
                style: StrokeStyle(lineWidth: trackWidth, lineCap: .butt)
            )

            for period in PrayerPeriod.allCases {
                let isActive = period == state.activePeriod
                let width = isActive ? activeWidth : trackWidth
                let color = blendedColor(for: period, isActive: isActive)
                let opacity = period.isFard ? (isActive ? 1.0 : 0.78) : (isActive ? 0.55 : 0.32)

                drawArc(
                    context: context,
                    center: center,
                    radius: radius - trackWidth / 2,
                    startDegrees: period.startAngleDegrees,
                    endDegrees: period.endAngleDegrees,
                    color: color.opacity(opacity),
                    lineWidth: width
                )

                if isActive {
                    drawArc(
                        context: context,
                        center: center,
                        radius: radius - trackWidth / 2,
                        startDegrees: period.startAngleDegrees,
                        endDegrees: period.endAngleDegrees,
                        color: color.opacity(0.28),
                        lineWidth: width + 10
                    )
                }
            }

            for hour in 0..<24 {
                let angle = Double(hour) / 24.0 * 360.0
                let isMajor = hour % 6 == 0
                let outer = point(on: center, radius: radius - trackWidth - 2, angleDegrees: angle)
                let inner = point(
                    on: center,
                    radius: radius - trackWidth - (isMajor ? 12 : 7),
                    angleDegrees: angle
                )
                var tick = Path()
                tick.move(to: outer)
                tick.addLine(to: inner)
                context.stroke(
                    tick,
                    with: .color(theme.currentTheme.text.opacity(isMajor ? 0.35 : 0.15)),
                    style: StrokeStyle(lineWidth: isMajor ? 1.5 : 1, lineCap: .round)
                )
            }

            for period in PrayerPeriod.allCases {
                let angle = period.startAngleDegrees
                let outer = point(on: center, radius: radius + 2, angleDegrees: angle)
                let inner = point(on: center, radius: radius - trackWidth - 4, angleDegrees: angle)
                var boundary = Path()
                boundary.move(to: outer)
                boundary.addLine(to: inner)
                context.stroke(
                    boundary,
                    with: .color(theme.currentTheme.text.opacity(0.45)),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
            }

            let handOuter = point(on: center, radius: radius + 4, angleDegrees: state.nowAngleDegrees)
            let handInner = point(on: center, radius: radius - trackWidth - 18, angleDegrees: state.nowAngleDegrees)
            var hand = Path()
            hand.move(to: handInner)
            hand.addLine(to: handOuter)
            context.stroke(
                hand,
                with: .color(theme.currentTheme.primary),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )

            let tip = Path(ellipseIn: CGRect(
                x: handOuter.x - 4.5,
                y: handOuter.y - 4.5,
                width: 9,
                height: 9
            ))
            context.fill(tip, with: .color(theme.currentTheme.primary))
            context.stroke(tip, with: .color(theme.currentTheme.cardBackground), lineWidth: 1.5)

            let hubRadius: CGFloat = radius - trackWidth - 22
            let hubRect = CGRect(
                x: center.x - hubRadius,
                y: center.y - hubRadius,
                width: hubRadius * 2,
                height: hubRadius * 2
            )
            context.stroke(
                Path(ellipseIn: hubRect),
                with: .color(theme.currentTheme.text.opacity(0.08)),
                lineWidth: 1
            )
        }
    }

    private var centerStatus: some View {
        let period = state.activePeriod
        return VStack(spacing: 6) {
            Image(systemName: period.systemImage)
                .font(.title2)
                .foregroundColor(blendedColor(for: period, isActive: true))

            Text(appLanguage.text(period.nameKey))
                .font(.headline.weight(.semibold))
                .foregroundColor(theme.currentTheme.text)
                .multilineTextAlignment(.center)

            Text("\(formatTime(period.startTimeString)) – \(formatTime(period.endTimeString))")
                .font(.caption)
                .foregroundColor(theme.currentTheme.text.opacity(0.55))
                .monospacedDigit()

            Text(appLanguage.text("prayer.countdown", state.countdownText))
                .font(.caption.weight(.medium))
                .foregroundColor(theme.currentTheme.primary)
                .padding(.top, 2)
        }
        .frame(maxWidth: 140)
        .padding(.horizontal, 8)
    }

    private func drawArc(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        startDegrees: Double,
        endDegrees: Double,
        color: Color,
        lineWidth: CGFloat
    ) {
        let start = Angle.degrees(startDegrees - 90)
        let end = Angle.degrees(endDegrees - 90)
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
        )
    }

    private func point(on center: CGPoint, radius: CGFloat, angleDegrees: Double) -> CGPoint {
        let radians = (angleDegrees - 90) * .pi / 180
        return CGPoint(
            x: center.x + radius * CGFloat(cos(radians)),
            y: center.y + radius * CGFloat(sin(radians))
        )
    }

    private func blendedColor(for period: PrayerPeriod, isActive: Bool) -> Color {
        period.semanticColor.mix(with: theme.currentTheme.primary, amount: isActive ? 0.28 : 0.18)
    }

    private func formatTime(_ hhmm: String) -> String {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            return hhmm
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = MakkahPrayerTimesSnapshot.timeZone
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        guard let date = calendar.date(from: components) else { return hhmm }
        return date.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened)
                .locale(appLanguage.locale)
        )
    }
}

extension Color {
    func mix(with other: Color, amount: Double) -> Color {
        let t = max(0, min(1, amount))
        let uiSelf = UIColor(self)
        let uiOther = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiSelf.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiOther.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t)
        )
    }
}
