//
//  SnapShot.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 08/07/2025.
//

import SwiftUI

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var completion: UIActivityViewController.CompletionWithItemsHandler?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = completion
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Exportable Zekr Card (Optimized for rendering)
struct ExportableZekrCard: View {
    let text: String
    let theme: ThemeManager
    let patternManager: PatternManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(text)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .minimumScaleFactor(0.4)
                .lineLimit(20)
            
            Spacer()
            
            // Watermark
            Text("azkarfold.com")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.currentTheme.text.opacity(0.6))
                .padding(.bottom, 20)
        }
        .frame(width: 350, height: 500)
        .background(
            ZStack {
                // Solid background
                theme.currentTheme.background
                
                // Pattern overlay
                if patternManager.currentPattern != "none" {
                    Image(patternManager.currentPattern)
                        .resizable(resizingMode: .tile)
                        .opacity(0.35)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Image Renderer Helper
@MainActor
func renderZekrImage(text: String, theme: ThemeManager, patternManager: PatternManager) -> UIImage? {
    let exportView = ExportableZekrCard(
        text: text,
        theme: theme,
        patternManager: patternManager
    )
    
    let renderer = ImageRenderer(content: exportView)
    renderer.scale = UIScreen.main.scale
    
    return renderer.uiImage
}
