//
//  UnderTheHoodView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  In-app source tour. Lists every Swift file with a one-line
//  purpose, presents a sheet with the design rationale callout,
//  embedded source, and an Open on GitHub link. Same pattern as
//  Audio Universe. Placeholder for now while the foundation lands.
//

import SwiftUI

struct UnderTheHoodView: View {
    var body: some View {
        AppShell {
            PlaceholderTab(
                icon: "wrench.and.screwdriver",
                title: "Under the Hood",
                summary: "Browse the app's own Swift source files with a callout per file explaining the design choice."
            )
            .navigationTitle("Under the Hood")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    UnderTheHoodView()
}
