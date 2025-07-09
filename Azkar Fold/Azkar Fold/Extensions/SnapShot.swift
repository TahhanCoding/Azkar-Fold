//
//  SnapShot.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 08/07/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func snapShot(trigger: Bool, onCompletion: @escaping (UIImage) -> ()) -> some View {
        self
            .modifier(SnapShotModifier(trigger: trigger, onCompletion: onCompletion))
    }
}


fileprivate struct SnapShotModifier: ViewModifier {
    var trigger: Bool
    var onCompletion: (UIImage) -> ()
    
    @State private var view: UIView = .init(frame: .zero)
    
    func body(content: Content) -> some View {
        content
            .background(ViewExtractor(view: view))
            .compositingGroup()
            .onChange(of: trigger) { newValue in
                generateSnapShot()
            }
    }
    
    private func generateSnapShot() {
        if let superView = view.superview?.superview {
            print(superView)
            let renderer = UIGraphicsImageRenderer(size: superView.bounds.size)
            let image = renderer.image { _ in
                superView.drawHierarchy(in: superView.bounds, afterScreenUpdates: true)
            }
            
            onCompletion(image)
        }
    }
}

fileprivate struct ViewExtractor: UIViewRepresentable {
    var view: UIView
    
    func makeUIView(context: Context) -> UIView {
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

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
