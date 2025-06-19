//
//  ThemeExampleView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

/// Example view demonstrating how to use the theme system throughout the app
struct ThemeExampleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var counter = 0
    @State private var showingAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with theme colors
                headerSection
                
                // Cards with theme colors
                cardSection
                
                // Buttons with theme colors
                buttonSection
                
                // Interactive elements
                interactiveSection
                
                // Text examples
                textSection
            }
            .padding()
        }
        .background(themeManager.currentTheme.background)
        .navigationTitle("Theme Example")
        .navigationBarTitleDisplayMode(.large)
        .alert("Theme Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("This alert uses the current theme colors!")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Theme Integration Example")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primary)
            
            Text("This view demonstrates how to use theme colors throughout your app")
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.background)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(themeManager.currentTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primary.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cards")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.background)
            
            HStack(spacing: 12) {
                // Primary card
                VStack {
                    Circle()
                        .fill(themeManager.currentTheme.primary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .foregroundColor(themeManager.currentTheme.primary)
                        )
                    
                    Text("Primary")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.background)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                
                // Secondary card
                VStack {
                    Circle()
                        .fill(themeManager.currentTheme.secondary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(themeManager.currentTheme.secondary)
                        )
                    
                    Text("Secondary")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.background)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                
                // Accent card
                VStack {
                    Circle()
                        .fill(themeManager.currentTheme.accent)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "gear")
                                .foregroundColor(themeManager.currentTheme.cardBackground)
                        )
                    
                    Text("Accent")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.background)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
            }
        }
    }
    
    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Buttons")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.background)
            
            VStack(spacing: 8) {
                // Primary button
                Button("Primary Button") {
                    showingAlert = true
                }
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(themeManager.currentTheme.primary)
                .cornerRadius(8)
                
                // Secondary button
                Button("Secondary Button") {
                    counter += 1
                }
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(themeManager.currentTheme.primary.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.primary, lineWidth: 1)
                )
                
                // Accent button
                Button("Accent Button") {
                    counter -= 1
                }
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.cardBackground)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(themeManager.currentTheme.accent)
                .cornerRadius(8)
            }
        }
    }
    
    private var interactiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interactive Elements")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.background)
            
            VStack(spacing: 16) {
                // Counter
                HStack {
                    Text("Counter:")
                        .foregroundColor(themeManager.currentTheme.background)
                    
                    Spacer()
                    
                    Text("\(counter)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.currentTheme.primary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress")
                            .foregroundColor(themeManager.currentTheme.background)
                        
                        Spacer()
                        
                        Text("\(min(abs(counter), 10))/10")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.background.opacity(0.7))
                    }
                    
                    ProgressView(value: Double(min(abs(counter), 10)), total: 10)
                        .progressViewStyle(LinearProgressViewStyle(tint: themeManager.currentTheme.primary))
                        .background(themeManager.currentTheme.accent.opacity(0.2))
                        .cornerRadius(4)
                }
                
                // Toggle
                HStack {
                    Text("Theme Preview")
                        .foregroundColor(themeManager.currentTheme.background)
                    
                    Spacer()
                    
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.currentTheme.primary))
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Typography")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.background)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Primary Text")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.primary)
                
                Text("Secondary Text")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.secondary)
                
                Text("Regular body text that adapts to the current theme. This demonstrates how text colors change with different themes.")
                    .font(.body)
                    .foregroundColor(themeManager.currentTheme.background)
                
                Text("Accent text for highlights")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.currentTheme.accent)
                
                Text("Muted text for less important information")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.background.opacity(0.6))
            }
            .padding()
            .background(themeManager.currentTheme.cardBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView {
        ThemeExampleView()
            .environmentObject(ThemeManager.shared)
    }
}
