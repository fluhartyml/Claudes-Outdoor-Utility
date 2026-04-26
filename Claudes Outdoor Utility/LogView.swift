//
//  LogView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Reverse-chronological list of past entries. Each row shows a
//  cached MKMapSnapshotter thumbnail next to "YYYY MMM DD {title}"
//  primary text and the weather summary as secondary text. Tap a
//  row to push the Entry detail view. Backed by @Query<OutsideLog>.
//  Placeholder for now while the foundation lands.
//

import SwiftUI

struct LogView: View {
    var body: some View {
        AppShell {
            PlaceholderTab(
                icon: "list.bullet.rectangle",
                title: "Log",
                summary: "Browse past entries chronologically. Each row leads with the date and your title."
            )
            .navigationTitle("Log")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LogView()
}
