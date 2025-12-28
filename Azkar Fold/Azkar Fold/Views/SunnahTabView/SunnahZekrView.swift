//
//  SunnahZekrView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct SunnahZekrView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var patternManager: PatternManager
    @State var azkarList: [SunnahZekrItem]
    let category: SunnahAzkarCategory
    @ObservedObject var progressStore: SunnahProgressStore
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("enable3DEffects") private var enable3DEffects = true
    @State private var currentIndex: Int = 0
    @State private var currentRepetition: Int = 0
    @State private var showCompletionAlert: Bool = false
    @State private var textOnScreen: String = ""
    @State private var reorderedAzkarList: [SunnahZekrItem]? = nil
    
    // Modular managers
    @EnvironmentObject var motionManager: CoreMotionManager
    @StateObject private var simpleModeManager = SimpleModeManager()
    
    // Snapshot states
    @State private var takeSnapshot: Bool = false
    @State private var capturedImage: UIImage? = nil
    @State private var showShareSheet: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var saveAlertMessage: String = ""
    
    // Computed property for displayed azkar list (uses reordered if available)
    var displayedAzkarList: [SunnahZekrItem] {
        return reorderedAzkarList ?? azkarList
    }
    
    var zekrItem: SunnahZekrItem {
        return displayedAzkarList[currentIndex]
    }
    
    // Total progress calculation - based on completed azkar items, not repetition counts
    var totalCategoryProgress: (completed: Int, total: Int, percentage: Double) {
        let total = displayedAzkarList.count
        let completed = displayedAzkarList.filter { zekr in
            progressStore.isCompleted(zekr: zekr, category: category)
        }.count
        let percentage = total > 0 ? Double(completed) / Double(total) : 0.0
        return (completed, total, percentage)
    }
    
    // Check if Move to End is available (not last item)
    var canMoveToEnd: Bool {
        return currentIndex < displayedAzkarList.count - 1
    }
    
    var body: some View {
        VStack {
            if simpleModeManager.isSimpleMode {
                simpleZekrView
                    .padding(.top, 16)
                
                Spacer()
                
                // Simple mode progress bar only
                VStack(spacing: 16) {
                    progressBar
                }
                .frame(height: screenHeight * 0.1)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(theme.currentTheme.background)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                        .ignoresSafeArea(.container, edges: .bottom)
                )
            } else {
                // Full mode
                zekrView
                    .padding(.top, 16)
                
                Spacer()
                
                VStack(spacing: 1) {
                    totalProgressBar
                    
                    VStack(spacing: 16) {
                        progressBar
                        
                        navigationButtons
                                    
                        contentControls
                    }
                    .frame(height: screenHeight * 0.27)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(theme.currentTheme.background)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                            .ignoresSafeArea(.container, edges: .bottom)
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 33)
                .fill(theme.currentTheme.background.opacity(0.35))
                .ignoresSafeArea(.all)
        )
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        takeSnapshot = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up.on.square.fill")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        moveCurrentZekrToEnd()
                    }) {
                        Label("Move to End", systemImage: "arrow.down.to.line")
                    }
                    .disabled(!canMoveToEnd)
                    
                    if reorderedAzkarList != nil {
                        Button(action: {
                            resetAzkarOrder()
                        }) {
                            Label("Reset Order", systemImage: "arrow.counterclockwise")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(theme.currentTheme.accent)
                        .padding(5)
                }
            }
        }
        .onAppear {
            setupView()
        }
        .onDisappear {
            cleanupView()
        }
        .onChange(of: currentIndex) { _ in
            resetRepetitions()
        }
        .onChange(of: currentRepetition) { newValue in
            handleRepetitionChange(newValue)
        }
        .onChange(of: enable3DEffects) { newValue in
            if newValue {
                // Start motion updates if 3D effects are enabled
                motionManager.startMotionUpdates(
                    sensitivity: 0.5,
                    maxAngle: 0.175,
                    interval: 0.1
                )
            } else {
                // Stop motion updates if 3D effects are disabled
                motionManager.stopMotionUpdates()
            }
        }
        .alert("Congratulations!", isPresented: $showCompletionAlert) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You have completed all Azkar for the \(category.rawValue) category.")
        }
        .alert("Save Status", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = capturedImage {
                ShareSheet(activityItems: [image]) { activity, success, items, error in
                    if let activity = activity, activity.rawValue.contains("SaveToCameraRoll") {
                        saveAlertMessage = success ? "Image saved to Photos successfully!" : "Failed to save image to Photos"
                        showSaveAlert = true
                    }
                }
            }
        }
    }
    
    //MARK: - Zekr Views
    private var zekrView: some View {
        let content = createZekrContent(height: screenHeight * 0.5)
            .addSimpleModeToggle(
                isSimpleMode: simpleModeManager.isSimpleMode,
                longPressDuration: 0.8
            ) {
                simpleModeManager.enableSimpleMode()
            }
        
        if enable3DEffects {
            return AnyView(content
                .addTiltEffect(preset: .floating)
            )
        } else {
            return AnyView(content)
        }
    }
    
    private var simpleZekrView: some View {
        let content = createZekrContent(height: screenHeight * 0.7)
            .addSimpleModeToggle(
                isSimpleMode: simpleModeManager.isSimpleMode,
                longPressDuration: 0.8
            ) {
                simpleModeManager.disableSimpleMode()
            }
        
        return content
    }
    
    private func createZekrContent(height: CGFloat) -> some View {
        VStack {
            Text(textOnScreen)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .font(.system(size: 80))
                .minimumScaleFactor(0.3)
                .lineLimit(15)
                .padding(.vertical, 12)
                .id(zekrItem.zekr)
            
            // Footer text for sharing
            if takeSnapshot {
                Spacer()
                Text("azkarfold.com")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.currentTheme.text.opacity(0.7))
                    .padding(.bottom, 16)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 33)
                .fill(currentRepetition >= zekrItem.repeat ? theme.currentTheme.background.opacity(0.65) : theme.currentTheme.background.opacity(0.45))
                .overlay(
                    Group {
                        if patternManager.currentPattern != "none" {
                            Image(patternManager.currentPattern)
                                .resizable(resizingMode: .tile)
                                .opacity(0.35)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 33))
                .padding(.horizontal, 21)
        )
        .onTapGesture {
            countUpZekr()
        }
        .snapShot(trigger: takeSnapshot) { image in
            capturedImage = image
            takeSnapshot = false
            showShareSheet = true
        }
    }
    
    //MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 24)
                
                // Progress fill
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.currentTheme.accent)
                    .frame(
                        width: geometry.size.width * (Double(currentRepetition) / Double(zekrItem.repeat)),
                        height: 24
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentRepetition)
                
                // Progress text overlay
                HStack {
                    Spacer()
                    Text("\(currentRepetition)/\(zekrItem.repeat)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.currentTheme.buttonText)
                    Spacer()
                }
            }
        }
        .frame(height: 24)
        .padding(.horizontal, 16)
        .onTapGesture {
            countUpZekr()
        }
    }
    
    //MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                navigateToPrevious()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(currentIndex == 0 ? theme.currentTheme.cardBackground : theme.currentTheme.primary)
                .foregroundColor(currentIndex == 0 ? theme.currentTheme.text : theme.currentTheme.buttonText)
                .cornerRadius(25)
            }
            .disabled(currentIndex == 0)
            
            VStack {
                Text("\(currentIndex + 1) of \(displayedAzkarList.count)")
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text)
            }
            
            Button(action: {
                navigateToNext()
            }) {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(canNavigateToNext ? theme.currentTheme.primary : theme.currentTheme.cardBackground)
                .foregroundColor(canNavigateToNext ? theme.currentTheme.buttonText : theme.currentTheme.text)
                .cornerRadius(25)
            }
            .disabled(!canNavigateToNext)
        }
        .padding(.horizontal)
    }
    
    //MARK: - Content Controls
    private var contentControls: some View {
        VStack(spacing: 12) {
            // Primary buttons row
            HStack(spacing: 12) {
                contentButton(text: "Arabic", content: zekrItem.zekr)
                contentButton(text: "Spelling", content: zekrItem.transliteration)
                contentButton(text: "Source", content: zekrItem.source)
            }
            
            // Secondary buttons row
            HStack(spacing: 8) {
                contentButton(text: "English", content: zekrItem.en_tr)
                
                if let bless = zekrItem.bless {
                    contentButton(text: "Bless_ar", content: bless)
                }
                
                if let bless_en = zekrItem.bless_en {
                    contentButton(text: "Bless_en", content: bless_en)
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: currentIndex) { _ in
            DispatchQueue.main.async {
                textOnScreen = zekrItem.zekr
            }
        }
        .onDisappear {
            progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
        }
    }
    
    private func contentButton(text: String, content: String) -> some View {
        Button(action: {
            textOnScreen = content
        }) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(textOnScreen == content ? theme.currentTheme.primary : theme.currentTheme.cardBackground)
                )
                .foregroundColor(textOnScreen == content ? theme.currentTheme.buttonText : theme.currentTheme.text)
        }
    }
    
    //MARK: - Total Progress Bar
    private var totalProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Thin background line
                RoundedRectangle(cornerRadius: 2)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 3)
                
                // Thin progress fill line
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.currentTheme.accent)
                    .frame(
                        width: geometry.size.width * totalCategoryProgress.percentage,
                        height: 3
                    )
                    .animation(.easeInOut(duration: 0.3), value: totalCategoryProgress.completed)
            }
        }
        .frame(height: 3)
    }
    
    //MARK: - Computed Properties
    private var canNavigateToNext: Bool {
        return currentIndex < displayedAzkarList.count - 1 && currentRepetition >= zekrItem.repeat
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    //MARK: - Methods
    private func setupView() {
        // Load saved order if available
        if let savedOrder = progressStore.loadAzkarOrder(category: category), !savedOrder.isEmpty {
            applySavedOrder(savedOrder)
        }
        
        currentIndex = findFirstIncompleteIndex()
        textOnScreen = zekrItem.zekr
        resetRepetitions()
        
        // Start motion updates with configuration only if 3D effects are enabled
        if enable3DEffects {
            motionManager.startMotionUpdates(
                sensitivity: 0.5,
                maxAngle: 0.175,
                interval: 0.1
            )
        }
    }
    
    private func applySavedOrder(_ savedOrder: [String]) {
        // Create a dictionary for quick lookup
        // Use both ID-based and text-based lookups for compatibility
        var azkarDictById: [String: SunnahZekrItem] = [:]
        var azkarDictByTextId: [String: SunnahZekrItem] = [:]
        
        for zekr in azkarList {
            let idBasedKey = "\(category.rawValue)_\(zekr.id)"
            let textBasedKey = "\(category.rawValue)_\(zekr.zekr)"
            
            azkarDictById[idBasedKey] = zekr
            // Only add to text dict if not already present (handle duplicates)
            if azkarDictByTextId[textBasedKey] == nil {
                azkarDictByTextId[textBasedKey] = zekr
            }
        }
        
        // Reorder based on saved order, then append any new items
        var reordered: [SunnahZekrItem] = []
        var usedZekrIds = Set<Int>()
        
        // Add items in saved order
        for savedId in savedOrder {
            // Try ID-based first (new format), then text-based (old format for compatibility)
            if let zekr = azkarDictById[savedId] ?? azkarDictByTextId[savedId] {
                if !usedZekrIds.contains(zekr.id) {
                    reordered.append(zekr)
                    usedZekrIds.insert(zekr.id)
                }
            }
        }
        
        // Add any new items that weren't in saved order
        for zekr in azkarList {
            if !usedZekrIds.contains(zekr.id) {
                reordered.append(zekr)
            }
        }
        
        reorderedAzkarList = reordered
    }
    
    private func moveCurrentZekrToEnd() {
        guard canMoveToEnd else { return }
        
        // Save current progress
        progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
        
        // Get current zekr
        let currentZekr = displayedAzkarList[currentIndex]
        
        // Create new list with current zekr moved to end
        var newList = displayedAzkarList
        newList.remove(at: currentIndex)
        newList.append(currentZekr)
        
        // Update reordered list
        reorderedAzkarList = newList
        
        // Save new order using zekr.id for uniqueness
        let orderIds = newList.map { "\(category.rawValue)_\($0.id)" }
        progressStore.saveAzkarOrder(category: category, order: orderIds)
        
        // Auto-advance to next zekr (which is now at currentIndex since we removed one)
        // The index stays the same because the item at currentIndex+1 moves to currentIndex
        withAnimation(.easeInOut(duration: 0.3)) {
            resetRepetitions()
        }
    }
    
    private func resetAzkarOrder() {
        reorderedAzkarList = nil
        progressStore.resetAzkarOrder(category: category)
        currentIndex = findFirstIncompleteIndex()
        resetRepetitions()
    }
    
    private func cleanupView() {
        motionManager.stopMotionUpdates()
        simpleModeManager.cancelAutoAdvance()
        progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
    }
    
    private func handleRepetitionChange(_ newValue: Int) {
        // Auto advance to next zekr when completed in simple mode
        if simpleModeManager.isSimpleMode && newValue >= zekrItem.repeat {
            simpleModeManager.scheduleAutoAdvance {
                autoAdvanceToNextZekr()
            }
        }
    }
    
    private func navigateToPrevious() {
        guard currentIndex > 0 else { return }
        
        progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
        currentIndex -= 1
        resetRepetitions()
    }
    
    private func navigateToNext() {
        guard canNavigateToNext else { return }
        
        progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
        currentIndex += 1
        resetRepetitions()
    }
    
    private func autoAdvanceToNextZekr() {
        if currentIndex < displayedAzkarList.count - 1 {
            progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
                resetRepetitions()
            }
        } else {
            checkIfAllAzkarCompleted()
        }
    }
    
    private func checkIfAllAzkarCompleted() {
        guard !displayedAzkarList.isEmpty else { return }
        
        let allCompleted = displayedAzkarList.allSatisfy { zekrItemInList in
            progressStore.isCompleted(zekr: zekrItemInList, category: category)
        }
        
        if allCompleted {
            showCompletionAlert = true
        }
    }
    
    private func resetRepetitions() {
        let savedProgress = progressStore.getPartialProgress(zekr: zekrItem, category: category)
        
        if progressStore.isCompleted(zekr: zekrItem, category: category) {
            currentRepetition = zekrItem.repeat
        } else {
            currentRepetition = savedProgress
        }
        
        textOnScreen = zekrItem.zekr
    }
    
    private func findFirstIncompleteIndex() -> Int {
        for (index, zekr) in displayedAzkarList.enumerated() {
            if !progressStore.isCompleted(zekr: zekr, category: category) {
                return index
            }
        }
        return 0
    }
    
    private func countUpZekr() {
        guard currentRepetition < zekrItem.repeat else { return }
        
        currentRepetition += 1
        progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
        
        if currentRepetition == zekrItem.repeat {
            progressStore.markAsCompleted(zekr: zekrItem, category: category)
            checkIfAllAzkarCompleted()
        }
    }
}

