//
//  PrayerLocationPickerView.swift
//  Azkar Fold
//

import SwiftUI
import MapKit
import CoreLocation

struct PrayerLocationPickerView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var settingsStore = PrayerSettingsStore.shared
    @StateObject private var locationManager = PrayerLocationManager()
    @StateObject private var searchCompleter = PrayerPlaceSearchCompleter()

    @State private var region: MKCoordinateRegion
    @State private var previewName: String
    @State private var previewTimeZoneId: String?
    @State private var pendingSource: PrayerLocationSource = .map
    @State private var isGeocoding = false
    @State private var isLocating = false
    @State private var showPermissionAlert = false
    @State private var geocodeTask: Task<Void, Never>?
    @State private var lastGeocodedCenter: CLLocationCoordinate2D?

    init() {
        let location = PrayerSettingsStore.shared.location
        _region = State(initialValue: MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
        _previewName = State(initialValue: location.displayName)
        _previewTimeZoneId = State(initialValue: location.timeZoneIdentifier)
        _pendingSource = State(initialValue: location.source == .defaultMakkah ? .map : location.source)
    }

    var body: some View {
        ZStack {
            mapLayer

            VStack(spacing: 0) {
                searchBar
                if !searchCompleter.results.isEmpty && !searchCompleter.query.isEmpty {
                    searchResultsList
                }
                Spacer()
                bottomCard
            }
        }
        .navigationTitle(appLanguage.text("prayer_location.title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            appLanguage.text("prayer_location.permission_title"),
            isPresented: $showPermissionAlert
        ) {
            Button(appLanguage.text("prayer_location.open_settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(appLanguage.text("common.cancel"), role: .cancel) {}
        } message: {
            Text(appLanguage.text("prayer_location.permission_message"))
        }
        .onChange(of: region.center.latitude) { _ in
            scheduleGeocodeForMapCenter(source: .map)
        }
        .onChange(of: region.center.longitude) { _ in
            scheduleGeocodeForMapCenter(source: .map)
        }
        .onAppear {
            if previewName.isEmpty || settingsStore.location.source == .defaultMakkah {
                previewName = settingsStore.location.resolvedDisplayName(using: appLanguage)
            }
        }
    }

    private var mapLayer: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: false)
                .ignoresSafeArea(edges: .bottom)

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(theme.currentTheme.primary)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                .offset(y: -18)
                .allowsHitTesting(false)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        Task { await useDeviceLocation() }
                    } label: {
                        Group {
                            if isLocating {
                                ProgressView()
                            } else {
                                Image(systemName: "location.fill")
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.currentTheme.primary)
                        .frame(width: 48, height: 48)
                        .background(theme.currentTheme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                    .disabled(isLocating)
                    .padding(.trailing, 16)
                    .padding(.bottom, 140)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.currentTheme.text.opacity(0.45))
            TextField(
                appLanguage.text("prayer_location.search_placeholder"),
                text: $searchCompleter.query
            )
            .foregroundColor(theme.currentTheme.text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)

            if !searchCompleter.query.isEmpty {
                Button {
                    searchCompleter.clear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.currentTheme.text.opacity(0.35))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(theme.currentTheme.cardBackground.opacity(0.96))
        .cornerRadius(14)
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(searchCompleter.results.prefix(8).enumerated()), id: \.offset) { _, item in
                    Button {
                        Task { await selectSearchResult(item) }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(theme.currentTheme.text)
                            if !item.subtitle.isEmpty {
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundColor(theme.currentTheme.text.opacity(0.55))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    Divider().padding(.leading, 14)
                }
            }
        }
        .frame(maxHeight: 220)
        .background(theme.currentTheme.cardBackground.opacity(0.98))
        .cornerRadius(14)
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 3)
    }

    private var bottomCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3)
                    .foregroundColor(theme.currentTheme.primary)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(appLanguage.text("prayer_location.selected"))
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.55))
                    if isGeocoding {
                        ProgressView()
                            .scaleEffect(0.85)
                    } else {
                        Text(previewName)
                            .font(.headline)
                            .foregroundColor(theme.currentTheme.text)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
            }

            Button {
                confirmSelection()
            } label: {
                Text(appLanguage.text("prayer_location.use_location"))
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.currentTheme.primary)
                    .cornerRadius(12)
            }
            .disabled(isGeocoding || previewName.isEmpty)
        }
        .padding(16)
        .background(theme.currentTheme.cardBackground.opacity(0.98))
        .cornerRadius(18)
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
        .shadow(color: .black.opacity(0.12), radius: 10, y: -2)
    }

    private func selectSearchResult(_ completion: MKLocalSearchCompletion) async {
        guard let item = await searchCompleter.resolve(completion) else { return }
        let coordinate = item.placemark.coordinate
        pendingSource = .search
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        searchCompleter.clear()
        await applyPlacemark(item.placemark, fallbackName: completion.title, source: .search)
    }

    private func useDeviceLocation() async {
        isLocating = true
        defer { isLocating = false }
        do {
            let location = try await locationManager.requestOneShotLocation()
            pendingSource = .device
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
            await reverseGeocode(coordinate: location.coordinate, source: .device)
        } catch PrayerLocationManager.LocationError.denied, PrayerLocationManager.LocationError.restricted {
            showPermissionAlert = true
        } catch {
            previewName = appLanguage.text("prayer_location.geocode_failed")
        }
    }

    private func scheduleGeocodeForMapCenter(source: PrayerLocationSource) {
        // Avoid fighting search/device updates that already geocoded
        let center = region.center
        if let last = lastGeocodedCenter,
           abs(last.latitude - center.latitude) < 0.00015,
           abs(last.longitude - center.longitude) < 0.00015 {
            return
        }

        geocodeTask?.cancel()
        geocodeTask = Task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            pendingSource = source
            await reverseGeocode(coordinate: center, source: source)
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D, source: PrayerLocationSource) async {
        isGeocoding = true
        defer { isGeocoding = false }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await reverseGeocode(location, using: geocoder)
            if let placemark = placemarks.first {
                await applyPlacemark(placemark, fallbackName: coordinateFallbackName(coordinate), source: source)
            } else {
                previewName = coordinateFallbackName(coordinate)
                previewTimeZoneId = TimeZone.current.identifier
                lastGeocodedCenter = coordinate
            }
        } catch {
            previewName = coordinateFallbackName(coordinate)
            previewTimeZoneId = TimeZone.current.identifier
            lastGeocodedCenter = coordinate
        }
    }

    private func reverseGeocode(_ location: CLLocation, using geocoder: CLGeocoder) async throws -> [CLPlacemark] {
        try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: placemarks ?? [])
                }
            }
        }
    }

    private func applyPlacemark(_ placemark: CLPlacemark, fallbackName: String, source: PrayerLocationSource) async {
        let name = displayName(from: placemark) ?? fallbackName
        previewName = name
        previewTimeZoneId = placemark.timeZone?.identifier ?? TimeZone.current.identifier
        pendingSource = source
        if let coordinate = placemark.location?.coordinate {
            lastGeocodedCenter = coordinate
        }
    }

    private func displayName(from placemark: CLPlacemark) -> String? {
        let parts = [
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ].compactMap { $0 }.filter { !$0.isEmpty }
        if !parts.isEmpty {
            return parts.joined(separator: ", ")
        }
        if let name = placemark.name, !name.isEmpty {
            return name
        }
        return nil
    }

    private func coordinateFallbackName(_ coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }

    private func confirmSelection() {
        let location = PrayerLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            displayName: previewName,
            timeZoneIdentifier: previewTimeZoneId,
            source: pendingSource
        )
        settingsStore.setLocation(location)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        PrayerLocationPickerView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(AppLanguageManager.shared)
    }
}
