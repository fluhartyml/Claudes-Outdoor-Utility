//
//  AppShell.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Wrapping container that adds NavigationStack + (i) info button
//  toolbar + About sheet plumbing. Every tab body wraps in this so
//  the (i) button and About flow are shared once instead of repeated
//  four times. Feature views just describe their own content.
//

import SwiftUI

struct AppShell<Content: View>: View {
    let content: Content
    @State private var showingAbout = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAbout = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .accessibilityLabel("About")
                    }
                }
                .sheet(isPresented: $showingAbout) {
                    AboutView()
                }
        }
    }
}