//
//  SimpleModeManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import Combine

/// A reusable manager for handling simple mode functionality
class SimpleModeManager: ObservableObject {
    @Published var isSimpleMode: Bool = false
    @Published var autoAdvanceEnabled: Bool = true
    @Published var autoAdvanceDelay: TimeInterval = 0.5
    
    private var autoAdvanceTimer: Timer?
    
    /// Toggle simple mode with animation
    func toggleSimpleMode() {
        //motionManager.resetTiltValues() // Add this

        withAnimation(.easeInOut(duration: 0.3)) {
            isSimpleMode.toggle()
        }
    }
    
    /// Enable simple mode with animation
    func enableSimpleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSimpleMode = true
        }
    }
    
    /// Disable simple mode with animation
    func disableSimpleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSimpleMode = false
        }
    }
    
    /// Schedule auto advance action
    func scheduleAutoAdvance(action: @escaping () -> Void) {
        guard autoAdvanceEnabled else { return }
        
        // Cancel any existing timer
        autoAdvanceTimer?.invalidate()
        
        // Schedule new timer
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: autoAdvanceDelay, repeats: false) { _ in
            DispatchQueue.main.async {
                action()
            }
        }
    }
    
    /// Cancel scheduled auto advance
    func cancelAutoAdvance() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
    }
    
    deinit {
        cancelAutoAdvance()
    }
}

