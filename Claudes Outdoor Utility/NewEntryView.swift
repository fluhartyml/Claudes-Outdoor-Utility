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

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var photoData: Data?
    @State private var weather: WeatherSnapshot?
    @State private var weatherError: String?
    @State private var fetchingWeather = false

    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @State private var pickerItem: PhotosPickerItem?

    @State private var saveCompleted = false

    var body: some View {
        AppShell {
            Form {
                Section("Title") {
                    TextField("Title this entry", text: $title)
                        .textInputAutocapitalization(.sentences)
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
                PhotosPicker("Choose from Library", selection: $pickerItem, matching: .images)
                Button("Cancel", role: .cancel) {}
            }
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
            .alert("Saved", isPresented: $saveCompleted) {
                Button("OK") { reset() }
            } message: {
                Text("Your entry was saved. Open the Log tab to see it.")
            }
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
                weatherError = "Could not fetch weather: \(error.localizedDescription)"
            }
            fetchingWeather = false
        }
    }

    private func save() {
        guard let coord = location.lastLocation?.coordinate else { return }
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
        saveCompleted = true
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
    NewEntryView()
        .modelContainer(for: OutsideLog.self, inMemory: true)
}
