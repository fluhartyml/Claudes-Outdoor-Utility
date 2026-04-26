//
//  Claudes_Outdoor_UtilityApp.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  App entry. WindowGroup hosting ContentView. Single SwiftData
//  ModelContainer for OutsideLog — the only persistent type the
//  app stores. Quiet by design: every feature tab owns its own
//  state, so the entry has nothing to coordinate beyond the model
//  container.
//

import SwiftUI
import SwiftData

@main
struct Claudes_Outdoor_UtilityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: OutsideLog.self)
    }
}