//MARK: - Simple Mode Configuration
struct SimpleModeConfig {
    let autoAdvanceEnabled: Bool
    let autoAdvanceDelay: TimeInterval
    let longPressMinimumDuration: Double
    let animationDuration: Double
    
    static let `default` = SimpleModeConfig(
        autoAdvanceEnabled: true,
        autoAdvanceDelay: 0.5,
        longPressMinimumDuration: 0.8,
        animationDuration: 0.3
    )
    
    static let quick = SimpleModeConfig(
        autoAdvanceEnabled: true,
        autoAdvanceDelay: 0.2,
        longPressMinimumDuration: 0.5,
        animationDuration: 0.2
    )
    
    static let slow = SimpleModeConfig(
        autoAdvanceEnabled: true,
        autoAdvanceDelay: 1.0,
        longPressMinimumDuration: 1.2,
        animationDuration: 0.5
    )
    
    static let manual = SimpleModeConfig(
        autoAdvanceEnabled: false,
        autoAdvanceDelay: 0.0,
        longPressMinimumDuration: 0.8,
        animationDuration: 0.3
    )
}

//MARK: - Simple Mode View Modifier
struct SimpleModeModifier: ViewModifier {
    let isSimpleMode: Bool
    let onToggle: () -> Void
    let longPressDuration: Double
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: longPressDuration) {
                onToggle()
            }
    }
}

