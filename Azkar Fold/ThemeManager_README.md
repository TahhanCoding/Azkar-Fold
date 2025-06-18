# Theme Manager System Documentation

## Overview

The Theme Manager system provides comprehensive theming capabilities for the Azkar Fold app, allowing users to customize colors and create personalized themes. The system includes theme storage, real-time preview, color customization, and seamless integration throughout the app.

## Features

### 🎨 Theme Management
- **Default Themes**: Pre-built themes (Default, Dark, Ocean, Sunset)
- **Custom Themes**: Create unlimited custom themes
- **Theme Persistence**: Themes are saved locally and persist across app launches
- **Real-time Application**: Theme changes apply immediately across all views

### 🖌️ Color Customization
- **Full Color Control**: Customize primary, secondary, background, accent, text, card background, and button text colors
- **Color Picker**: Advanced color picker with hex input and preset colors
- **Hex Support**: Full support for #RGB, #RRGGBB, and #AARRGGBB formats
- **Color Validation**: Real-time validation of color inputs

### 👁️ Preview System
- **Live Preview**: See theme changes in real-time
- **Compact Preview**: Quick preview in theme lists
- **Full Preview**: Comprehensive preview showing all UI elements
- **Mock Interface**: Preview shows buttons, cards, text, and other UI components

### 🔧 Developer Integration
- **Theme-Aware Colors**: Easy access to current theme colors via `Color.themePrimary`, `Color.themeBackground`, etc.
- **Environment Integration**: ThemeManager available as environment object
- **Smooth Transitions**: Animated theme changes with customizable duration

## Usage

### Accessing Theme Colors in Views

```swift
// Use theme-aware colors in your views
Text("Hello World")
    .foregroundColor(.themeText)
    .background(.themeCardBackground)

Button("Action") {
    // Action
}
.foregroundColor(.themeButtonText)
.background(.themePrimary)

// Access theme manager directly
@EnvironmentObject var themeManager: ThemeManager

var body: some View {
    VStack {
        Text("Current theme: \(themeManager.currentTheme.name)")
            .foregroundColor(themeManager.currentTheme.text)
    }
}
```

### Available Theme Colors

- `Color.themePrimary` - Primary brand color
- `Color.themeSecondary` - Secondary accent color
- `Color.themeBackground` - Main background color
- `Color.themeAccent` - Accent color for highlights
- `Color.themeText` - Primary text color
- `Color.themeCardBackground` - Card and surface background
- `Color.themeButtonText` - Text color for buttons

### Creating Custom Themes

```swift
// Create a new theme
let customTheme = Theme(
    name: "My Theme",
    primaryColor: "#FF6B35",
    secondaryColor: "#F7931E",
    backgroundColor: "#FFF8E1",
    accentColor: "#D84315",
    textColor: "#333333",
    cardBackgroundColor: "#FFFFFF",
    buttonTextColor: "#FFFFFF"
)

// Add to theme manager
themeManager.addCustomTheme(customTheme)

// Set as current theme
themeManager.setCurrentTheme(customTheme)
```

### Theme Manager Operations

```swift
@EnvironmentObject var themeManager: ThemeManager

// Get all available themes
let allThemes = themeManager.allThemes

// Get only custom themes
let customThemes = themeManager.customThemes

// Update existing theme
themeManager.updateCustomTheme(modifiedTheme)

// Delete custom theme
themeManager.deleteCustomTheme(themeToDelete)

// Duplicate theme
let duplicatedTheme = themeManager.duplicateTheme(existingTheme)

// Validate theme
let errors = themeManager.validateTheme(theme)
```

## File Structure

```
Theme Manager System/
├── Models/
│   └── Theme.swift                    # Theme data model
├── Services/
│   └── ThemeManager.swift            # Theme management service
├── Views/ThemeManager/
│   ├── ThemeManagerView.swift        # Main theme manager interface
│   ├── ThemeEditorView.swift         # Theme creation/editing
│   ├── ColorPickerView.swift         # Color selection component
│   ├── ThemePreviewView.swift        # Theme preview component
│   └── ThemeExampleView.swift        # Usage examples
└── Extensions/
    └── Color+Extensions.swift        # Color utilities and theme integration
```

## Integration Points

### 1. App Initialization
The ThemeManager is initialized as a singleton and added to the environment in `RootView.swift`:

```swift
@StateObject private var themeManager = ThemeManager.shared

// In body
.environmentObject(themeManager)
```

### 2. Settings Integration
The Theme Manager is accessible from the Settings tab with a dedicated section:

```swift
Section("Appearance") {
    NavigationLink(destination: ThemeManagerView()) {
        // Theme manager entry
    }
}
```

### 3. View Integration
Views can access theme colors using the convenient static properties:

```swift
.foregroundColor(.themePrimary)
.background(.themeBackground)
```

## Best Practices

### 1. Use Theme-Aware Colors
Always use `Color.theme*` properties instead of hardcoded colors:

```swift
// ✅ Good
.foregroundColor(.themePrimary)

// ❌ Avoid
.foregroundColor(.blue)
```

### 2. Test with Different Themes
Test your views with different themes to ensure proper contrast and readability:

```swift
#Preview {
    MyView()
        .environmentObject(ThemeManager.shared)
        .onAppear {
            ThemeManager.shared.setCurrentTheme(Theme.darkTheme)
        }
}
```

### 3. Provide Fallbacks
When using theme colors programmatically, provide sensible fallbacks:

```swift
let textColor = themeManager.currentTheme.text
```

### 4. Validate Custom Themes
Always validate themes before saving:

```swift
let errors = themeManager.validateTheme(newTheme)
if errors.isEmpty {
    themeManager.addCustomTheme(newTheme)
} else {
    // Handle validation errors
}
```

## Color Utilities

The system includes helpful color utilities:

```swift
// Convert colors to hex
let hexString = Color.blue.toHex() // "#0000FF"

// Validate hex colors
let isValid = Color.isValidHex("#FF0000") // true

// Create lighter/darker variants
let lighterColor = Color.themePrimary.lighter(by: 0.2)
let darkerColor = Color.themePrimary.darker(by: 0.3)

// Initialize from hex
let customColor = Color(hex: "#FF6B35")
```

## Troubleshooting

### Theme Not Applying
1. Ensure ThemeManager is added as environment object
2. Use `Color.theme*` properties instead of hardcoded colors
3. Check that views are properly observing the ThemeManager

### Color Picker Issues
1. Verify hex color format (#RRGGBB or #RGB)
2. Check color validation in ThemeManager
3. Ensure proper binding to color properties

### Performance Considerations
1. Theme changes trigger view updates - use sparingly in animations
2. Color calculations are cached for performance
3. Theme persistence is handled automatically

## Future Enhancements

- **Theme Import/Export**: Share themes between devices
- **Gradient Support**: Add gradient color options
- **Dark Mode Integration**: Automatic theme switching based on system appearance
- **Theme Templates**: Pre-configured theme templates for quick customization
- **Color Accessibility**: Automatic contrast checking and suggestions

## Support

For questions or issues with the Theme Manager system, refer to the example implementations in `ThemeExampleView.swift` or check the inline documentation in the source files.