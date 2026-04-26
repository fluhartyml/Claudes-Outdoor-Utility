//
//  WeatherAttributionRow.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Single-Link row reading "Weather data provided by  Weather"
//  (apple glyph U+F8FF). Tappable destination is Apple's canonical
//  legal-attribution page. Reused on the About sheet and adjacent to
//  every weather card so attribution appears wherever weather data
//  shows — required by Apple WeatherKit terms.
//

import SwiftUI

struct WeatherAttributionRow: View {
    var body: some View {
        Link(destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!) {
            Text("Weather data provided by \u{F8FF} Weather")
                .font(.caption)
        }
    }
}

#Preview {
    WeatherAttributionRow()
        .padding()
}
