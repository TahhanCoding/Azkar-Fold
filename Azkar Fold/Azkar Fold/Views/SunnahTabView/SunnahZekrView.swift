import SwiftUI

struct SunnahZekrView: View {
    @EnvironmentObject var theme: ThemeManager
    @State var azkarList: [SunnahZekrItem]
    let category: SunnahAzkarCategory
    @ObservedObject var progressStore: SunnahProgressStore

    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var currentRepetition: Int = 0
    @State private var showCompletionAlert: Bool = false
    @State private var textOnScreen: String = ""
    
    var zekrItem: SunnahZekrItem {
        return azkarList[currentIndex]
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                    // Upper half - Zekr text
                    VStack(spacing: 16) {
                            VStack(spacing: 12) {
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
                                
                                HStack {
                                    Text("مسلم(١)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(theme.currentTheme.text)
                                        .padding(.horizontal, 18)

                                    
                                    
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                    }
                    .frame(height: geometry.size.height * 0.6)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 33)
                            .fill(currentRepetition >= zekrItem.repeat ? theme.currentTheme.primary.opacity(0.2) : theme.currentTheme.primary.opacity(0.1))
                            .overlay(
                                Image("islamic_pattern")
                                    .resizable(resizingMode: .tile)
                                    .opacity(0.35)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 33))
                            .padding(.horizontal, 21)
                            .padding(.vertical, 21)
                    )
                    .onTapGesture {
                        countUpZekr()
                    }

                    // Lower half - Counter and controls
                    VStack(spacing: 16) {
                        // Counter display
                        VStack(spacing: 12) {
                            // Progress bar
                            VStack(spacing: 8) {
                                // Progress bar background and fill
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(theme.currentTheme.background.opacity(0.2))
                                            .frame(height: 24)
                                        
                                        // Progress fill
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [theme.currentTheme.accent, theme.currentTheme.accent.opacity(0.8)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
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
                            
                            // Status text and zekr count
                            VStack(spacing: 4) {
                                Text("Zekr \(currentIndex + 1) of \(azkarList.count)")
                                    .font(.caption)
                                    .foregroundColor(theme.currentTheme.text)
                            }
                            .onTapGesture {
                                countUpZekr()
                            }

                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())

                        // Navigation controls
                        HStack(spacing: 20) {
                            Button(action: {
                                if currentIndex > 0 {
                                    // Save current progress before moving
                                    progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
                                    currentIndex -= 1
                                    resetRepetitions()
                                }
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
                                Text("\(currentIndex + 1) of \(azkarList.count)")
                                    .font(.caption)
                                    .foregroundColor(theme.currentTheme.text)
                            }
                            
                            Button(action: {
                                if currentIndex < azkarList.count - 1 {
                                    // Save current progress before moving
                                    progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
                                    currentIndex += 1
                                    resetRepetitions()
                                }
                            }) {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background((currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat) ? theme.currentTheme.cardBackground : theme.currentTheme.primary)
                                .foregroundColor((currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat) ? theme.currentTheme.text : theme.currentTheme.buttonText)
                                .cornerRadius(25)
                            }
                            .disabled(currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                        // Text switching controls
                        VStack(spacing: 12) {
                            // Primary buttons (Arabic and English)
                            HStack(spacing: 12) {
                                Button(action: {
                                    textOnScreen = zekrItem.zekr
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "textformat.arabic")
                                        Text("Arabic")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(textOnScreen == zekrItem.zekr ? theme.currentTheme.primary : theme.currentTheme.cardBackground)
                                    )
                                    .foregroundColor(textOnScreen == zekrItem.zekr ? theme.currentTheme.buttonText : theme.currentTheme.text)
                                }
                                
                                Button(action: {
                                    textOnScreen = zekrItem.transliteration
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "textformat.abc")
                                        Text("Transliteration")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(textOnScreen == zekrItem.transliteration ? theme.currentTheme.primary.opacity(0.8) : theme.currentTheme.background.opacity(0.15))
                                    )
                                    .foregroundColor(textOnScreen == zekrItem.transliteration ? theme.currentTheme.primary : theme.currentTheme.background.opacity(0.7))
                                }

                            }
                            
                            // Secondary buttons row
                            HStack(spacing: 8) {
                                Button(action: {
                                    textOnScreen = zekrItem.en_tr
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "textformat")
                                        Text("English")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(textOnScreen == zekrItem.en_tr ? theme.currentTheme.primary : theme.currentTheme.background.opacity(0.2))
                                    )
                                    .foregroundColor(textOnScreen == zekrItem.en_tr ? theme.currentTheme.primary : theme.currentTheme.background)
                                }

                                if let bless = zekrItem.bless {
                                    Button(action: {
                                        textOnScreen = bless
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                            Text("Blessing")
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(textOnScreen == bless ? theme.currentTheme.primary.opacity(0.8) : theme.currentTheme.background.opacity(0.15))
                                        )
                                        .foregroundColor(textOnScreen == bless ? theme.currentTheme.primary : theme.currentTheme.background.opacity(0.7))
                                    }
                                }
                                
                                if let bless_en = zekrItem.bless_en {
                                    Button(action: {
                                        textOnScreen = bless_en
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star")
                                            Text("Blessing EN")
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(textOnScreen == bless_en ? theme.currentTheme.primary.opacity(0.8) : theme.currentTheme.background.opacity(0.15))
                                        )
                                        .foregroundColor(textOnScreen == bless_en ? theme.currentTheme.primary : theme.currentTheme.background.opacity(0.7))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
//                        .onAppear {
//                            textOnScreen = zekrItem.zekr
//                        }
                        .onChange(of: currentIndex) { _ in
                            DispatchQueue.main.async {
                                textOnScreen = zekrItem.zekr
                            }
                        }
                        // Save progress when view disappears
                        .onDisappear {
                            progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(theme.currentTheme.background)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                    )
                    
                
            }
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                currentIndex = findFirstIncompleteIndex()
                textOnScreen = zekrItem.zekr
                resetRepetitions()
            }
            .onChange(of: currentIndex) { _ in
                resetRepetitions()
            }
        }
        .alert("Congratulations!", isPresented: $showCompletionAlert) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("You have completed all Azkar for the \(category.rawValue) category.")
        }
    }

    private func checkIfAllAzkarCompleted() {
        // Ensure azkarList is not empty before checking
        guard !azkarList.isEmpty else { return }
        
        let allCompleted = azkarList.allSatisfy { zekrItemInList in
            progressStore.isCompleted(zekr: zekrItemInList, category: category)
        }
        if allCompleted {
            showCompletionAlert = true
        }
    }

    private func resetRepetitions() {
        // Load saved partial progress instead of just checking completion
        let savedProgress = progressStore.getPartialProgress(zekr: zekrItem, category: category)
        
        // If the item is fully completed, set to max repetitions
        if progressStore.isCompleted(zekr: zekrItem, category: category) {
            currentRepetition = zekrItem.repeat
        } else {
            // Otherwise, restore the saved partial progress
            currentRepetition = savedProgress
        }
    }
    
    private func findFirstIncompleteIndex() -> Int {
        for (index, zekr) in azkarList.enumerated() {
            if !progressStore.isCompleted(zekr: zekr, category: category) {
                return index
            }
        }
        // If all are completed, return 0 (first item)
        return 0
    }

    private func countUpZekr() {
        if currentRepetition < zekrItem.repeat {
            currentRepetition += 1
            // Save partial progress immediately
            progressStore.savePartialProgress(zekr: zekrItem, category: category, currentRepetition: currentRepetition)
            
            if currentRepetition == zekrItem.repeat {
                progressStore.markAsCompleted(zekr: zekrItem, category: category)
                checkIfAllAzkarCompleted()
            }
        }
    }
}