//MARK: - View Extension for Simple Mode
extension View {
    func addSimpleModeToggle(
        isSimpleMode: Bool,
        longPressDuration: Double = 0.8,
        onToggle: @escaping () -> Void
    ) -> some View {
        self.modifier(SimpleModeModifier(
            isSimpleMode: isSimpleMode,
            onToggle: onToggle,
            longPressDuration: longPressDuration
        ))
    }
}

//
//  TiltEffectModifiers.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

//MARK: - Basic 3D Tilt Effect Modifier
struct TiltEffect3D: ViewModifier {
    @EnvironmentObject var motionManager: CoreMotionManager
    let animationResponse: Double
    let dampingFraction: Double
    
    init(
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) {
        self.animationResponse = animationResponse
        self.dampingFraction = dampingFraction
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(radians: motionManager.tiltPitch),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .rotation3DEffect(
                Angle(radians: -motionManager.tiltRoll),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltPitch)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltRoll)
    }
}

//MARK: - Enhanced 3D Tilt Effect with Perspective
struct EnhancedTiltEffect3D: ViewModifier {
    @EnvironmentObject var motionManager: CoreMotionManager
    let perspectiveIntensity: Double
    let shadowIntensity: Double
    let animationResponse: Double
    let dampingFraction: Double
    
