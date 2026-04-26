//
//  HomeView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Map fills the tab. Pins for every past entry. v1.0 Phase 2 wires
//  MapKit + @Query<OutsideLog>. Placeholder for now while the
//  foundation lands.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        AppShell {
            PlaceholderTab(
                icon: "map",
                title: "Home",
                summary: "Map of every place you have logged. Tap a pin to re-read that entry."
            )
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomeView()
}
