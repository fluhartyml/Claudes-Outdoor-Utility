//
//  AboutView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  The (i)-launched sheet that every tab shares via AppShell. Same
//  shape used across the book's roster: icon hero, app name, version,
//  short description, "Engineered with Claude" credit, four outbound
//  buttons (Send Feedback, Support / Wiki, Privacy Policy, Portfolio),
//  GPL v3 footer line. Reachable from any tab's (i) info button.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFeedback = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("AppIconDisplay")
                        .resizable()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.top, 16)

                    Text("Claudes Outdoor Utility")
                        .font(.title2)

                    Text(appVersion)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("A weather-stamped photo journal. One tap captures a photo, current weather, your location, a title, and a free-text note — one entry, frozen in time.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Engineered with Claude")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 10) {
                        Button {
                            showingFeedback = true
                        } label: {
                            Label("Send Feedback", systemImage: "envelope")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Link(destination: URL(string: "https://github.com/fluhartyml/Claudes-Outdoor-Utility/wiki")!) {
                            Label("Support / Wiki", systemImage: "book")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Link(destination: URL(string: "https://fluharty.me/outdoorutility-privacy")!) {
                            Label("Privacy Policy", systemImage: "lock.shield")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Link(destination: URL(string: "https://fluharty.me")!) {
                            Label("Portfolio", systemImage: "person.crop.square")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    Divider()
                        .padding(.horizontal)
                        .padding(.top, 12)

                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "cloud.sun.fill")
                                .foregroundStyle(.secondary)
                            Text("Weather data from")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Link("Apple Weather", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                                .font(.caption)
                        }
                        Text("Other data sources are listed on the linked legal-attribution page.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 8)

                    Text("Released under GPL v3.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)

                    Spacer(minLength: 16)
                }
            }
            .navigationTitle("About")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingFeedback) {
                FeedbackView()
            }
        }
    }
}

#Preview {
    AboutView()
}
