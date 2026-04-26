//
//  EntryShareBuilder.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Composes the multi-item bundle for sharing one OutsideLog via the
//  system share sheet. Bundle contents:
//    - The user's photo (UIImage) when present
//    - A static map snapshot (UIImage) of the entry's location
//    - A formatted text block carrying title, date, weather, location,
//      note, and a tappable Apple Maps URL
//  System share targets render this naturally: Apple Notes embeds
//  both images and the text; iMessage attaches the images and sends
//  the text in the same message; Mail composes a body with attachments.
//

import Foundation
import UIKit
import CoreLocation

enum EntryShareBuilder {

    /// Builds the share bundle. Async because the map snapshot is
    /// generated on demand. Returns an array suitable for passing
    /// directly to UIActivityViewController.activityItems.
    static func buildItems(for log: OutsideLog) async -> [Any] {
        var items: [Any] = []

        if let data = log.photoData, let photo = UIImage(data: data) {
            items.append(photo)
        }

        let coordinate = CLLocationCoordinate2D(latitude: log.latitude, longitude: log.longitude)
        if let mapImage = try? await MapSnapshotter.snapshot(at: coordinate) {
            items.append(mapImage)
        }

        items.append(formattedText(for: log))

        return items
    }

    private static func formattedText(for log: OutsideLog) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM dd  HH:mm"
        let dateString = dateFormatter.string(from: log.timestamp).uppercased()

        let coords = String(format: "%.4f, %.4f", log.latitude, log.longitude)
        let mapsURL = "https://maps.apple.com/?ll=\(log.latitude),\(log.longitude)&q=\(urlEncoded(log.title))"

        var lines: [String] = []
        lines.append(log.title)
        lines.append(dateString)

        if !log.weatherSummary.isEmpty {
            lines.append("Weather: \(log.weatherSummary)")
        }

        lines.append("Location: \(coords)")

        if !log.note.isEmpty {
            lines.append("")
            lines.append(log.note)
        }

        lines.append("")
        lines.append(mapsURL)
        lines.append("")
        lines.append("Logged with Claudes Outdoor Utility.")

        return lines.joined(separator: "\n")
    }

    private static func urlEncoded(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}
