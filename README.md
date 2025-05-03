# Azkar-Fold

## App Description

Azkar-Fold is an Islamic app with three main tab views: Settings, Azkary, and Sunnah. The app focuses on providing users with a personalized experience for their daily Islamic remembrances (Azkar).

### Azkary Tab View
- **Custom Azkar Creation**: Users can create their own personalized Zekr (remembrance).
- **Azkar List**: Displays a list of user-created Azkar, showing the Zekr text, counter value, and last time the counter was updated.
- **Empty State**: Shows a "No custom Azkar created yet" view when the user hasn't created any Azkar.
- **ZekrView**: When a user taps on a Zekr, they are taken to a dedicated view where:
  - The upper half displays the Zekr text
  - The lower half provides a tappable area to increment the counter
  - The counter is displayed in a large, bold font within the tappable area

### Design Philosophy
The app combines Neo-Brutalism design principles with Islamic textures in a minimalist style:
- **Neo-Brutalism Elements**:
  - Bold Typography: Strong, clear fonts that make text stand out
  - Vibrant Colors: Bright and contrasting colors for visual interest
  - Minimalistic Layouts: Simple, uncluttered designs focusing on essential elements
  - Raw Aesthetic: Embracing unfinished or raw elements to highlight authenticity
  - Functional Design: Prioritizing functionality and usability
- **Islamic Textures**: Subtle Islamic patterns and textures integrated into the minimalist design

## App Navigation

The Azkar Fold app uses a structured navigation system managed by the `NavigationCoordinator`. This coordinator handles navigation paths and routes within the app.

### NavigationCoordinator
- **Routes**: The app defines several routes such as `home`, `azkarList`, `azkarDetail`, `settings`, and `about`.
- **Navigation Functions**: It provides functions to navigate to specific routes, go back one level, or return to the root.
- **Deep Linking**: The coordinator can handle deep links by parsing URLs and navigating to the appropriate route.

### RootView
- Utilizes a `NavigationStack` to manage navigation destinations.
- Sets up the initial view as `HomeView` and uses `navigationDestination` to handle route changes.

### ViewFactory
- Responsible for creating views based on the current route.
- Supports views like `HomeView`, `AzkarListView`, `AzkarDetailView`, `SettingsView`, and `AboutView`.

This setup allows for a flexible and scalable navigation system within the Azkar Fold app.