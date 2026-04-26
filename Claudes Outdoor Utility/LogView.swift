//
//  LogView.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Reverse-chronological list of past entries. Each row leads with
//  the date+title display string ("YYYY MMM DD {title}") and shows
//  the weather summary as secondary text. Tap a row to push the
//  EntryDetailView. Backed by SwiftData @Query observing the
//  modelContext for live updates whenever a new entry saves.
//

import SwiftUI
import SwiftData

struct LogView: View {
    @Query(sort: \OutsideLog.timestamp, order: .reverse) private var entries: [OutsideLog]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        AppShell {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink {
                                EntryDetailView(log: entry)
                            } label: {
                                LogRow(entry: entry)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(entries[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Log")
            .toolbarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.secondary)
            Text("No entries yet")
                .font(.title2)
            Text("Tap New Entry to capture your first weather-stamped moment.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LogRow: View {
    let entry: OutsideLog

    var body: some View {
        HStack(spacing: 12) {
            if let data = entry.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "camera")
                            .foregroundStyle(.secondary)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.displayTitle)
                    .font(.callout)
                    .lineLimit(2)
                if !entry.weatherSummary.isEmpty {
                    Text(entry.weatherSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LogView()
        .modelContainer(for: OutsideLog.self, inMemory: true)
}
