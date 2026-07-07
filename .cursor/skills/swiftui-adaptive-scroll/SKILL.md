---
name: swiftui-adaptive-scroll
description: Build SwiftUI views that shrink to content height and only scroll when content exceeds a max height. Use when implementing adaptive cards, text containers, ScrollView sizing, ViewThatFits, scrollBounceBehavior, TabView height, or when ScrollView breaks intrinsic/adaptive layout.
---

# SwiftUI Adaptive Scroll Containers

## Problem

`ScrollView` expands to fill proposed space. Combining it with `.frame(minHeight:maxHeight:)` makes the container **always** consume max height and **clips** content when measurement is wrong.

PreferenceKey height hacks often report `0` on first layout → false non-scroll path → truncation.

**TabView / page containers** propose **infinite height** to children. `ViewThatFits` then always picks the first child (plain text) because infinite space always "fits" — scroll never activates, or layout clips oddly.

## Correct pattern: `ViewThatFits(in: .vertical)`

Pick **plain content** when it fits; fall back to **ScrollView** only when it overflows.

```swift
// Parent — center with spacers, not frame alignment on maxHeight child
GeometryReader { geometry in
    VStack(spacing: 0) {
        Spacer(minLength: 0)
        AdaptiveCard(text: text, availableHeight: geometry.size.height)
        Spacer(minLength: 0)
    }
    .frame(width: geometry.size.width, height: geometry.size.height)
}

// Card
let heightBudget = min(maxCardHeight, max(availableHeight, 1))

ViewThatFits(in: .vertical) {
    content.fixedSize(horizontal: false, vertical: true)
    ScrollView(.vertical, showsIndicators: true) {
        content
    }
    .frame(height: heightBudget - verticalInsets)
}
.frame(maxWidth: .infinity)
.frame(maxHeight: heightBudget)
.fixedSize(horizontal: false, vertical: true)
```

### Rules

1. **Always** pass `in: .vertical` — default axes cause text-wrap vs scroll mis-selection ([Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-an-adaptive-layout-with-viewthatfits)).
2. **Bound** `ViewThatFits` with `.frame(maxHeight: heightBudget)` where `heightBudget` is **finite** (from `GeometryReader` in parent, not inside the card).
3. **Never** put `GeometryReader` + `.position()` inside the card — causes clipping and non-adaptive sizing.
4. **Do not** wrap everything in `ScrollView` for adaptive height.
5. **Do not** set `.frame(height:)` on the outer card from measured PreferenceKey state.
6. First child must use `.fixedSize(horizontal: false, vertical: true)` so text reports true height.
7. Parent page: `VStack { Spacer; card; Spacer }` — reliable vertical centering. Do **not** use `.frame(width:height:alignment: .center)` on a child that also has `.frame(maxHeight:)` — Apple expands the child to the proposed height when max ≥ proposal.
8. After bounding `ViewThatFits` with `.frame(maxHeight:)`, add `.fixedSize(horizontal: false, vertical: true)` so the card reports intrinsic height to the parent (short = shrink, long = scroll height).

## TabView-specific

```swift
TabView(selection: $index) {
    ForEach(items.indices, id: \.self) { i in
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                card(availableHeight: geo.size.height)
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .tag(i)
    }
}
.tabViewStyle(.page(indexDisplayMode: .never))
```

Without `GeometryReader` at page level, `ViewThatFits` receives infinite vertical proposal → broken.

## Alternative: always ScrollView + bounce (not adaptive height)

If max height is fixed and only bounce behavior matters:

```swift
ScrollView { content }
    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
    .frame(maxHeight: maxHeight)
```

iOS 16.4+. Shrinks bounce, **not** container height. Use `ViewThatFits` when the card itself must grow/shrink.

## Modifier audit checklist

| Anti-pattern | Why |
|---|---|
| `ScrollView` + `.frame(minHeight: X, maxHeight: Y)` on same axis | Always fills to max |
| Hidden `GeometryReader` measurement driving height | Often 0 / wrong width → truncation |
| `GeometryReader` inside card with `.position()` | Clips content, breaks adaptive height |
| `lineLimit` / `minimumScaleFactor` with scroll | Fights adaptive layout |
| Parent `VStack` without `Spacer` in flexible height | Stretches child |
| Missing finite `maxHeight` on `ViewThatFits` | Infinite TabView proposal → wrong branch |
| `.frame(maxHeight:)` + parent `.frame(height:, alignment: .center)` | Child expands to full proposed height; centering fails |

## References

- [ViewThatFits vertical axis](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-an-adaptive-layout-with-viewthatfits)
- [Mastering ViewThatFits](https://fatbobman.com/en/posts/mastering-viewthatfits/)
- [scrollBounceBehavior(.basedOnSize)](https://www.avanderlee.com/swiftui/scrollview-bounce-behavior/)
- [TabView height in ScrollView](https://stackoverflow.com/questions/76008079/content-inside-tabview-is-not-growing-inside-scrollview)
