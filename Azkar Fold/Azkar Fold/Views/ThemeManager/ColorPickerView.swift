//
//  ColorPickerView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ColorPickerView: View {
    let title: String
    @Binding var selectedColor: String
    @State private var showingColorPicker = false
    @State private var tempColor: Color
    
    init(title: String, selectedColor: Binding<String>) {
        self.title = title
        self._selectedColor = selectedColor
        self._tempColor = State(initialValue: Color(hex: selectedColor.wrappedValue))
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
            
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
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(
                title: title,
                selectedColor: $selectedColor,
                tempColor: $tempColor
            )
        }
    }
}

struct ColorPickerSheet: View {
    let title: String
    @Binding var selectedColor: String
    @Binding var tempColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var hexInput: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Color preview
                VStack(spacing: 12) {
                    Text("Preview")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
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
                    Text("Select Color")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ColorPicker("Color", selection: $tempColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                // Hex input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hex Code")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("#RRGGBB", text: $hexInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.allCharacters)
                            .onChange(of: hexInput) { newValue in
                                if isValidHex(newValue) {
                                    tempColor = Color(hex: newValue)
                                }
                            }
                        
                        Button("Apply") {
                            if isValidHex(hexInput) {
                                tempColor = Color(hex: hexInput)
                            }
                        }
                        .disabled(!isValidHex(hexInput))
                    }
                }
                .padding(.horizontal)
                
                // Preset colors
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preset Colors")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
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
                                            .stroke(Color.blue, lineWidth: 2)
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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedColor = tempColor.toHex()
                        dismiss()
                    }
                    .fontWeight(.semibold)
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
    ColorPickerView(title: "Primary Color", selectedColor: .constant("#4A9897"))
}