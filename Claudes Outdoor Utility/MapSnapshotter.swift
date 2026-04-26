//
//  MapSnapshotter.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Async wrapper around MKMapSnapshotter. Renders a static map image
//  centered on the entry's coordinate with a red pin annotation
//  drawn on top. Used by EntryShareBuilder to attach a map to the
//  per-entry share bundle and (later) by JournalPDFGenerator for
//  the per-entry page in PDF exports.
//

import Foundation
import MapKit
import UIKit
import CoreLocation

enum MapSnapshotter {

    /// Generates a snapshot of the map centered on `coordinate` with a
    /// red pin annotation drawn on top. Returns the rendered UIImage.
    /// Throws if the system snapshotter fails (e.g. low memory).
    static func snapshot(
        at coordinate: CLLocationCoordinate2D,
        size: CGSize = CGSize(width: 800, height: 500),
        spanDelta: CLLocationDegrees = 0.02
    ) async throws -> UIImage {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        )
        options.size = size
        options.scale = UIScreen.main.scale
        options.mapType = .standard

        let snapshotter = MKMapSnapshotter(options: options)
        let snapshot = try await snapshotter.start()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            snapshot.image.draw(at: .zero)

            let point = snapshot.point(for: coordinate)
            let pinSize: CGFloat = 32
            let pinRect = CGRect(
                x: point.x - pinSize / 2,
                y: point.y - pinSize,
                width: pinSize,
                height: pinSize
            )

            if let pin = UIImage(systemName: "mappin.circle.fill")?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal) {
                pin.draw(in: pinRect)
            }
        }
    }
}
