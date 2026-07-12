//
//  PrayerPlaceSearchCompleter.swift
//  Azkar Fold
//

import Foundation
import MapKit
import Combine

@MainActor
final class PrayerPlaceSearchCompleter: NSObject, ObservableObject {
    @Published var query: String = "" {
        didSet { scheduleSearch() }
    }
    @Published private(set) var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()
    private var debounceTask: Task<Void, Never>?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func clear() {
        query = ""
        results = []
        completer.queryFragment = ""
    }

    private func scheduleSearch() {
        debounceTask?.cancel()
        let fragment = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fragment.isEmpty else {
            results = []
            completer.queryFragment = ""
            return
        }
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            completer.queryFragment = fragment
        }
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> MKMapItem? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MKLocalSearch.Response, Error>) in
                search.start { response, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let response {
                        continuation.resume(returning: response)
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }
            }
            return response.mapItems.first
        } catch {
            return nil
        }
    }
}

extension PrayerPlaceSearchCompleter: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            results = completer.results
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            results = []
        }
    }
}
