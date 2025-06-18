//
//  ThemeEditorView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ThemeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var editingTheme: Theme
    @State private var showingPreview = false
    @State private var showingDeleteAlert = false
    @State private var validationErrors: [String] = []
    
    let isEditing: Bool
    let originalTheme: Theme?
    
    init(theme: Theme? = nil) {
        if let theme = theme {
            self.isEditing = true
            self.originalTheme = theme
            self._editingTheme = State(initialValue: theme)
        } else {
            self.isEditing = false
            self.originalTheme = nil
            self._editingTheme = State(initialValue: Theme(name: "My Custom Theme"))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Theme name section
                Section("Theme Name") {
                    TextField("Enter theme name", text: $editingTheme.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Color customization section
                Section("Colors") {
                    ColorPickerView(title: "Primary Color", selectedColor: $editingTheme.primaryColor)
                    ColorPickerView(title: "Secondary Color", selectedColor: $editingTheme.secondaryColor)
                    ColorPickerView(title: "Background Color", selectedColor: $editingTheme.backgroundColor)
                    ColorPickerView(title: "Accent Color", selectedColor: $editingTheme.accentColor)
                    ColorPickerView(title: "Text Color", selectedColor: $editingTheme.textColor)
                    ColorPickerView(title: "Card Background", selectedColor: $editingTheme.cardBackgroundColor)
                    ColorPickerView(title: "Button Text Color", selectedColor: $editingTheme.buttonTextColor)
                }
                
                // Preview section
                Section("Preview") {
                    Button(action: {
                        showingPreview = true
                    }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("View Full Preview")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Compact preview
                    ThemePreviewView(theme: editingTheme, isCompact: true)
                        .frame(height: 80)
                        .padding(.vertical, 8)
                }
                
                // Actions section
                if isEditing && originalTheme?.isDefault == false {
                    Section {
                        Button("Delete Theme", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
                
                // Validation errors
                if !validationErrors.isEmpty {
                    Section("Errors") {
                        ForEach(validationErrors, id: \.self) { error in
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Theme" : "New Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Create") {
                        saveTheme()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidTheme)
                }
            }
        }
        .sheet(isPresented: $showingPreview) {
            NavigationView {
                ScrollView {
                    ThemePreviewView(theme: editingTheme)
                        .padding()
                }
                .navigationTitle("Theme Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingPreview = false
                        }
                    }
                }
            }
        }
        .alert("Delete Theme", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTheme()
            }
        } message: {
            Text("Are you sure you want to delete this theme? This action cannot be undone.")
        }
        .onChange(of: editingTheme.name) { _ in validateTheme() }
        .onChange(of: editingTheme.primaryColor) { _ in validateTheme() }
        .onChange(of: editingTheme.secondaryColor) { _ in validateTheme() }
        .onChange(of: editingTheme.backgroundColor) { _ in validateTheme() }
        .onChange(of: editingTheme.accentColor) { _ in validateTheme() }
        .onChange(of: editingTheme.textColor) { _ in validateTheme() }
        .onChange(of: editingTheme.cardBackgroundColor) { _ in validateTheme() }
        .onChange(of: editingTheme.buttonTextColor) { _ in validateTheme() }
        .onAppear {
            validateTheme()
        }
    }
    
    private var isValidTheme: Bool {
        validationErrors.isEmpty
    }
    
    private func validateTheme() {
        validationErrors = themeManager.validateTheme(editingTheme)
    }
    
    private func saveTheme() {
        if isEditing {
            themeManager.updateCustomTheme(editingTheme)
        } else {
            themeManager.addCustomTheme(editingTheme)
        }
        dismiss()
    }
    
    private func deleteTheme() {
        if let originalTheme = originalTheme {
            themeManager.deleteCustomTheme(originalTheme)
        }
        dismiss()
    }
}

#Preview {
    ThemeEditorView()
        .environmentObject(ThemeManager.shared)
}

#Preview("Editing") {
    ThemeEditorView(theme: Theme.defaultTheme)
        .environmentObject(ThemeManager.shared)
}