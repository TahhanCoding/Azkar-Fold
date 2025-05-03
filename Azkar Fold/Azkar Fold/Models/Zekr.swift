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
    @Published var zekrs: [Zekr] = []
    private let saveKey = "savedZekrs"
    
    init() {
        loadZekrs()
    }
    
    func addZekr(text: String) {
        let newZekr = Zekr(text: text)
        zekrs.append(newZekr)
        saveZekrs()
    }
    
    func updateCounter(for zekrId: UUID) {
        if let index = zekrs.firstIndex(where: { $0.id == zekrId }) {
            zekrs[index].counter += 1
            zekrs[index].lastUpdated = Date()
            saveZekrs()
        }
    }
    
    func deleteZekr(at indexSet: IndexSet) {
        zekrs.remove(atOffsets: indexSet)
        saveZekrs()
    }
    
    private func saveZekrs() {
        if let encoded = try? JSONEncoder().encode(zekrs) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadZekrs() {
        if let savedZekrs = UserDefaults.standard.data(forKey: saveKey),
           let decodedZekrs = try? JSONDecoder().decode([Zekr].self, from: savedZekrs) {
            zekrs = decodedZekrs
        }
    }
}