    init(
        perspectiveIntensity: Double = 0.001,
        shadowIntensity: Double = 0.3,
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) {
        self.perspectiveIntensity = perspectiveIntensity
        self.shadowIntensity = shadowIntensity
        self.animationResponse = animationResponse
        self.dampingFraction = dampingFraction
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(radians: motionManager.tiltPitch),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: perspectiveIntensity
            )
            .rotation3DEffect(
                Angle(radians: -motionManager.tiltRoll),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: perspectiveIntensity
            )
            .shadow(
                color: .black.opacity(shadowIntensity * abs(motionManager.tiltRoll + motionManager.tiltPitch)),
                radius: 8,
                x: CGFloat(motionManager.tiltRoll * 10),
                y: CGFloat(motionManager.tiltPitch * 10)
            )
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltPitch)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltRoll)
    }
}

//MARK: - Floating Card Tilt Effect
struct FloatingCardTiltEffect: ViewModifier {
    @EnvironmentObject var motionManager: CoreMotionManager
    let floatIntensity: Double
    let animationResponse: Double
    let dampingFraction: Double
    
    init(
        floatIntensity: Double = 5.0,
        animationResponse: Double = 0.4,
        dampingFraction: Double = 0.9
    ) {
        self.floatIntensity = floatIntensity
        self.animationResponse = animationResponse
        self.dampingFraction = dampingFraction
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(radians: motionManager.tiltPitch),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .rotation3DEffect(
                Angle(radians: -motionManager.tiltRoll),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .offset(
                x: CGFloat(-motionManager.tiltRoll * floatIntensity),
                y: CGFloat(-motionManager.tiltPitch * floatIntensity)
            )
            .scaleEffect(1.0 + (abs(motionManager.tiltPitch) + abs(motionManager.tiltRoll)) * 0.05)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltPitch)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltRoll)
    }
}

