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
    @EnvironmentObject var appLanguage: AppLanguageManager
    
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
                Section(header: Text("theme.name_section").foregroundColor(themeManager.currentTheme.text)) {
                    TextField("theme.enter_name", text: $editingTheme.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(themeManager.currentTheme.text)
                }
                
                Section(header: Text("theme.colors_section").foregroundColor(themeManager.currentTheme.text)) {
                    ColorPickerView(titleKey: "theme.primary_color", selectedColor: $editingTheme.primaryColor)
                    ColorPickerView(titleKey: "theme.secondary_color", selectedColor: $editingTheme.secondaryColor)
                    ColorPickerView(titleKey: "theme.background_color", selectedColor: $editingTheme.backgroundColor)
                    ColorPickerView(titleKey: "theme.accent_color", selectedColor: $editingTheme.accentColor)
                    ColorPickerView(titleKey: "theme.text_color", selectedColor: $editingTheme.textColor)
                    ColorPickerView(titleKey: "theme.card_background_color", selectedColor: $editingTheme.cardBackgroundColor)
                    ColorPickerView(titleKey: "theme.button_text_color", selectedColor: $editingTheme.buttonTextColor)
                }
                
                Section(header: Text("theme.preview_section").foregroundColor(themeManager.currentTheme.text)) {
                    Button(action: {
                        showingPreview = true
                    }) {
                        HStack {
                            Image(systemName: "eye")
                                .foregroundColor(themeManager.currentTheme.primary)
                            Text("theme.view_full_preview")
                                .foregroundColor(themeManager.currentTheme.text)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.text)
                        }
                    }
                    
                    ThemePreviewView(theme: editingTheme, isCompact: true)
                        .frame(height: 80)
                        .padding(.vertical, 8)
                }
                
                if isEditing && originalTheme?.isDefault == false {
                    Section {
                        Button(appLanguage.text("theme.delete_title"), role: .destructive) {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(themeManager.currentTheme.text)
                    }
                } else if isEditing && originalTheme?.isDefault == true {
                    Section {
                        Text("theme.cannot_delete_default")
                            .foregroundColor(themeManager.currentTheme.text)
                            .font(.caption)
                    }
                }
                
                if !validationErrors.isEmpty {
                    Section(header: Text("theme.errors").foregroundColor(themeManager.currentTheme.text)) {
                        ForEach(validationErrors, id: \.self) { error in
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "theme.edit_title" : "theme.create_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(appLanguage.text("common.cancel")) {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.text)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? appLanguage.text("common.save") : appLanguage.text("common.create")) {
                        saveTheme()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidTheme)
                    .foregroundColor(themeManager.currentTheme.text)
                }
            }
        }
        .sheet(isPresented: $showingPreview) {
            NavigationView {
                ScrollView {
                    ThemePreviewView(theme: editingTheme)
                        .padding()
                }
                .navigationTitle("theme.preview_title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(appLanguage.text("common.done")) {
                            showingPreview = false
                        }
                    }
                }
            }
            .environmentObject(appLanguage)
        }
        .alert(appLanguage.text("theme.delete_title"), isPresented: $showingDeleteAlert) {
            Button(appLanguage.text("common.cancel"), role: .cancel) { }
            Button(appLanguage.text("common.delete"), role: .destructive) {
                deleteTheme()
            }
        } message: {
            Text("theme.delete_message")
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
            if !isEditing, editingTheme.name == "My Custom Theme" {
                editingTheme.name = appLanguage.text("theme.new_default_name")
            }
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
        .environmentObject(AppLanguageManager.shared)
}

#Preview("Editing") {
    ThemeEditorView(theme: Theme.defaultTheme)
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppLanguageManager.shared)
}
