# Azkar Fold

<p align="center">
  <strong>مطوية الأذكار</strong> — personal azkar and curated Sunnah remembrances for iOS
</p>

<p align="center">
  <a href="https://apps.apple.com/app/id6745419190">
    <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83" alt="Download on the App Store" height="60">
  </a>
</p>

<p align="center">
  <a href="https://apps.apple.com/app/id6745419190">App Store</a> ·
  <a href="https://tahhancoding.github.io/Azkar-Fold/privacy-policy.html">Privacy Policy</a> ·
  <a href="LICENSE">License (MIT)</a>
</p>

Azkar Fold is an open-source SwiftUI app for daily Islamic remembrance. It combines a neo-brutalist UI with bundled Sunnah azkar content and personal custom azkar you create on-device.

## Features

### Azkary
- Create, edit, and delete personal azkar
- Tap to count; progress saved locally
- Long-press a row to reveal delete
- Share a zekr as an image

### Sunnah
- Morning, evening, prayer, sleep, and wake-up categories from bundled SQLite content
- Simple and full reading modes
- Optional secondary translation language
- Progress tracking and category selection

### Settings
- Arabic / English in-app language
- Custom themes and background patterns
- Sunnah display preferences
- Privacy policy and terms in-app
- Contact support with attachments

## Requirements

- macOS with **Xcode 16+**
- **iOS 16.0+** (app target)
- Apple Developer account (for device testing and App Store builds)

## Getting started

1. Clone the repository:
   ```bash
   git clone https://github.com/TahhanCoding/Azkar-Fold.git
   cd Azkar-Fold
   ```
2. Open `Azkar Fold/Azkar Fold.xcodeproj` in Xcode.
3. Set your development team under **Signing & Capabilities**.
4. Add Firebase config (see below).
5. Build and run on a simulator or device.

## Firebase setup (optional for local dev)

The app uses Firebase for:

- **Remote Config** — optional / force update checks (`min_version`, `latest_version`)
- **Analytics** (`FirebaseAnalyticsCore`, without Ad ID) — anonymous usage (sessions, a few feature events)
- **Crashlytics** — crash and non-fatal diagnostics

1. Create a Firebase iOS app or use an existing project.
2. In the Firebase Console, enable **Analytics** and **Crashlytics** for the iOS app.
3. Download `GoogleService-Info.plist` (ensure `IS_ANALYTICS_ENABLED` is `true`).
4. Copy the example file and replace placeholders:
   ```bash
   cp "Azkar Fold/Azkar Fold/GoogleService-Info.plist.example" "Azkar Fold/Azkar Fold/GoogleService-Info.plist"
   ```
5. Paste your real Firebase values into `GoogleService-Info.plist`.

`GoogleService-Info.plist` is gitignored. Do not commit production keys.

If Firebase is not configured, the app should still run; update prompts, analytics, and crash reporting will not work until the plist and Console products are set up.

When submitting to App Store Connect, disclose **crash data** and **product interaction** analytics in App Privacy (no advertising ID).

To verify Analytics quickly, run with launch argument `-FIRDebugEnabled` and check Firebase **DebugView**.

## Project structure

```
Azkar Fold/
├── Azkar Fold/              # iOS app source
│   ├── Views/               # SwiftUI screens
│   ├── Services/            # Content, Firebase, localization
│   ├── Models/              # App models
│   ├── Resources/           # String catalog, JSON, azkar DB
│   └── Fonts/               # Amiri Quran (OFL)
├── docs/                    # GitHub Pages (privacy policy)
├── Azkar Fold/azkar-db-master/   # Sunnah content database (maintenance copy)
└── Azkar Fold/content_setUp_Guide.md
```

## Content

Sunnah azkar text comes from the bundled **azkar-db** SQLite database (see [azkar-db-master README](Azkar%20Fold/azkar-db-master/README.md)). That dataset is maintained separately and is **not covered by this repo’s MIT license** — see its own terms in that folder.

To update Sunnah content, follow [content_setUp_Guide.md](Azkar%20Fold/content_setUp_Guide.md).

## Third-party notices

| Component | License / terms |
|-----------|-----------------|
| App source code | [MIT](LICENSE) |
| [Amiri Quran](Azkar%20Fold/Azkar%20Fold/Fonts/AmiriQuran-OFL.txt) font | SIL Open Font License 1.1 |
| [azkar-db](Azkar%20Fold/azkar-db-master/README.md) Sunnah content | Separate terms (see azkar-db README) |
| [Firebase iOS SDK](https://firebase.google.com/) | Google terms |

## GitHub Pages

Privacy policy for App Store Connect:

**Privacy:** https://tahhancoding.github.io/Azkar-Fold/privacy-policy.html  
**Support:** https://tahhancoding.github.io/Azkar-Fold/support.html

Enable in repo **Settings → Pages → Deploy from branch `main` → `/docs`**.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Support

- **Email:** [tahhancoding@gmail.com](mailto:tahhancoding@gmail.com)
- **Issues:** [GitHub Issues](https://github.com/TahhanCoding/Azkar-Fold/issues)

## License

Copyright © 2026 Ahmed AlTahhan

Released under the [MIT License](LICENSE).