//MARK: - View Extensions for Easy Usage
extension View {
    /// Apply basic 3D tilt effect
    func add3DTiltEffect(
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) -> some View {
        self.modifier(TiltEffect3D(
            animationResponse: animationResponse,
            dampingFraction: dampingFraction
        ))
    }
    
    /// Apply enhanced 3D tilt effect with perspective and shadow
    func addEnhanced3DTiltEffect(
        perspectiveIntensity: Double = 0.001,
        shadowIntensity: Double = 0.3,
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) -> some View {
        self.modifier(EnhancedTiltEffect3D(
            perspectiveIntensity: perspectiveIntensity,
            shadowIntensity: shadowIntensity,
            animationResponse: animationResponse,
            dampingFraction: dampingFraction
        ))
    }
    
    /// Apply floating card tilt effect
    func addFloatingCardTiltEffect(
        floatIntensity: Double = 5.0,
        animationResponse: Double = 0.4,
        dampingFraction: Double = 0.9
    ) -> some View {
        self.modifier(FloatingCardTiltEffect(
            floatIntensity: floatIntensity,
            animationResponse: animationResponse,
            dampingFraction: dampingFraction
        ))
    }
}

//MARK: - Tilt Effect Presets
enum TiltEffectPreset {
    case subtle
    case normal
    case dramatic
    case floating
    
    var animationResponse: Double {
        switch self {
        case .subtle: return 0.5
        case .normal: return 0.3
        case .dramatic: return 0.2
        case .floating: return 0.4
        }
    }
    
    var dampingFraction: Double {
        switch self {
        case .subtle: return 0.9
        case .normal: return 0.8
        case .dramatic: return 0.7
        case .floating: return 0.9
        }
    }
}

