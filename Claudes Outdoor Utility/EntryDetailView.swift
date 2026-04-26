//
//  EntryDetailView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  One entry full. Hero photo at the top, weather card with
//  attribution, the note, timestamp + coordinates, map at the
//  bottom with this entry's pin centered. Map is last on per-entry
//  views so the photo and the words lead — see Build-Along 05's
//  layout rule. Toolbar: Delete, Share.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let log: OutsideLog

    @State private var showingDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let data = log.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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

                if !log.note.isEmpty {
                    Text(log.note)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(timestampDisplay)
                        .font(.callout)
                    Text(coordinatesDisplay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: log.latitude, longitude: log.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))) {
                    Marker(log.title, coordinate: CLLocationCoordinate2D(latitude: log.latitude, longitude: log.longitude))
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle(log.displayTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete Entry", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
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
}
