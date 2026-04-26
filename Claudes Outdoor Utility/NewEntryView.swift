//
//  NewEntryView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  The capture flow. Title TextField, "Add Photo" confirmation
//  dialog (Take Photo / Choose from Library), auto-filled weather
//  card from WeatherKit, note editor, timestamp+coords caption,
//  small live map at the bottom showing where the pin will drop.
//  Save inserts an OutsideLog into modelContext. Placeholder for
//  now while the foundation lands.
//

import SwiftUI

struct NewEntryView: View {
    var body: some View {
        AppShell {
            PlaceholderTab(
                icon: "plus.app",
                title: "New Entry",
                summary: "Capture a moment: title, photo, current weather, location, note. One tap to save."
            )
            .navigationTitle("New Entry")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewEntryView()
}