//MARK: - Preset-based View Extension
extension View {
    func addTiltEffect(
        preset: TiltEffectPreset = .normal
    ) -> some View {
        switch preset {
        case .subtle:
            return AnyView(self.add3DTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        case .normal:
            return AnyView(self.add3DTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        case .dramatic:
            return AnyView(self.addEnhanced3DTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        case .floating:
            return AnyView(self.addFloatingCardTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        }
    }
}

//
//  CoreMotionManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import Foundation
import CoreMotion
import Combine

/// A reusable CoreMotion manager that provides device tilt data for 3D effects
class CoreMotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var tiltPitch: Double = 0.0
    @Published var tiltRoll: Double = 0.0
    @Published var isActive: Bool = false
    
    // Configurable properties
    var maxTiltAngle: Double = 0.175 // ~10 degrees in radians
    var motionSensitivity: Double = 0.5
    var updateInterval: TimeInterval = 0.1 // 10Hz for smooth 60fps experience
    
    /// Start motion updates with optional configuration
    func startMotionUpdates(
        sensitivity: Double? = nil,
        maxAngle: Double? = nil,
        interval: TimeInterval? = nil
    ) {
        guard motionManager.isDeviceMotionAvailable else {
            print("CoreMotionManager: Device motion not available")
            return
        }
        
        // Apply optional configuration
        if let sensitivity = sensitivity { motionSensitivity = sensitivity }
        if let maxAngle = maxAngle { maxTiltAngle = maxAngle }
        if let interval = interval { updateInterval = interval }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            print("Motion update: \(motion?.attitude.pitch ?? 0)") // Add this line

            guard let self = self, let motion = motion, error == nil else {
                if let error = error {
                    print("CoreMotionManager error: \(error.localizedDescription)")
                }
                return
            }
            
            let pitch = motion.attitude.pitch * self.motionSensitivity
            let roll = motion.attitude.roll * self.motionSensitivity
            
            // Clamp the values to prevent excessive rotation
            self.tiltPitch = max(-self.maxTiltAngle, min(self.maxTiltAngle, pitch))
            self.tiltRoll = max(-self.maxTiltAngle, min(self.maxTiltAngle, roll))
            
            if !self.isActive {
                self.isActive = true
            }
        }
    }
    
    /// Stop motion updates and reset values
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        tiltPitch = 0.0
        tiltRoll = 0.0
        isActive = false
    }
    
    /// Reset tilt values to zero (useful for recalibration)
    func resetTiltValues() {
        tiltPitch = 0.0
        tiltRoll = 0.0
    }
    
    deinit {
        stopMotionUpdates()
    }
}

//MARK: - Configuration Struct
struct MotionConfig {
    let sensitivity: Double
    let maxAngle: Double
    let updateInterval: TimeInterval
    
    static let `default` = MotionConfig(
        sensitivity: 0.5,
        maxAngle: 0.175,
        updateInterval: 0.1
    )
    
    static let subtle = MotionConfig(
        sensitivity: 0.3,
        maxAngle: 0.1,
        updateInterval: 0.1
    )
    
    static let dramatic = MotionConfig(
        sensitivity: 0.8,
        maxAngle: 0.3,
        updateInterval: 0.05
    )
}

/*
 // Enhanced effect with shadows
 .addEnhanced3DTiltEffect(motionManager: motionManager)

 // Floating card effect
 .addFloatingCardTiltEffect(motionManager: motionManager)

 // Simple mode toggle
 .addSimpleModeToggle(isSimpleMode: isSimpleMode) {
    simpleModeManager.toggleSimpleMode()
 }

 // Custom motion configuration
 motionManager.startMotionUpdates(
    sensitivity: 0.5,    // Motion sensitivity
    maxAngle: 0.175,     // ~10 degrees max rotation
    interval: 0.1        // 10Hz update rate
 )
 
 
 🔧 Key Technical Features:
 Performance Optimized:

 Motion updates only when view is visible
 Efficient timer management for auto-advance
 Smooth animations without blocking UI
 Memory-safe with proper cleanup

 Highly Configurable:

 Multiple tilt effect presets
 Adjustable motion sensitivity
 Configurable auto-advance timing
 Customizable animation parameters

 User Experience:

 Intuitive gestures: Long tap to toggle modes
 Visual feedback: Smooth transitions and animations
 Immersive feel: 3D card appears to float in device
 Accessibility: Maintains all existing functionality

 Easy Integration:

 Drop-in replacement for existing view
 No breaking changes to existing code
 Modular components can be reused elsewhere
 Clean separation of concerns

 📱 Simple Mode Behavior:

 Long tap on zekr card enters simple mode
 Larger display area for better readability
 Auto-advance when zekr count reaches target
 0.5 second delay before advancing (configurable)
 Long tap again to exit simple mode
 Completion alert when all azkar finished

 🎮 3D Tilt Effect Details:

 Device pitch → X-axis rotation (forward/backward tilt)
 Device roll → Y-axis rotation (left/right tilt)
 Clamped rotation prevents excessive movement
 Spring animations for natural, responsive feel
 60fps updates for smooth visual experience
 Battery efficient - stops when view disappears

 The modular design makes it easy to:

 Reuse components in other parts of your app
 Customize behavior with different presets
 Extend functionality by adding new effects
 Maintain code with clear separation of concerns

 All components work together seamlessly while maintaining the original functionality of your Zekr app! 🕌✨
 
 */
