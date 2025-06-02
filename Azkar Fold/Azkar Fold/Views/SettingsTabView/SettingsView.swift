//
//  SettingsView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: .constant(false))
                    .toggleStyle(SwitchToggleStyle(tint: .appPrimary))
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Daily Reminders", isOn: .constant(true))
                    .toggleStyle(SwitchToggleStyle(tint: .appPrimary))
                
                Toggle("Prayer Times", isOn: .constant(true))
                    .toggleStyle(SwitchToggleStyle(tint: .appPrimary))
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                Button("Privacy Policy") {
                    // Action to show privacy policy
                }
                
                Button("Terms of Service") {
                    // Action to show terms of service
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .background(
            Image("islamic_pattern")
                .resizable(resizingMode: .tile)
                .opacity(0.05)
        )
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
