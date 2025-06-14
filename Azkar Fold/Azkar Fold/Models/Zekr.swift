//
//  Zekr.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import Foundation

struct Zekr: Identifiable, Codable, Hashable {
    var id: UUID
    var text: String
    var counter: Int
    var lastUpdated: Date
    
    init(id: UUID = UUID(), text: String, counter: Int = 0, lastUpdated: Date = Date()) {
        self.id = id
        self.text = text
        self.counter = counter
        self.lastUpdated = lastUpdated
    }
}

// ViewModel to manage Zekr data
class ZekrStore: ObservableObject {
    @Published private(set) var zekrs: [Zekr] = []
    private let saveKey = "savedZekrs"
    
    init() {
        loadZekrs()
    }
    
    func addZekr(text: String, completion: @escaping () -> Void) {
        let newZekr = Zekr(text: text)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.zekrs.append(newZekr)
            self.saveZekrs()
            self.objectWillChange.send()
            
            completion()
        }
    }

    func updateCounter(for zekrId: UUID) {
        if let index = zekrs.firstIndex(where: { $0.id == zekrId }) {
            var updatedZekrs = zekrs
            var updatedZekr = updatedZekrs[index]
            updatedZekr.counter += 1
            updatedZekr.lastUpdated = Date()
            updatedZekrs[index] = updatedZekr
            zekrs = updatedZekrs
            saveZekrs()
        }
    }
    
    func deleteZekr(at indexSet: IndexSet) {
        var updatedZekrs = zekrs
        updatedZekrs.remove(atOffsets: indexSet)
        zekrs = updatedZekrs
        saveZekrs()
        // Explicitly notify observers of the change
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func deleteZekr(withId id: UUID) {
        if let index = zekrs.firstIndex(where: { $0.id == id }) {
            var updatedZekrs = zekrs
            updatedZekrs.remove(at: index)
            zekrs = updatedZekrs
            saveZekrs()
            // Explicitly notify observers of the change
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private func saveZekrs() {
        do {
            let encoded = try JSONEncoder().encode(zekrs)
            UserDefaults.standard.set(encoded, forKey: saveKey)
            // Force UserDefaults to save immediately
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving zekrs: \(error.localizedDescription)")
        }
    }
    
    func loadZekrs() {
        if let savedZekrs = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decodedZekrs = try JSONDecoder().decode([Zekr].self, from: savedZekrs)
                zekrs = decodedZekrs
                // Explicitly notify observers of the change after loading data
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            } catch {
                print("Error loading zekrs: \(error.localizedDescription)")
            }
        }
    }
}

extension ZekrStore {
    // Reset counter to 0
    func resetCounter(for id: UUID) {
        if let index = zekrs.firstIndex(where: { $0.id == id }) {
            var updatedZekrs = zekrs
            var updatedZekr = updatedZekrs[index]
            updatedZekr.counter = 0
            updatedZekr.lastUpdated = Date()
            updatedZekrs[index] = updatedZekr
            zekrs = updatedZekrs
            saveZekrs()
        }
    }

    // Update zekr text
    func updateZekrText(for id: UUID, newText: String) {
        if let index = zekrs.firstIndex(where: { $0.id == id }) {
            var updatedZekrs = zekrs
            var updatedZekr = updatedZekrs[index]
            updatedZekr.text = newText
            updatedZekr.lastUpdated = Date()
            updatedZekrs[index] = updatedZekr
            zekrs = updatedZekrs
            saveZekrs()
        }
    }
}
