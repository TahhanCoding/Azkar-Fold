//
//  SunnahZekrView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import UIKit
import Combine

struct SunnahZekrView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    @State var azkarList: [SunnahZekrItem]
    let category: SunnahAzkarCategory
    @ObservedObject var progressStore: SunnahProgressStore
    @ObservedObject private var settingsStore = SunnahSettingsStore.shared
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var showCompletionAlert: Bool = false
    
    enum ZekrDisplayMode {
        case arabic
        case translation // previously english, now general translation
        case sourceArabic
        case sourceTranslated
        case blessArabic
        case blessTranslated
    }
    @State private var currentDisplayMode: ZekrDisplayMode = .arabic
    
    @State private var reorderedAzkarList: [SunnahZekrItem]? = nil
    @State private var listVersion: UUID = UUID()
    @Namespace private var progressBarNamespace
    
    // Modular managers
    @EnvironmentObject var motionManager: CoreMotionManager
    @StateObject private var simpleModeManager: SimpleModeManager
    
    init(azkarList: [SunnahZekrItem], category: SunnahAzkarCategory, progressStore: SunnahProgressStore) {
        self._azkarList = State(initialValue: azkarList)
        self.category = category
        self.progressStore = progressStore

        AzkarDebugLog.log("SunnahZekrView init category=\(category.rawValue) azkarList.count=\(azkarList.count)")

        let initialMode = SunnahSettingsStore.shared.initialViewMode == .simple
        self._simpleModeManager = StateObject(wrappedValue: SimpleModeManager(initialMode: initialMode))
    }
    
    @State private var showSaveAlert: Bool = false
    @State private var saveAlertMessage: String = ""
    @State private var isExporting: Bool = false
    @AppStorage("hasSeenSunnahModeHint") private var hasSeenSunnahModeHint = false
    @State private var showModeHint = false
    
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
        ZStack {
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
            .id("\(listVersion.uuidString)_\(displayedAzkarList.count)")
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

            if showModeHint {
                TimedCoachMarkView(
                    titleKey: "hint.mode.title",
                    messageKey: "hint.mode.message",
                    isPresented: $showModeHint
                )
            }
        }
        .navigationTitle(category.localizedTitle(using: appLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: requestShareCurrentZekr) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(theme.currentTheme.accent)
                }
                .accessibilityLabel(appLanguage.text("common.share"))
                .disabled(isExporting)
            }
        }
        .onAppear {
            setupView()
            if !hasSeenSunnahModeHint {
                showModeHint = true
                hasSeenSunnahModeHint = true
            }
        }
        .onDisappear {
            cleanupView()
        }
        .onChange(of: currentIndex) { _ in
            // Reset display mode to Arabic when navigating
            currentDisplayMode = .arabic
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
        .alert(appLanguage.text("sunnah.congratulations"), isPresented: $showCompletionAlert) {
            Button(appLanguage.text("common.ok"), role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(appLanguage.text("sunnah.completed_category", category.localizedTitle(using: appLanguage)))
        }
        .alert(appLanguage.text("common.share"), isPresented: $showSaveAlert) {
            Button(appLanguage.text("common.ok"), role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
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
                        
                        Text(appLanguage.text("common.preparing"))
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
                    Image(systemName: NavigationSymbol.backwardChevron)
                    Text(appLanguage.text("sunnah.previous"))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(currentIndex == 0 ? theme.currentTheme.cardBackground : theme.currentTheme.primary)
                .foregroundColor(currentIndex == 0 ? theme.currentTheme.text : theme.currentTheme.buttonText)
                .cornerRadius(25)
            }
            .disabled(currentIndex == 0)
            
            VStack {
                Text(appLanguage.text("sunnah.progress_of", currentIndex + 1, displayedAzkarList.count))
                .font(.caption)
                .foregroundColor(theme.currentTheme.text)
            }
            
            Button(action: {
                navigateToNext()
            }) {
                HStack {
                    Text(appLanguage.text("sunnah.next"))
                    Image(systemName: NavigationSymbol.forwardChevron)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(canNavigateToNext ? theme.currentTheme.primary : theme.currentTheme.cardBackground)
                .foregroundColor(canNavigateToNext ? theme.currentTheme.buttonText : theme.currentTheme.text)
                .cornerRadius(25)
            }
            .disabled(!canNavigateToNext)
        }
        .environment(\.layoutDirection, .leftToRight)
        .padding(.horizontal)
    }
    
    //MARK: - Content Controls
    private var contentControls: some View {
        let isArabicOnly = settingsStore.secondaryLanguage == "ar_only" || settingsStore.secondaryLanguage == "ar"
        
        return Group {
            if isArabicOnly {
                // Arabic Only Layout: 3 Buttons
                HStack(spacing: 12) {
                    contentButton(textKey: "sunnah.arabic", mode: .arabic)
                    contentButton(textKey: "sunnah.source", mode: .sourceArabic)
                    if zekrItem.bless != nil {
                        contentButton(textKey: "sunnah.bless", mode: .blessArabic)
                    }
                }
            } else {
                // Multi-Language Layout: Flexible Wrapping
                // Expected: Arabic, [Language], Source, Source_[Lang], Bless, Bless_[Lang]
                // Using LazyVGrid for flexible layout
                let columns = [GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 8)]
                
                LazyVGrid(columns: columns, spacing: 8) {
                    // 1. Arabic (Always present)
                    contentButton(textKey: "sunnah.arabic", mode: .arabic)
                    
                    let langCode = settingsStore.secondaryLanguage
                    let langName = appLanguage.locale.localizedString(forLanguageCode: langCode)?.capitalized ?? langCode.uppercased()
                    contentButton(text: langName, mode: .translation)
                    
                    contentButton(textKey: "sunnah.source", mode: .sourceArabic)
                    
                    // 4. Source (Translated) - Source_[Lang]
                    // e.g. "Source_En"
                    contentButton(text: appLanguage.text("sunnah.source_lang", langCode.uppercased()), mode: .sourceTranslated)
                    
                    // 5. Bless (Arabic)
                    if zekrItem.bless != nil {
                        contentButton(textKey: "sunnah.bless", mode: .blessArabic)
                    }
                    
                    // 6. Bless (Translated) - Bless_[Lang]
                    if zekrItem.translatedBless != nil {
                        contentButton(text: appLanguage.text("sunnah.bless_lang", langCode.uppercased()), mode: .blessTranslated)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func contentButton(textKey: String.LocalizationValue, mode: ZekrDisplayMode) -> some View {
        contentButton(text: appLanguage.text(textKey), mode: mode)
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
        AzkarDebugLog.log("SunnahZekrView setupView category=\(category.rawValue) azkarList=\(azkarList.count) displayed=\(displayedAzkarList.count) currentIndex will resolve after order")
        if let savedOrder = progressStore.loadAzkarOrder(category: category), !savedOrder.isEmpty {
            AzkarDebugLog.log("SunnahZekrView setupView applying savedOrder count=\(savedOrder.count)")
            applySavedOrder(savedOrder)
        }

        currentIndex = findFirstIncompleteIndex()
        currentDisplayMode = .arabic
        AzkarDebugLog.log("SunnahZekrView setupView currentIndex=\(currentIndex) firstZekrPreview=\(displayedAzkarList.prefix(1).first?.zekr.prefix(40) ?? "empty")")

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
        
        let orderIds = newList.map { "\(category.rawValue)_\($0.id)" }
        progressStore.saveAzkarOrder(category: category, order: orderIds)
        
        // Slide to next zekr with animation
        // Since we removed the item at currentIndex, the next item is now at currentIndex
        // We update listVersion to force TabView to recreate, which will show the next item
        // Using a spring animation for a smooth slide effect
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            reorderedAzkarList = newList
            listVersion = UUID() // Force TabView to recreate and animate
        }
        
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
    
    private func requestShareCurrentZekr() {
        guard !isExporting else { return }
        isExporting = true

        Task { @MainActor in
            guard currentIndex < displayedAzkarList.count else {
                isExporting = false
                return
            }

            let currentZekr = displayedAzkarList[currentIndex]
            let isCompleted = progressStore.isCompleted(zekr: currentZekr, category: category)
                || progressStore.getPartialProgress(zekr: currentZekr, category: category) >= currentZekr.repeat

            let text = shareText(for: currentZekr)
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                isExporting = false
                saveAlertMessage = appLanguage.text("sunnah.share_nothing")
                showSaveAlert = true
                return
            }

            guard let shareURL = renderZekrShareURL(
                text: text,
                isCompleted: isCompleted,
                isSimpleMode: simpleModeManager.isSimpleMode,
                theme: theme,
                patternManager: patternManager
            ) else {
                isExporting = false
                saveAlertMessage = appLanguage.text("sunnah.share_failed")
                showSaveAlert = true
                return
            }

            isExporting = false
            FirebaseTelemetry.logEvent(FirebaseTelemetry.Event.shareZekr)
            presentShareSheet(activityItems: [shareURL]) { activity, success, _, _ in
                Task { @MainActor in
                    guard activity == .saveToCameraRoll else { return }
                    saveAlertMessage = success
                        ? appLanguage.text("sunnah.share_saved")
                        : appLanguage.text("sunnah.share_save_failed")
                    showSaveAlert = true
                }
            }
        }
    }

    private func shareText(for zekr: SunnahZekrItem) -> String {
        switch currentDisplayMode {
        case .arabic:
            return zekr.zekr
        case .translation:
            return zekr.translatedZekr ?? zekr.zekr
        case .sourceArabic:
            return zekr.source
        case .sourceTranslated:
            return zekr.translatedSource ?? zekr.source
        case .blessArabic:
            return zekr.bless ?? ""
        case .blessTranslated:
            return zekr.translatedBless ?? zekr.bless ?? ""
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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                SunnahZekrTextCard(
                    text: textOnScreen,
                    isCompleted: currentRepetition >= zekrItem.repeat,
                    isSimpleMode: simpleModeManager.isSimpleMode,
                    availableHeight: geometry.size.height,
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

                Spacer(minLength: 0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
        case .translation:
            textOnScreen = zekrItem.translatedZekr ?? zekrItem.zekr // Fallback to Arabic if translation missing
        case .sourceArabic:
            textOnScreen = zekrItem.source
        case .sourceTranslated:
            textOnScreen = zekrItem.translatedSource ?? zekrItem.source // Fallback to Arabic Source
        case .blessArabic:
            textOnScreen = zekrItem.bless ?? ""
        case .blessTranslated:
            textOnScreen = zekrItem.translatedBless ?? zekrItem.bless ?? ""
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
