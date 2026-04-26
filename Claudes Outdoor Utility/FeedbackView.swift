//
//  FeedbackView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Mailto-based feedback form. Type picker (bug/feature/other),
//  free-text body, auto-included device info (app version, device
//  model, iOS version, locale). Falls back to a simple alert when
//  the device has no mail handler configured.
//

import SwiftUI
import UIKit

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .bug
    @State private var bodyText: String = ""
    @State private var showingNoMailAlert = false

    enum FeedbackType: String, CaseIterable, Identifiable {
        case bug = "Bug Report"
        case feature = "Feature Request"
        case other = "Other"
        var id: String { rawValue }
    }

    private var deviceInfo: String {
        let app = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
        let build = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"
        let device = UIDevice.current.model
        let system = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let locale = Locale.current.identifier
        return """

        --- Device Info ---
        App: Claudes Outdoor Utility \(app) (\(build))
        Device: \(device)
        System: \(system)
        Locale: \(locale)
        """
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $feedbackType) {
                        ForEach(FeedbackType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Details") {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 160)
                }
                Section {
                    Button {
                        sendFeedback()
                    } label: {
                        Label("Send Feedback", systemImage: "paperplane")
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Send Feedback")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("No Mail Configured", isPresented: $showingNoMailAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please configure a Mail account on this device, or email michael.fluharty@mac.com directly.")
            }
        }
    }

    private func sendFeedback() {
        let subject = "Claudes Outdoor Utility — \(feedbackType.rawValue)"
        let body = bodyText + deviceInfo
        let to = "michael.fluharty@mac.com"
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        guard let url = components.url else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if success { dismiss() } else { showingNoMailAlert = true }
            }
        } else {
            showingNoMailAlert = true
        }
    }
}

#Preview {
    FeedbackView()
}
