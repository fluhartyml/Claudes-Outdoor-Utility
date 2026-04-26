//
//  WeatherFetcher.swift
//  Claudes Outdoor Utility
//
//  ── Under the Hood ──────────────────────────────────────────────
//  Thin async wrapper around WeatherKit's WeatherService. Given a
//  CLLocation, returns a frozen snapshot suitable for stamping into
//  a journal entry: human-readable summary, temperature in user's
//  preferred unit, and the SF Symbol name for the condition. The
//  attribution row in the UI is the developer's responsibility, not
//  this struct's — see AboutView and the weather card in
//  NewEntryView / EntryDetailView.
//

import Foundation
import CoreLocation
import WeatherKit

struct WeatherSnapshot {
    let summary: String
    let temperature: Double
    let conditionSymbolName: String
}

enum WeatherFetcher {
    static func fetch(at location: CLLocation) async throws -> WeatherSnapshot {
        let service = WeatherService.shared
        let weather = try await service.weather(for: location)
        let current = weather.currentWeather

        let temperatureF = current.temperature.converted(to: .fahrenheit).value
        let conditionText = current.condition.description
        let summary = String(format: "%.0f°F, %@", temperatureF, conditionText.lowercased())

        return WeatherSnapshot(
            summary: summary,
            temperature: temperatureF,
            conditionSymbolName: current.symbolName
        )
    }
}
