# Azkar-Fold

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