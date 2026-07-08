# Contributing to Azkar Fold

Thank you for helping improve Azkar Fold.

## Before you start

- Search [existing issues](https://github.com/TahhanCoding/Azkar-Fold/issues) to avoid duplicate work.
- For large changes, open an issue first to discuss the approach.
- Keep PRs focused. One feature or fix per pull request when possible.

## Development setup

1. Fork and clone the repo.
2. Open `Azkar Fold/Azkar Fold.xcodeproj` in Xcode 16+.
3. Copy `GoogleService-Info.plist.example` to `GoogleService-Info.plist` and add your Firebase values (or skip if you are not testing update flows).
4. Select your development team for signing.
5. Run on an iOS 16+ simulator or device.

## Code guidelines

- Follow existing SwiftUI patterns and naming in the project.
- Prefer small, readable changes over broad refactors.
- UI strings belong in `Localizable.xcstrings` (English + Arabic).
- Azkar **content text** stays Arabic; localize app chrome only unless the task is explicitly about translations.
- Do not commit secrets, signing assets, or `GoogleService-Info.plist`.

## Content changes (Sunnah azkar)

Sunnah text lives in the bundled SQLite database. See [content_setUp_Guide.md](Azkar%20Fold/content_setUp_Guide.md).

When submitting content fixes, include:

- Category (morning, evening, prayer, sleep, wake-up)
- What changed (text, count, reference, etc.)
- Source or justification when possible

The azkar-db dataset has its own terms — see [azkar-db-master/README.md](Azkar%20Fold/azkar-db-master/README.md).

## Pull requests

1. Branch from `main`.
2. Test your change in the simulator (and on device for navigation, gestures, or RTL).
3. Use a clear PR title and description.
4. Link related issues if any.

## Reporting bugs

Include:

- iOS version and device/simulator
- App language (Arabic / English)
- Steps to reproduce
- Expected vs actual behavior
- Screenshots or screen recordings if helpful

## Questions

- Open a GitHub issue for bugs and feature ideas.
- Email: [tahhancoding@gmail.com](mailto:tahhancoding@gmail.com)

## License

By contributing, you agree that your contributions will be licensed under the same [MIT License](LICENSE) as the project.
