//
//  DeveloperNotes.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Architecture map authored before any feature work. Mirrors the
//  Build-Along 05 page in Claude's X26 Swift6 Bible. Source of truth
//  for what this app is, what it teaches, and what stays out of scope.
//

import Foundation

enum DeveloperNotes {

    // MARK: - Mission

    /// Claudes Outdoor Utility is a weather-stamped photo journal for
    /// iPhone and iPad. One tap captures a photo, current weather, your
    /// location, a title, and a free-text note — one entry, frozen.
    /// Browse past entries chronologically or pinned on a map.
    static let mission = """
    Weather-stamped photo journal. Apple Photos remembers GPS but not \
    weather; this app fills that gap. v1.0 ships the journal/map; v2.0 \
    adds RainViewer radar overlay on top.
    """

    // MARK: - v1.0 frameworks (no third-party)

    static let frameworks: [String] = [
        "CoreLocation — request when-in-use, read coordinates",
        "WeatherKit — fetch current conditions at log time, freeze them",
        "SwiftData — persist journal entries with @Model + @Query",
        "PhotosUI + UIImagePickerController — library picker + camera",
        "MapKit — Home tab pinned map + per-entry detail map"
    ]

    // MARK: - File map

    static let fileMap: [String: String] = [
        "Claudes_Outdoor_UtilityApp.swift": "App entry — WindowGroup + ModelContainer for OutsideLog",
        "ContentView.swift": "Four-tab TabView shell (Home, New Entry, Log, Under the Hood)",
        "AppShell.swift": "Wrapping container — NavigationStack + (i) info button + About sheet",
        "AboutView.swift": "(i)-launched sheet — icon, version, credit, Send Feedback, Wiki, Privacy, Portfolio, GPL v3",
        "FeedbackView.swift": "Mailto form with auto-included device info",
        "PlaceholderTab.swift": "Shared placeholder body component used while feature views are stubs",
        "OutsideLog.swift": "SwiftData @Model — id, timestamp, title, lat/lng, weather, photoData, note",
        "HomeView.swift": "Map fills the tab, pins for every past entry",
        "NewEntryView.swift": "Capture: title, photo (camera/library), weather (auto), location (auto), note",
        "LogView.swift": "Reverse-chronological list of entries with date+title display",
        "EntryDetailView.swift": "One entry full — photo hero, weather card, note, timestamp+coords, map last",
        "UnderTheHoodView.swift": "Source-tour tab — file list, callout per file, embedded source, Open on GitHub"
    ]

    // MARK: - Locked design rules

    static let rules: [String] = [
        "iOS only (iPhone + iPad). No macOS, no visionOS",
        "SwiftData persists. The diary survives restarts; iCloud sync is a v2.x candidate",
        "Photos untouched. App never reads or modifies photo EXIF",
        "Title required at New Entry time. Keeps Log scannable long-term",
        "Map last on per-entry views, first on archive views",
        "Display format: YYYY MMM DD {title}",
        "Focus-only audio (N/A here, but no Background Modes entitlements)"
    ]

    // MARK: - Info.plist usage descriptions

    static let infoPlistKeys: [String: String] = [
        "NSLocationWhenInUseUsageDescription": "CoreLocation reads your location when you log a new entry.",
        "NSCameraUsageDescription": "Camera lets you take a photo for the entry you are about to log.",
        // PhotoLibrary not listed — PhotosPicker is privacy-preserving and does not require permission
    ]

    // MARK: - Version plan

    /// v1.0 — five-framework composition, no third-party dependencies.
    /// v2.0 — RainViewer radar overlay + MKTileOverlay + UIViewRepresentable + ToS attribution.
    static let versionPlan = """
    v1.0: CoreLocation + WeatherKit + SwiftData + PhotosUI + MapKit. \
    Submit, ship, soak. v2.0: add RainViewer radar tiles on the Home map \
    via MKTileOverlay subclass + UIViewRepresentable bridge. The v1.0 → \
    v2.0 arc is itself a teaching artifact in the book.
    """

    // MARK: - App Services portal

    /// One-time trip on developer.apple.com to enable WeatherKit on the
    /// App ID. CoreLocation, MapKit, PhotosUI, SwiftData do not require
    /// portal enablement.
    static let portalServices: [String] = ["WeatherKit"]
}
