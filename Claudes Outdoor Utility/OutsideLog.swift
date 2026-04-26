//
//  OutsideLog.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  The app's single SwiftData @Model. Every journal entry is one
//  OutsideLog. Title, timestamp, latitude, longitude, weather snapshot
//  fields, optional photo bytes, free-text note. SwiftData persists
//  these to a local SQLite store; @Query in the Log tab observes
//  changes automatically.
//
//  Photo bytes are stored exactly as the user gave them — no EXIF
//  read, no EXIF write. Location coordinates live alongside the photo
//  in the model, separate from the photo's own metadata. The user's
//  iOS camera-location setting remains the sole authority on whether
//  photos carry GPS EXIF anywhere.
//

import Foundation
import SwiftData

@Model
final class OutsideLog {
    var id: UUID
    var timestamp: Date
    var title: String
    var latitude: Double
    var longitude: Double
    var weatherSummary: String
    var temperature: Double
    var condition: String
    var photoData: Data?
    var note: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        title: String,
        latitude: Double,
        longitude: Double,
        weatherSummary: String = "",
        temperature: Double = 0,
        condition: String = "",
        photoData: Data? = nil,
        note: String = ""
    ) {
        self.id = id
        self.timestamp = timestamp
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.weatherSummary = weatherSummary
        self.temperature = temperature
        self.condition = condition
        self.photoData = photoData
        self.note = note
    }
}

extension OutsideLog {
    /// Display title formatted as "YYYY MMM DD {title}" — used in Log rows,
    /// detail view navigation title, and map pin callouts. Date dominates.
    var displayTitle: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy MMM dd"
        return "\(f.string(from: timestamp).uppercased()) \(title)"
    }
}
