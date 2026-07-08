//
//  ColorPickerView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ColorPickerView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    let titleKey: String.LocalizationValue
    @Binding var selectedColor: String
    @State private var showingColorPicker = false
    @State private var tempColor: Color
    
    init(titleKey: String.LocalizationValue, selectedColor: Binding<String>) {
        self.titleKey = titleKey
        self._selectedColor = selectedColor
        self._tempColor = State(initialValue: Color(hex: selectedColor.wrappedValue))
    }
    
    var body: some View {
        HStack {
            Text(appLanguage.text(titleKey))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.currentTheme.text)
            
            Spacer()
            
            Button(action: {
                showingColorPicker = true
            }) {
                HStack(spacing: 8) {
                    // Color preview circle
                    Circle()
                        .fill(Color(hex: selectedColor))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Hex value
                    Text(selectedColor.uppercased())
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.currentTheme.text)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(
                titleKey: titleKey,
                selectedColor: $selectedColor,
                tempColor: $tempColor
            )
        }
    }
}

struct ColorPickerSheet: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    let titleKey: String.LocalizationValue
    @Binding var selectedColor: String
    @Binding var tempColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var hexInput: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Color preview
                VStack(spacing: 12) {
                    Text("theme.color_preview")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tempColor)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Color picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("theme.select_color")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    ColorPicker("Color", selection: $tempColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                // Hex input
                VStack(alignment: .leading, spacing: 8) {
                    Text("theme.hex_code")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    HStack {
                        TextField("#RRGGBB", text: $hexInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.allCharacters)
                            .foregroundColor(theme.currentTheme.text)
                            .onChange(of: hexInput) { newValue in
                                if isValidHex(newValue) {
                                    tempColor = Color(hex: newValue)
                                }
                            }
                        
                        Button(appLanguage.text("common.apply")) {
                            if isValidHex(hexInput) {
                                tempColor = Color(hex: hexInput)
                            }
                        }
                        .disabled(!isValidHex(hexInput))
                        .foregroundColor(theme.currentTheme.primary)
                    }
                }
                .padding(.horizontal)
                
                // Preset colors
                VStack(alignment: .leading, spacing: 8) {
                    Text("theme.preset_colors")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(presetColors, id: \.self) { color in
                            Button(action: {
                                tempColor = Color(hex: color)
                                hexInput = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(theme.currentTheme.primary, lineWidth: 2)
                                            .opacity(color == selectedColor ? 1 : 0)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(appLanguage.text(titleKey))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(appLanguage.text("common.cancel")) {
                        dismiss()
                    }
                    .foregroundColor(theme.currentTheme.text)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(appLanguage.text("common.done")) {
                        selectedColor = tempColor.toHex()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(theme.currentTheme.text)
                }
            }
        }
        .onAppear {
            hexInput = selectedColor
        }
        .onChange(of: tempColor) { newColor in
            hexInput = newColor.toHex()
        }
    }
    
    private func isValidHex(_ hex: String) -> Bool {
        let hexPattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        let regex = try? NSRegularExpression(pattern: hexPattern)
        let range = NSRange(location: 0, length: hex.count)
        return regex?.firstMatch(in: hex, options: [], range: range) != nil
    }
    
    private let presetColors = [
        "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF",
        "#FF8000", "#8000FF", "#0080FF", "#80FF00", "#FF0080", "#00FF80",
        "#800000", "#008000", "#000080", "#808000", "#800080", "#008080",
        "#C0C0C0", "#808080", "#404040", "#000000", "#FFFFFF", "#F0F0F0"
    ]
}

// Extension to convert Color to hex
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    ColorPickerView(titleKey: "theme.primary_color", selectedColor: .constant("#4A9897"))
}
