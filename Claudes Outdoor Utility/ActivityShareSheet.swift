//
//  ActivityShareSheet.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Thin SwiftUI wrapper around UIActivityViewController. Used when
//  the share content has to be assembled asynchronously (e.g. a map
//  snapshot has to be rendered before the share sheet opens), since
//  SwiftUI's native ShareLink cannot accept heterogeneous items
//  whose content depends on async work. Present as a .sheet.
//

import SwiftUI
import UIKit

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
