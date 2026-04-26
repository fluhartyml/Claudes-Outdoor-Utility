//
//  NewEntryView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Capture flow. Title TextField, "Add Photo" confirmation dialog
//  (Take Photo or Choose from Library), auto-filled weather card
//  via WeatherKit + WeatherAttributionRow, free-text note editor,
//  caption with timestamp + coordinates, live small Map at the
//  bottom showing where the entry will pin. Save inserts an
//  OutsideLog into the SwiftData modelContext. Photo bytes are
//  stored as-is — never modify EXIF.
//

import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation
import MapKit

struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var location = LocationManager()
    @Binding var selectedTab: AppTab

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var photoData: Data?
    @State private var weather: WeatherSnapshot?
    @State private var weatherError: String?
    @State private var fetchingWeather = false

    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var pickerItem: PhotosPickerItem?

    enum Field: Hashable { case title, note }
    @FocusState private var focusedField: Field?

    var body: some View {
        AppShell {
            Form {
                Section("Title") {
                    TextField("Title this entry", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .note }
                }

                Section("Photo") {
                    if let data = photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    photoData = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .padding(6)
                                }
                            }
                    }
                    Button {
                        showingPhotoOptions = true
                    } label: {
                        Label(photoData == nil ? "Add Photo" : "Replace Photo", systemImage: "camera")
                    }
                }

                Section("Weather") {
                    weatherCard
                }

                Section("Note") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                        .focused($focusedField, equals: .note)
                }

                Section("Stamp") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(timestampDisplay)
                            .font(.callout)
                        if let location = location.lastLocation {
                            Text(coordinatesDisplay(location.coordinate))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if location.authorizationStatus == .denied || location.authorizationStatus == .restricted {
                            Text("Location permission denied. Update Settings to enable.")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else {
                            Text("Acquiring location…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let coord = location.lastLocation?.coordinate {
                    Section("Where this will pin") {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))) {
                            Marker("", coordinate: coord)
                        }
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .allowsHitTesting(false)
                    }
                }

                Section {
                    Button {
                        save()
                    } label: {
                        Label("Save Entry", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                }
            }
            .navigationTitle("New Entry")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        focusedField = nil
                        reset()
                        selectedTab = .log
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .task {
                location.requestAuthorizationIfNeeded()
            }
            .onChange(of: location.lastLocation) { _, newValue in
                guard let newValue else { return }
                if weather == nil { fetchWeather(at: newValue) }
            }
            .confirmationDialog("Add Photo", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                Button("Take Photo") {
                    showingCamera = true
                }
                Button("Choose from Library") {
                    showingPhotoLibrary = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(isPresented: $showingPhotoLibrary, selection: $pickerItem, matching: .images)
            .sheet(isPresented: $showingCamera) {
                CameraPicker { data in
                    photoData = data
                }
                .ignoresSafeArea()
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                    pickerItem = nil
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    @ViewBuilder
    private var weatherCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            if fetchingWeather {
                ProgressView("Fetching weather…")
            } else if let weather = weather {
                HStack(spacing: 12) {
                    Image(systemName: weather.conditionSymbolName)
                        .font(.title)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading) {
                        Text(weather.summary)
                            .font(.headline)
                    }
                }
                WeatherAttributionRow()
            } else if let weatherError = weatherError {
                Text(weatherError)
                    .font(.caption)
                    .foregroundStyle(.red)
                Button {
                    if let location = location.lastLocation { fetchWeather(at: location) }
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Waiting for location to fetch weather…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        location.lastLocation != nil
    }

    private var timestampDisplay: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy MMM dd  HH:mm"
        return f.string(from: Date()).uppercased()
    }

    private func coordinatesDisplay(_ coord: CLLocationCoordinate2D) -> String {
        String(format: "%.4f, %.4f", coord.latitude, coord.longitude)
    }

    private func fetchWeather(at location: CLLocation) {
        fetchingWeather = true
        weatherError = nil
        Task {
            do {
                let snapshot = try await WeatherFetcher.fetch(at: location)
                weather = snapshot
            } catch {
                weatherError = friendlyError(error)
            }
            fetchingWeather = false
        }
    }

    private func friendlyError(_ error: Error) -> String {
        let raw = error.localizedDescription
        if raw.contains("JWT") || raw.contains("authservice") || raw.contains("Authenticator") {
            return "Weather service is not yet available on this device. The WeatherKit entitlement may take a few minutes to propagate after enabling it on developer.apple.com. You can still save the entry — the weather field will be left empty."
        }
        return "Could not fetch weather: \(raw)"
    }

    private func save() {
        guard let coord = location.lastLocation?.coordinate else { return }
        focusedField = nil
        let log = OutsideLog(
            timestamp: Date(),
            title: title.trimmingCharacters(in: .whitespaces),
            latitude: coord.latitude,
            longitude: coord.longitude,
            weatherSummary: weather?.summary ?? "",
            temperature: weather?.temperature ?? 0,
            condition: weather?.conditionSymbolName ?? "",
            photoData: photoData,
            note: note
        )
        modelContext.insert(log)
        try? modelContext.save()
        reset()
        selectedTab = .log
    }

    private func reset() {
        title = ""
        note = ""
        photoData = nil
        weather = nil
        weatherError = nil
    }
}

#Preview {
    NewEntryView(selectedTab: .constant(.newEntry))
        .modelContainer(for: OutsideLog.self, inMemory: true)
}
