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
    @ObservedObject private var settingsStore = SunnahSettingsStore.shared
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var showCompletionAlert: Bool = false
    
    enum ZekrDisplayMode {
        case arabic
        case english
        case transliteration
        case source
        case blessArabic
        case blessEnglish
    }
    @State private var currentDisplayMode: ZekrDisplayMode = .arabic
    
    @State private var reorderedAzkarList: [SunnahZekrItem]? = nil
    @Namespace private var progressBarNamespace
    
    // Modular managers
    @EnvironmentObject var motionManager: CoreMotionManager
    @StateObject private var simpleModeManager: SimpleModeManager
    
    init(azkarList: [SunnahZekrItem], category: SunnahAzkarCategory, progressStore: SunnahProgressStore) {
        self._azkarList = State(initialValue: azkarList)
        self.category = category
        self.progressStore = progressStore
        
        let initialMode = SunnahSettingsStore.shared.initialViewMode == .simple
        self._simpleModeManager = StateObject(wrappedValue: SimpleModeManager(initialMode: initialMode))
    }
    
    // Export states
    @State private var capturedImage: UIImage? = nil
    @State private var showShareSheet: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var saveAlertMessage: String = ""
    @State private var isExporting: Bool = false
    
    // Computed property for displayed azkar list (uses reordered if available)
    var displayedAzkarList: [SunnahZekrItem] {
        return reorderedAzkarList ?? azkarList
    }
    
    var zekrItem: SunnahZekrItem {
        if displayedAzkarList.isEmpty {
            // Fallback to avoid crash, though should not happen given logic
             return azkarList.first! 
        }
        return displayedAzkarList[min(currentIndex, displayedAzkarList.count - 1)]
    }
    
    // Total progress calculation - based on completed azkar items
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
        VStack(spacing: 0) {
            TabView(selection: $currentIndex) {
                ForEach(displayedAzkarList.indices, id: \.self) { index in
                    SunnahZekrPage(
                        zekrItem: displayedAzkarList[index],
                        category: category,
                        index: index,
                        currentIndex: $currentIndex,
                        progressStore: progressStore,
                        settingsStore: settingsStore,
                        displayMode: $currentDisplayMode,
                        theme: theme,
                        patternManager: patternManager,
                        motionManager: motionManager,
                        simpleModeManager: simpleModeManager,
                        enable3DEffects: settingsStore.enable3DEffects,
                        onRequestNext: {
                            autoAdvanceToNextZekr()
                        },
                        onCheckCompletion: {
                            checkIfAllAzkarCompleted()
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 16)
            
            Spacer(minLength: 0)
            
            // Shared controls section
            VStack(spacing: 0) {
                // Total Progress Bar (Always visible as border line)
                totalProgressBar
                    .zIndex(1) // Ensure it stays on top
                
                VStack {
                    if simpleModeManager.isSimpleMode {
                        // Simple mode: Minimal height, only progress bar
                        VStack(spacing: 16) {
                            progressBar
                        }
                        .padding(.top, 16)
                    } else {
                        // Full mode: Standard height, all controls
                        VStack(spacing: 16) {
                            progressBar
                            
                            navigationButtons
                                        
                            contentControls
                        }
                        .padding(.top, 16)
                    }
                }
                .frame(height: simpleModeManager.isSimpleMode ? UIScreen.main.bounds.height * 0.1 : UIScreen.main.bounds.height * 0.27)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(theme.currentTheme.background)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                        .ignoresSafeArea(.container, edges: .bottom)
                )
                .animation(.easeInOut(duration: 0.3), value: simpleModeManager.isSimpleMode)
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
                        // Just set the flag - menu will dismiss automatically
                        isExporting = true
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
            // Reset display mode to Arabic when navigating
            currentDisplayMode = .arabic
        }
        .onChange(of: isExporting) { newValue in
            if newValue {
                // Delay to allow menu to dismiss first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    exportCurrentZekr()
                }
            }
        }
        .onChange(of: settingsStore.enable3DEffects) { newValue in
            if newValue {
                motionManager.startMotionUpdates(
                    sensitivity: 0.5,
                    maxAngle: 0.175,
                    interval: 0.1
                )
            } else {
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
        .overlay {
            if isExporting {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(theme.currentTheme.accent)
                        
                        Text("Preparing...")
                            .font(.subheadline)
                            .foregroundColor(theme.currentTheme.text)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.currentTheme.cardBackground)
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    )
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExporting)
    }
    
    //MARK: - Progress Bar
    private var progressBar: some View {
        // We fetch current repetition from store for the progress bar
        let progress = progressStore.getPartialProgress(zekr: zekrItem, category: category)
        let isCompleted = progressStore.isCompleted(zekr: zekrItem, category: category)
        let currentCount = isCompleted ? zekrItem.repeat : progress
        
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 24)
                
                // Progress fill
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.currentTheme.accent)
                    .frame(
                        width: geometry.size.width * (Double(currentCount) / Double(zekrItem.repeat)),
                        height: 24
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentCount)
                
                // Progress text overlay
                HStack {
                    Spacer()
                    Text("\(currentCount)/\(zekrItem.repeat)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.currentTheme.buttonText)
                    Spacer()
                }
            }
        }
        .frame(height: 24)
        .padding(.horizontal, 16)
        .matchedGeometryEffect(id: "progressBar", in: progressBarNamespace)
        // Note: Tap gesture on progress bar is removed or handled via store updates
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
                contentButton(text: "Arabic", mode: .arabic)
                contentButton(text: "Spelling", mode: .transliteration)
                contentButton(text: "Source", mode: .source)
            }
            
            // Secondary buttons row
            HStack(spacing: 8) {
                let englishLabel = settingsStore.secondaryLanguage == "en" ? "English" : settingsStore.secondaryLanguage.capitalized
                contentButton(text: englishLabel, mode: .english)
                
                if zekrItem.bless != nil {
                    contentButton(text: "Bless_ar", mode: .blessArabic)
                }
                
                if zekrItem.bless_en != nil {
                    contentButton(text: "Bless_en", mode: .blessEnglish)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func contentButton(text: String, mode: ZekrDisplayMode) -> some View {
        Button(action: {
            currentDisplayMode = mode
        }) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(currentDisplayMode == mode ? theme.currentTheme.primary : theme.currentTheme.cardBackground)
                )
                .foregroundColor(currentDisplayMode == mode ? theme.currentTheme.buttonText : theme.currentTheme.text)
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
        // Logic: can go next if not at end AND current zekr is completed
        let isCompleted = progressStore.isCompleted(zekr: zekrItem, category: category)
        return currentIndex < displayedAzkarList.count - 1 && isCompleted
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    //MARK: - Methods
    private func setupView() {
        if let savedOrder = progressStore.loadAzkarOrder(category: category), !savedOrder.isEmpty {
            applySavedOrder(savedOrder)
        }
        
        currentIndex = findFirstIncompleteIndex()
        currentDisplayMode = .arabic
        
        if settingsStore.enable3DEffects {
            motionManager.startMotionUpdates(
                sensitivity: 0.5,
                maxAngle: 0.175,
                interval: 0.1
            )
        }
    }
    
    private func applySavedOrder(_ savedOrder: [String]) {
        var azkarDictById: [String: SunnahZekrItem] = [:]
        var azkarDictByTextId: [String: SunnahZekrItem] = [:]
        
        for zekr in azkarList {
            let idBasedKey = "\(category.rawValue)_\(zekr.id)"
            let textBasedKey = "\(category.rawValue)_\(zekr.zekr)"
            
            azkarDictById[idBasedKey] = zekr
            if azkarDictByTextId[textBasedKey] == nil {
                azkarDictByTextId[textBasedKey] = zekr
            }
        }
        
        var reordered: [SunnahZekrItem] = []
        var usedZekrIds = Set<Int>()
        
        for savedId in savedOrder {
            if let zekr = azkarDictById[savedId] ?? azkarDictByTextId[savedId] {
                if !usedZekrIds.contains(zekr.id) {
                    reordered.append(zekr)
                    usedZekrIds.insert(zekr.id)
                }
            }
        }
        
        for zekr in azkarList {
            if !usedZekrIds.contains(zekr.id) {
                reordered.append(zekr)
            }
        }
        
        reorderedAzkarList = reordered
    }
    
    private func moveCurrentZekrToEnd() {
        guard canMoveToEnd else { return }
        
        // Progress is already saved by Page view when it updates
        
        let currentZekr = displayedAzkarList[currentIndex]
        
        var newList = displayedAzkarList
        newList.remove(at: currentIndex)
        newList.append(currentZekr)
        
        reorderedAzkarList = newList
        
        let orderIds = newList.map { "\(category.rawValue)_\($0.id)" }
        progressStore.saveAzkarOrder(category: category, order: orderIds)
        
        // No need to reset Repetitions here manually as the view for the new zekr at currentIndex will load its own
    }
    
    private func resetAzkarOrder() {
        reorderedAzkarList = nil
        progressStore.resetAzkarOrder(category: category)
        currentIndex = findFirstIncompleteIndex()
    }
    
    private func cleanupView() {
        motionManager.stopMotionUpdates()
        simpleModeManager.cancelAutoAdvance()
        // Last progress save happens in Page view
    }
    
    private func navigateToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
    
    private func navigateToNext() {
        guard canNavigateToNext else { return }
        currentIndex += 1
    }
    
    private func autoAdvanceToNextZekr() {
        if currentIndex < displayedAzkarList.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
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
    
    private func findFirstIncompleteIndex() -> Int {
        for (index, zekr) in displayedAzkarList.enumerated() {
            if !progressStore.isCompleted(zekr: zekr, category: category) {
                return index
            }
        }
        return 0
    }
    
    private func exportCurrentZekr() {
        guard currentIndex < displayedAzkarList.count else {
            isExporting = false
            return
        }
        
        let currentZekr = displayedAzkarList[currentIndex]
        
        // Render the image using ImageRenderer (fast and efficient)
        if let image = renderZekrImage(
            text: currentZekr.zekr,
            theme: theme,
            patternManager: patternManager
        ) {
            capturedImage = image
            isExporting = false
            showShareSheet = true
        } else {
            isExporting = false
        }
    }
}

struct SunnahZekrPage: View {
    let zekrItem: SunnahZekrItem
    let category: SunnahAzkarCategory
    let index: Int
    @Binding var currentIndex: Int
    @ObservedObject var progressStore: SunnahProgressStore
    @ObservedObject var settingsStore: SunnahSettingsStore
    @Binding var displayMode: SunnahZekrView.ZekrDisplayMode
    
    var theme: ThemeManager
    var patternManager: PatternManager
    @ObservedObject var motionManager: CoreMotionManager
    @ObservedObject var simpleModeManager: SimpleModeManager
    var enable3DEffects: Bool
    
    var onRequestNext: () -> Void
    var onCheckCompletion: () -> Void
    
    @State private var currentRepetition: Int = 0
    @State private var textOnScreen: String = ""
    
    var body: some View {
        VStack {
            SunnahZekrTextCard(
                text: textOnScreen,
                isCompleted: currentRepetition >= zekrItem.repeat,
                cardHeightMode: settingsStore.cardHeightMode,
                isSimpleMode: simpleModeManager.isSimpleMode,
                theme: theme,
                patternManager: patternManager,
                onTap: {
                    countUpZekr()
                }
            )
            .addSimpleModeToggle(
                isSimpleMode: simpleModeManager.isSimpleMode,
                longPressDuration: 0.8
            ) {
                simpleModeManager.toggleSimpleMode()
            }
            .modifier(
                enable3DEffects
                ? AnyViewModifier(TiltEffect3D(animationResponse: 0.4, dampingFraction: 0.9))
                : AnyViewModifier(EmptyModifier())
            )
        }
        .onAppear {
            loadProgress()
            updateText()
        }
        .onChange(of: displayMode) { _ in
            updateText()
        }
        .onChange(of: settingsStore.secondaryLanguage) { _ in
            updateText()
        }
    }
    
    // Type-erased wrapper for conditional modifier application
    struct AnyViewModifier: ViewModifier {
        let modifier: any ViewModifier
        
        init(_ modifier: any ViewModifier) {
            self.modifier = modifier
        }
        
        func body(content: Content) -> some View {
            anyBody(content, modifier: modifier)
        }
        
        private func anyBody(_ content: Content, modifier: any ViewModifier) -> some View {
            if let m = modifier as? TiltEffect3D {
                return AnyView(content.modifier(m))
            } else if let m = modifier as? EnhancedTiltEffect3D {
                return AnyView(content.modifier(m))
            } else if let m = modifier as? FloatingCardTiltEffect {
                return AnyView(content.modifier(m))
            } else {
                return AnyView(content)
            }
        }
    }
    
    struct EmptyModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
        }
    }
    
    private func loadProgress() {
        let savedProgress = progressStore.getPartialProgress(zekr: zekrItem, category: category)
        if progressStore.isCompleted(zekr: zekrItem, category: category) {
            currentRepetition = zekrItem.repeat
        } else {
            currentRepetition = savedProgress
        }
    }
    
    private func updateText() {
        switch displayMode {
        case .arabic:
            textOnScreen = zekrItem.zekr
        case .english:
            textOnScreen = zekrItem.en_tr
        case .transliteration:
            textOnScreen = zekrItem.transliteration
        case .source:
            textOnScreen = zekrItem.source
        case .blessArabic:
            textOnScreen = zekrItem.bless ?? ""
        case .blessEnglish:
            textOnScreen = zekrItem.bless_en ?? ""
        }
    }
    
    private func countUpZekr() {
        guard currentRepetition < zekrItem.repeat else { return }
        
        currentRepetition += 1
        progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
        
        if currentRepetition == zekrItem.repeat {
            progressStore.markAsCompleted(zekr: zekrItem, category: category)
            onCheckCompletion()
            
            // Auto advance logic
            if simpleModeManager.isSimpleMode {
                 simpleModeManager.scheduleAutoAdvance {
                     onRequestNext()
                 }
            }
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
    @Published var isSimpleMode: Bool
    @Published var autoAdvanceEnabled: Bool = true
    @Published var autoAdvanceDelay: TimeInterval = 0.5
    
    private var autoAdvanceTimer: Timer?
    
    init(initialMode: Bool = false) {
        self.isSimpleMode = initialMode
    }
    
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
    
    /// Set simple mode directly without animation (for initialization)
    func setSimpleMode(_ enabled: Bool, animated: Bool = false) {
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                isSimpleMode = enabled
            }
        } else {
            isSimpleMode = enabled
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
    
    // Initializer matching the usage in static properties
    init(autoAdvanceEnabled: Bool, autoAdvanceDelay: TimeInterval, longPressMinimumDuration: Double, animationDuration: Double) {
        self.autoAdvanceDelay = autoAdvanceDelay
        self.longPressMinimumDuration = longPressMinimumDuration
        self.animationDuration = animationDuration
    }
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
        
        // Stop any existing updates before starting new ones to avoid conflicts
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else {
                // Silently handle errors - CoreMotion may log system warnings that are harmless
                // Only log actual errors that prevent functionality
                if let error = error as NSError?,
                   error.domain != "NSCocoaErrorDomain" || error.code != 257 {
                    // Only log non-permission errors (257 is the permission error code)
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
