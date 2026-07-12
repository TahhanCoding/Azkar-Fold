//
//  PrayerLocationManager.swift
//  Azkar Fold
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class PrayerLocationManager: NSObject, ObservableObject {
    enum Status: Equatable {
        case idle
        case requestingAuthorization
        case locating
        case success(CLLocation)
        case denied
        case restricted
        case failed(String)
    }

    @Published private(set) var status: Status = .idle

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestOneShotLocation() async throws -> CLLocation {
        var auth = manager.authorizationStatus

        if auth == .notDetermined {
            status = .requestingAuthorization
            auth = await withCheckedContinuation { continuation in
                authContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        }

        switch auth {
        case .denied:
            status = .denied
            throw LocationError.denied
        case .restricted:
            status = .restricted
            throw LocationError.restricted
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined:
            status = .denied
            throw LocationError.denied
        @unknown default:
            status = .failed("unknown")
            throw LocationError.failed
        }

        status = .locating
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    enum LocationError: Error {
        case denied
        case restricted
        case failed
    }
}

extension PrayerLocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            guard let authContinuation else { return }
            let status = manager.authorizationStatus
            if status != .notDetermined {
                authContinuation.resume(returning: status)
                self.authContinuation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            status = .success(location)
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            status = .failed(error.localizedDescription)
            locationContinuation?.resume(throwing: LocationError.failed)
            locationContinuation = nil
        }
    }
}
