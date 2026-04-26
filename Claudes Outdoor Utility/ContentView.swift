//
//  ContentView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Root TabView shell. Four tabs: Home (map of past entries),
//  New Entry (capture flow), Log (chronological list), Under the
//  Hood (source tour). Each tab body is wrapped in AppShell so the
//  (i) info button + About sheet plumbing is shared once. The tab
//  selection lives here as a Binding so child views (notably
//  NewEntryView) can switch tabs after save.
//

import SwiftUI
import SwiftData

enum AppTab: Hashable { case home, newEntry, log, underTheHood }

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem { Label("Home", systemImage: "map") }
            NewEntryView(selectedTab: $selectedTab)
                .tag(AppTab.newEntry)
                .tabItem { Label("New Entry", systemImage: "plus.app") }
            LogView()
                .tag(AppTab.log)
                .tabItem { Label("Log", systemImage: "list.bullet.rectangle") }
            UnderTheHoodView()
                .tag(AppTab.underTheHood)
                .tabItem { Label("Under the Hood", systemImage: "wrench.and.screwdriver") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: OutsideLog.self, inMemory: true)
}
