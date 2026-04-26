//
//  EntryDetailView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  One entry full, in-place editable. The detail view IS the edit
//  view (Apple Notes pattern) — title and note are TextField/TextEditor
//  bound directly to the @Bindable @Model, photo is replaceable via
//  the same Add Photo confirmation dialog used by NewEntryView.
//  SwiftData autosaves on the modelContext, so changes persist as the
//  user types. Frozen fields — timestamp, coordinates, weather — stay
//  read-only because they define when/where/what-was-the-weather of
//  the original moment; editing them undermines the journal's premise.
//  The map is locked (.allowsHitTesting(false)) so the pin cannot get
//  scrolled out of view.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation
import PhotosUI

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var log: OutsideLog

    @State private var showingDeleteConfirm = false
    @State private var showingShare = false
    @State private var shareItems: [Any] = []
    @State private var preparingShare = false

    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var pickerItem: PhotosPickerItem?

    enum Field: Hashable { case title, note }
    @FocusState private var focusedField: Field?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let data = log.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                log.photoData = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white, .black.opacity(0.6))
                                    .padding(8)
                            }
                        }
                }
                Button {
                    showingPhotoOptions = true
                } label: {
                    Label(log.photoData == nil ? "Add Photo" : "Replace Photo",
                          systemImage: "camera")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Title this entry", text: $log.title)
                        .font(.headline)
                        .textInputAutocapitalization(.sentences)
                        .focused($focusedField, equals: .title)
                }

                if !log.weatherSummary.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            if !log.condition.isEmpty {
                                Image(systemName: log.condition)
                                    .font(.title)
                                    .foregroundStyle(.tint)
                            }
                            Text(log.weatherSummary)
                                .font(.headline)
                        }
                        WeatherAttributionRow()
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Note")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $log.note)
                        .frame(minHeight: 140)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .focused($focusedField, equals: .note)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(timestampDisplay)
                        .font(.callout)
                    Text(coordinatesDisplay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ZStack(alignment: .bottomTrailing) {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: log.latitude, longitude: log.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    ))) {
                        Marker(log.title, coordinate: CLLocationCoordinate2D(latitude: log.latitude, longitude: log.longitude))
                    }
                    .allowsHitTesting(false)

                    Color.clear
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 0.4) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            openInAppleMaps()
                        }

                    Text("Hold to open in Maps")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .padding(8)
                        .allowsHitTesting(false)
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(log.displayTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        prepareAndShare()
                    } label: {
                        Label("Share Entry", systemImage: "square.and.arrow.up")
                    }
                    .disabled(preparingShare)
                    Divider()
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete Entry", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .sheet(isPresented: $showingShare) {
            ActivityShareSheet(items: shareItems)
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
                log.photoData = data
            }
            .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    log.photoData = data
                }
                pickerItem = nil
            }
        }
        .alert("Delete Entry?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(log)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This entry will be removed permanently. The photo it carries will be deleted along with it.")
        }
    }

    private var timestampDisplay: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy MMM dd  HH:mm"
        return f.string(from: log.timestamp).uppercased()
    }

    private var coordinatesDisplay: String {
        String(format: "%.4f, %.4f", log.latitude, log.longitude)
    }

    private func prepareAndShare() {
        focusedField = nil
        preparingShare = true
        Task {
            let items = await EntryShareBuilder.buildItems(for: log)
            await MainActor.run {
                shareItems = items
                preparingShare = false
                showingShare = true
            }
        }
    }

    private func openInAppleMaps() {
        let titleEncoded = log.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? log.title
        let urlString = "https://maps.apple.com/?ll=\(log.latitude),\(log.longitude)&q=\(titleEncoded)"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
