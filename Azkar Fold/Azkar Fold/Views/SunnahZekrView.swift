import SwiftUI

struct SunnahZekrView: View {
    @State var azkarList: [SunnahZekrItem]
    let category: SunnahAzkarCategory
    @ObservedObject var progressStore: SunnahProgressStore

    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var currentRepetition: Int = 0
    @State private var showCompletionAlert: Bool = false

    var currentZekr: SunnahZekrItem? {
        guard !azkarList.isEmpty, azkarList.indices.contains(currentIndex) else {
            return nil
        }
        return azkarList[currentIndex]
    }

    var body: some View {
        VStack(spacing: 20) {
            if let zekrItem = currentZekr {
                Text(category.rawValue)
                    .font(.headline)
                    .padding(.top)

                ScrollView {
                    Text(zekrItem.zekr)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(minHeight: 100, maxHeight: .infinity)
                .background(currentRepetition >= zekrItem.repeat ? Color.green.opacity(0.15) : Color.clear)
                .cornerRadius(8)
                
                Text("Repeat: \(currentRepetition)/\(zekrItem.repeat)")
                    .font(.headline)

                Button(action: {
                    if currentRepetition < zekrItem.repeat {
                        currentRepetition += 1
                        if currentRepetition == zekrItem.repeat {
                            progressStore.markAsCompleted(zekr: zekrItem, category: category)
                            checkIfAllAzkarCompleted()
                            // Optionally, auto-advance or enable next button
                        }
                    }
                }) {
                    Text(currentRepetition < zekrItem.repeat ? "Recite (\(currentRepetition + 1))" : "Completed")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(currentRepetition < zekrItem.repeat ? Color.blue : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(currentRepetition >= zekrItem.repeat)

                HStack {
                    Button("Previous") {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            resetRepetitions()
                        }
                    }
                    .disabled(currentIndex == 0)

                    Spacer()
                    
                    Text("\(currentIndex + 1) of \(azkarList.count)")
                        .font(.footnote)

                    Spacer()

                    Button("Next") {
                        if currentIndex < azkarList.count - 1 {
                            currentIndex += 1
                            resetRepetitions()
                        }
                    }
                    .disabled(currentIndex == azkarList.count - 1 || currentRepetition < zekrItem.repeat)
                }
                .padding()

            } else {
                Text("No Azkar loaded for this category or index out of bounds.")
                    .padding()
                Button("Go Back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .padding()
        .navigationTitle(currentZekr != nil ? "Zekr" : category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resetRepetitions() // Ensure correct state when view appears
        }
        .onChange(of: currentIndex) { _ in // Swift 5.5+ syntax, use older if needed
            resetRepetitions()
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
