//
//  ContentView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Root TabView shell. Four tabs: Home (map of past entries),
//  New Entry (capture flow), Log (chronological list), Under the
//  Hood (source tour). Each tab body is wrapped in AppShell so the
//  (i) info button + About sheet plumbing is shared once.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "map") }
            NewEntryView()
                .tabItem { Label("New Entry", systemImage: "plus.app") }
            LogView()
                .tabItem { Label("Log", systemImage: "list.bullet.rectangle") }
            UnderTheHoodView()
                .tabItem { Label("Under the Hood", systemImage: "wrench.and.screwdriver") }
        }
    }
}

#Preview {
    ContentView()
}
