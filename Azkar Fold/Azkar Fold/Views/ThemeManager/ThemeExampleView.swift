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
        .background(Color.themeBackground)
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
                .foregroundColor(.themePrimary)
            
            Text("This view demonstrates how to use theme colors throughout your app")
                .font(.subheadline)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themePrimary.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cards")
                .font(.headline)
                .foregroundColor(.themeText)
            
            HStack(spacing: 12) {
                // Primary card
                VStack {
                    Circle()
                        .fill(Color.themePrimary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .foregroundColor(.themeButtonText)
                        )
                    
                    Text("Primary")
                        .font(.caption)
                        .foregroundColor(.themeText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeCardBackground)
                .cornerRadius(8)
                
                // Secondary card
                VStack {
                    Circle()
                        .fill(Color.themeSecondary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(.themeButtonText)
                        )
                    
                    Text("Secondary")
                        .font(.caption)
                        .foregroundColor(.themeText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeCardBackground)
                .cornerRadius(8)
                
                // Accent card
                VStack {
                    Circle()
                        .fill(Color.themeAccent)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "gear")
                                .foregroundColor(.themeCardBackground)
                        )
                    
                    Text("Accent")
                        .font(.caption)
                        .foregroundColor(.themeText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeCardBackground)
                .cornerRadius(8)
            }
        }
    }
    
    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Buttons")
                .font(.headline)
                .foregroundColor(.themeText)
            
            VStack(spacing: 8) {
                // Primary button
                Button("Primary Button") {
                    showingAlert = true
                }
                .font(.headline)
                .foregroundColor(.themeButtonText)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.themePrimary)
                .cornerRadius(8)
                
                // Secondary button
                Button("Secondary Button") {
                    counter += 1
                }
                .font(.headline)
                .foregroundColor(.themePrimary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.themePrimary.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.themePrimary, lineWidth: 1)
                )
                
                // Accent button
                Button("Accent Button") {
                    counter -= 1
                }
                .font(.headline)
                .foregroundColor(.themeCardBackground)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.themeAccent)
                .cornerRadius(8)
            }
        }
    }
    
    private var interactiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interactive Elements")
                .font(.headline)
                .foregroundColor(.themeText)
            
            VStack(spacing: 16) {
                // Counter
                HStack {
                    Text("Counter:")
                        .foregroundColor(.themeText)
                    
                    Spacer()
                    
                    Text("\(counter)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.themePrimary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress")
                            .foregroundColor(.themeText)
                        
                        Spacer()
                        
                        Text("\(min(abs(counter), 10))/10")
                            .font(.caption)
                            .foregroundColor(.themeText.opacity(0.7))
                    }
                    
                    ProgressView(value: Double(min(abs(counter), 10)), total: 10)
                        .progressViewStyle(LinearProgressViewStyle(tint: .themePrimary))
                        .background(Color.themeAccent.opacity(0.2))
                        .cornerRadius(4)
                }
                
                // Toggle
                HStack {
                    Text("Theme Preview")
                        .foregroundColor(.themeText)
                    
                    Spacer()
                    
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle(tint: .themePrimary))
                }
            }
            .padding()
            .background(Color.themeCardBackground)
            .cornerRadius(12)
        }
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Typography")
                .font(.headline)
                .foregroundColor(.themeText)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Primary Text")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.themePrimary)
                
                Text("Secondary Text")
                    .font(.headline)
                    .foregroundColor(.themeSecondary)
                
                Text("Regular body text that adapts to the current theme. This demonstrates how text colors change with different themes.")
                    .font(.body)
                    .foregroundColor(.themeText)
                
                Text("Accent text for highlights")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.themeAccent)
                
                Text("Muted text for less important information")
                    .font(.caption)
                    .foregroundColor(.themeText.opacity(0.6))
            }
            .padding()
            .background(Color.themeCardBackground)
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