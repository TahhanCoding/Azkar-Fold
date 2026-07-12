//
//  WidgetPrayerClockDialView.swift
//  AzkarFoldWidgets
//
//  Visual parity with in-app PrayerClockView dial.
//

import SwiftUI

struct WidgetPrayerClockDialView: View {
    let schedule: WidgetPrayerSchedule
    let activePeriod: WidgetPrayerPeriod
    let minutesFromMidnight: Int
    var showHourLabels: Bool = true
    var showCenterStatus: Bool = true
    var compactCenter: Bool = false
    /// Boosts stroke scale so Lock Screen circular uses the slot aggressively.
    var dense: Bool = false

    private let accent = Color(red: 0.29, green: 0.60, blue: 0.59)
    private let cardBackground = Color(red: 0.996, green: 0.996, blue: 0.969)
    /// Explicit ink — `Color.primary` often fails to resolve inside widget Canvas / overlays.
    private let ink = Color(red: 0.14, green: 0.16, blue: 0.18)

    var body: some View {
        GeometryReader { geo in
            let side = max(1, min(geo.size.width, geo.size.height))
            let scale = dialScale(for: side)

            ZStack {
                dialCanvas(side: side, scale: scale)

                if showHourLabels {
                    hourLabelsOverlay(side: side, scale: scale)
                }

                if showCenterStatus {
                    centerStatus(side: side, scale: scale)
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func dialScale(for side: CGFloat) -> CGFloat {
        let base = side / 300.0
        if dense {
            return max(0.62, base * 1.35)
        }
        // Keep strokes readable on Small/Medium without crushing label math.
        return max(0.55, base)
    }

    private func dialCanvas(side: CGFloat, scale: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let inset: CGFloat = dense ? 1 : max(2, 8 * scale)
            let radius = min(size.width, size.height) / 2 - inset
            let trackWidth = max(dense ? 7 : 5, 26 * scale)
            let activeWidth = dense ? trackWidth + max(1.5, 6 * scale) : max(trackWidth + 6, 32 * scale)

            let platePad = dense ? 1 : max(2, 6 * scale)
            let plateRect = CGRect(
                x: center.x - radius - platePad,
                y: center.y - radius - platePad,
                width: (radius + platePad) * 2,
                height: (radius + platePad) * 2
            )
            context.fill(
                Path(ellipseIn: plateRect),
                with: .color(cardBackground.opacity(0.92))
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
                with: .color(ink.opacity(0.08)),
                style: StrokeStyle(lineWidth: trackWidth, lineCap: .butt)
            )

            for period in WidgetPrayerPeriod.allCases {
                let isActive = period == activePeriod
                let width = isActive ? activeWidth : trackWidth
                let color = blended(period.color, with: accent, amount: isActive ? 0.28 : 0.18)
                let opacity = period.isFard ? (isActive ? 1.0 : 0.78) : (isActive ? 0.55 : 0.32)
                let startDegrees = schedule.startAngle(for: period)
                let endDegrees = schedule.endAngle(for: period)

                drawArc(
                    context: context,
                    center: center,
                    radius: radius - trackWidth / 2,
                    startDegrees: startDegrees,
                    endDegrees: endDegrees,
                    color: color.opacity(opacity),
                    lineWidth: width
                )

                if isActive {
                    drawArc(
                        context: context,
                        center: center,
                        radius: radius - trackWidth / 2,
                        startDegrees: startDegrees,
                        endDegrees: endDegrees,
                        color: color.opacity(0.28),
                        lineWidth: width + max(3, 10 * scale)
                    )
                }
            }

            for hour in 0..<24 {
                let angle = Double(hour) / 24.0 * 360.0
                let isMajor = hour % 6 == 0
                let outer = point(on: center, radius: radius - trackWidth - 2 * scale, angleDegrees: angle)
                let inner = point(
                    on: center,
                    radius: radius - trackWidth - (isMajor ? 11 : 7) * scale,
                    angleDegrees: angle
                )
                var tick = Path()
                tick.move(to: outer)
                tick.addLine(to: inner)
                context.stroke(
                    tick,
                    with: .color(ink.opacity(isMajor ? 0.40 : 0.20)),
                    style: StrokeStyle(lineWidth: isMajor ? max(1, 1.5 * scale) : max(0.7, scale), lineCap: .round)
                )
            }

            for period in WidgetPrayerPeriod.allCases {
                let angle = schedule.startAngle(for: period)
                let outer = point(on: center, radius: radius + 2 * scale, angleDegrees: angle)
                let inner = point(on: center, radius: radius - trackWidth - 4 * scale, angleDegrees: angle)
                var boundary = Path()
                boundary.move(to: outer)
                boundary.addLine(to: inner)
                context.stroke(
                    boundary,
                    with: .color(ink.opacity(0.45)),
                    style: StrokeStyle(lineWidth: max(0.8, 1.5 * scale), lineCap: .round)
                )
            }

            let nowAngle = Double(minutesFromMidnight) / Double(24 * 60) * 360
            let handOuter = point(on: center, radius: radius + 4 * scale, angleDegrees: nowAngle)
            let handInner = point(on: center, radius: radius - trackWidth - 28 * scale, angleDegrees: nowAngle)
            var hand = Path()
            hand.move(to: handInner)
            hand.addLine(to: handOuter)
            context.stroke(
                hand,
                with: .color(accent),
                style: StrokeStyle(lineWidth: max(1.2, 2.5 * scale), lineCap: .round)
            )

            let tipSize = max(3, 9 * scale)
            let tip = Path(ellipseIn: CGRect(
                x: handOuter.x - tipSize / 2,
                y: handOuter.y - tipSize / 2,
                width: tipSize,
                height: tipSize
            ))
            context.fill(tip, with: .color(accent))
            context.stroke(tip, with: .color(cardBackground), lineWidth: max(0.8, 1.5 * scale))

            let hubRadius = radius - trackWidth - 32 * scale
            if hubRadius > 8 {
                let hubRect = CGRect(
                    x: center.x - hubRadius,
                    y: center.y - hubRadius,
                    width: hubRadius * 2,
                    height: hubRadius * 2
                )
                context.stroke(
                    Path(ellipseIn: hubRect),
                    with: .color(ink.opacity(0.10)),
                    lineWidth: 1
                )
            }
        }
    }

    /// SwiftUI Text overlays — Canvas-drawn Text is unreliable in WidgetKit.
    private func hourLabelsOverlay(side: CGFloat, scale: CGFloat) -> some View {
        let trackWidth = max(dense ? 7 : 5, 26 * scale)
        let inset: CGFloat = dense ? 1 : max(2, 8 * scale)
        let radius = side / 2 - inset
        let labelRadius = radius - trackWidth - max(14, 18 * scale)
        // Readable floor even on Small (~155pt).
        let majorSize = max(9, 10 * scale)
        let minorSize = max(7.5, 8 * scale)

        return ZStack {
            ForEach(0..<24, id: \.self) { hour in
                let angle = Double(hour) / 24.0 * 360.0
                let isMajor = hour % 6 == 0
                let point = point(on: CGPoint(x: side / 2, y: side / 2), radius: labelRadius, angleDegrees: angle)

                Text(String(format: "%02d", hour))
                    .font(.system(size: isMajor ? majorSize : minorSize, weight: isMajor ? .semibold : .medium).monospacedDigit())
                    .foregroundColor(ink.opacity(isMajor ? 0.78 : 0.55))
                    .position(point)
            }
        }
        .frame(width: side, height: side)
        .allowsHitTesting(false)
    }

    private func centerStatus(side: CGFloat, scale: CGFloat) -> some View {
        let period = activePeriod
        let start = schedule.hhmm(schedule.startMinutes(for: period))
        let end = schedule.hhmm(schedule.endMinutes(for: period))
        let remaining = schedule.minutesUntilEnd(of: period, from: minutesFromMidnight)

        let iconSize = max(compactCenter ? 11 : 16, (compactCenter ? 13 : 20) * scale)
        let nameSize = max(compactCenter ? 10 : 13, (compactCenter ? 11 : 15) * scale)
        let metaSize = max(11, 12 * scale)

        return VStack(spacing: compactCenter ? 2 : max(3, 4 * scale)) {
            Image(systemName: period.systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(blended(period.color, with: accent, amount: 0.28))

            Text(period.localizedName())
                .font(.system(size: nameSize, weight: .semibold))
                .foregroundColor(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            // Always show start–end when space allows (Home Screen).
            if !compactCenter {
                Text("\(start) – \(end)")
                    .font(.system(size: metaSize).monospacedDigit())
                    .foregroundColor(ink.opacity(0.60))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(WidgetCountdown.nextInText(minutes: remaining))
                    .font(.system(size: metaSize, weight: .medium))
                    .foregroundColor(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                // Lock Screen circular: still show the active name + short countdown.
                Text(WidgetCountdown.text(minutes: remaining))
                    .font(.system(size: max(9, 10 * scale), weight: .medium).monospacedDigit())
                    .foregroundColor(accent)
            }
        }
        .frame(width: side * (compactCenter ? 0.52 : 0.50))
        .multilineTextAlignment(.center)
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
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startDegrees - 90),
            endAngle: .degrees(endDegrees - 90),
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

    private func blended(_ a: Color, with b: Color, amount: Double) -> Color {
        let t = max(0, min(1, amount))
        let uiA = UIColor(a)
        let uiB = UIColor(b)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiA.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiB.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t)
        )
    }
}
