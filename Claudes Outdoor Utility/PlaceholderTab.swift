//
//  PlaceholderTab.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Shared placeholder body used by every feature tab while its real
//  implementation is being built. Each tab passes an SF Symbol, a
//  display name, and a one-line summary of what the tab will do; the
//  placeholder renders those into a consistent visual shell. Real
//  implementations replace the body without touching ContentView.
//

import SwiftUI

struct PlaceholderTab: View {
    let icon: String
    let title: String
    let summary: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2)
            Text(summary)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Text("Coming in v1.0.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlaceholderTab(
        icon: "map",
        title: "Home",
        summary: "Map view of every place you have logged."
    )
}
