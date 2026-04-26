//
//  HomeView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Full-tab MapKit map of every saved entry. Each entry renders as
//  a Marker with the entry's title. Tap a marker → selectedEntryID
//  flips → navigationDestination(item:) pushes the EntryDetailView.
//  UserAnnotation shows the device's current location dot when
//  location permission is granted. Camera position is .automatic so
//  MapKit auto-fits to the markers + user dot on first appear.
//  Empty state when no entries exist directs the user to the New
//  Entry tab.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct HomeView: View {
    @Query(sort: \OutsideLog.timestamp, order: .reverse) private var entries: [OutsideLog]
    @StateObject private var location = LocationManager()

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedEntryID: UUID?

    var body: some View {
        AppShell {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    map
                }
            }
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inline)
            .task {
                location.requestAuthorizationIfNeeded()
            }
        }
    }

    private var map: some View {
        Map(position: $cameraPosition, selection: $selectedEntryID) {
            UserAnnotation()
            ForEach(entries) { entry in
                Marker(
                    entry.title.isEmpty ? "Entry" : entry.title,
                    coordinate: CLLocationCoordinate2D(
                        latitude: entry.latitude,
                        longitude: entry.longitude
                    )
                )
                .tag(entry.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .navigationDestination(item: $selectedEntryID) { id in
            if let entry = entries.first(where: { $0.id == id }) {
                EntryDetailView(log: entry)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.secondary)
            Text("No entries logged yet")
                .font(.title2)
            Text("Open New Entry to capture your first weather-stamped moment. It will appear here pinned on the map.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
