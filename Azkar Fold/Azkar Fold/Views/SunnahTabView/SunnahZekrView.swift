import SwiftUI

struct SunnahZekrView: View {
    @State var azkarList: [SunnahZekrItem]
    let category: SunnahAzkarCategory
    @ObservedObject var progressStore: SunnahProgressStore

    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var currentRepetition: Int = 0
    @State private var showCompletionAlert: Bool = false
    @State private var animateCounter = false
    @State private var textOnScreen: String = ""
    var currentZekr: SunnahZekrItem? {
        guard !azkarList.isEmpty, azkarList.indices.contains(currentIndex) else {
            return nil
        }
        return azkarList[currentIndex]
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if let zekrItem = currentZekr {
                    // Upper half - Zekr text
                    VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                Text(textOnScreen)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .font(.system(size: 80))
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(15)
                                    .padding(.vertical, 12)

                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)

                    }
                    .frame(height: geometry.size.height * 0.6)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 33)
                            .fill(currentRepetition >= zekrItem.repeat ? Color.green.opacity(0.2) : Color.appPrimary.opacity(0.1))
                            .overlay(
                                Image("islamic_pattern")
                                    .resizable(resizingMode: .tile)
                                    .opacity(0.35)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 33))
                            .padding(.horizontal, 21)
                            .padding(.vertical, 21)
                    )
                    
                    // Lower half - Counter and controls
                    VStack(spacing: 16) {
                        // Counter display
                        VStack(spacing: 8) {
                            Text("\(currentRepetition)/\(zekrItem.repeat)")
                                .font(.system(size: 60, weight: .black, design: .rounded))
                                .foregroundColor(.appPrimary)
                                .scaleEffect(animateCounter ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCounter)
                            
                            Text(currentRepetition < zekrItem.repeat ? "Tap to recite" : "Completed!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentRepetition < zekrItem.repeat {
                                currentRepetition += 1
                                animateCounter = true
                                
                                if currentRepetition == zekrItem.repeat {
                                    progressStore.markAsCompleted(zekr: zekrItem, category: category)
                                    checkIfAllAzkarCompleted()
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    animateCounter = false
                                }
                            }
                        }
                        
                        // Navigation controls
                        HStack(spacing: 20) {
                            Button(action: {
                                if currentIndex > 0 {
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
                                .background(currentIndex == 0 ? Color.gray.opacity(0.3) : Color.appPrimary)
                                .foregroundColor(currentIndex == 0 ? .gray : .white)
                                .cornerRadius(25)
                            }
                            .disabled(currentIndex == 0)
                            
                            VStack {
                                Text("\(currentIndex + 1) of \(azkarList.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {
                                if currentIndex < azkarList.count - 1 {
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
                                .background((currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat) ? Color.gray.opacity(0.3) : Color.appPrimary)
                                .foregroundColor((currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat) ? .gray : .white)
                                .cornerRadius(25)
                            }
                            .disabled(currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                        // Replace the existing HStack with buttons with this code:

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
                                            .fill(textOnScreen == zekrItem.zekr ? Color.appPrimary : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(textOnScreen == zekrItem.zekr ? .white : .primary)
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
                                            .fill(textOnScreen == zekrItem.transliteration ? Color.appPrimary.opacity(0.8) : Color.gray.opacity(0.15))
                                    )
                                    .foregroundColor(textOnScreen == zekrItem.transliteration ? .white : .secondary)
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
                                            .fill(textOnScreen == zekrItem.en_tr ? Color.appPrimary : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(textOnScreen == zekrItem.en_tr ? .white : .primary)
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
                                                .fill(textOnScreen == bless ? Color.appPrimary.opacity(0.8) : Color.gray.opacity(0.15))
                                        )
                                        .foregroundColor(textOnScreen == bless ? .white : .secondary)
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
                                                .fill(textOnScreen == bless_en ? Color.appPrimary.opacity(0.8) : Color.gray.opacity(0.15))
                                        )
                                        .foregroundColor(textOnScreen == bless_en ? .white : .secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .onAppear {
                            textOnScreen = zekrItem.zekr
                        }

                        
//                        HStack {
//                            Button("zekr") {
//                                textOnScreen = zekrItem.zekr
//                            }
//                            
//                                Button("english_translation") {
//                                    textOnScreen = zekrItem.en_tr
//                                }
//
//                                Button("zekr_transliteration") {
//                                    textOnScreen = zekrItem.transliteration
//                                }
//
//                            if let bless = zekrItem.bless {
//                                Button("bless") {
//                                    textOnScreen = bless
//                                }
//                            }
//                            
//                            
//                            if let bless_en = zekrItem.bless_en {
//                                Button("bless_english_translation") {
//                                    textOnScreen = bless_en
//                                }
//                            }
//
//
//                        }
//                        .onAppear {
//                            textOnScreen = zekrItem.zekr
//                        }
                        
                    }
                    .frame(height: geometry.size.height * 0.4)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                    )
                    
                } else {
                    VStack {
                        Text("No Azkar loaded for this category")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Button("Go Back") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
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
        guard let zekrItem = currentZekr else {
            currentRepetition = 0
            return
        }
        // Check if already completed from store, if so, set repetitions to max
        if progressStore.isCompleted(zekr: zekrItem, category: category) {
            currentRepetition = zekrItem.repeat
        } else {
            currentRepetition = 0
        }
    }
}
