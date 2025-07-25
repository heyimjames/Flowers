//
//  WidgetDataProvider.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import Foundation
import SwiftUI

/// Provides data access for widgets using shared UserDefaults via App Groups
class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    private let sharedDefaults = UserDefaults(suiteName: "group.OCTOBER.Flowers")
    
    // UserDefaults keys (matching FlowerStore)
    private let discoveredFlowersKey = "discoveredFlowers"
    private let pendingFlowerKey = "pendingFlower"
    private let nextFlowerTimeKey = "nextFlowerTime"
    private let favoritesKey = "favorites"
    private let dailyFlowerKey = "dailyFlower"
    private let dailyFlowerDateKey = "dailyFlowerDate"
    private let lastScheduledDateKey = "lastScheduledFlowerDate"
    
    private init() {}
    
    // MARK: - Current/Recent Flower Data
    
    /// Get the most recent discovered flower
    var mostRecentFlower: AIFlower? {
        print("🔍 WidgetDataProvider: Getting most recent flower...")
        let flowers = discoveredFlowers
        let recent = flowers.sorted(by: { $0.generatedDate > $1.generatedDate }).first
        print("📱 WidgetDataProvider: Most recent flower: \(recent?.name ?? "none")")
        return recent
    }
    
    /// Get pending flower if available
    var pendingFlower: AIFlower? {
        guard let data = sharedDefaults?.data(forKey: pendingFlowerKey) else { return nil }
        return try? JSONDecoder().decode(AIFlower.self, from: data)
    }
    
    /// Check if there's an unrevealed flower available
    var hasUnrevealedFlower: Bool {
        return pendingFlower != nil
    }
    
    /// Get next flower time
    var nextFlowerTime: Date? {
        guard let timestamp = sharedDefaults?.object(forKey: nextFlowerTimeKey) as? Date else { return nil }
        return timestamp
    }
    
    // MARK: - Collection Data
    
    /// Get widget data (lightweight)
    private var widgetDataStore: WidgetDataStore? {
        print("🔍 WidgetDataProvider: Attempting to read widget data...")
        print("🔍 WidgetDataProvider: Shared defaults available: \(sharedDefaults != nil)")
        
        guard let sharedDefaults = sharedDefaults else {
            print("❌ WidgetDataProvider: No shared UserDefaults available!")
            return nil
        }
        
        guard let data = sharedDefaults.data(forKey: "widgetData") else { 
            print("❌ WidgetDataProvider: No widget data found")
            print("🔍 WidgetDataProvider: Available keys in shared defaults: \(Array(sharedDefaults.dictionaryRepresentation().keys))")
            return nil
        }
        
        print("✅ WidgetDataProvider: Found widget data, size: \(data.count) bytes (\(String(format: "%.1f", Double(data.count) / 1024))KB)")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let widgetData = try decoder.decode(WidgetDataStore.self, from: data)
            print("✅ WidgetDataProvider: Successfully decoded widget data with \(widgetData.recentFlowers.count) flowers")
            if !widgetData.recentFlowers.isEmpty {
                print("🌸 WidgetDataProvider: First flower: \(widgetData.recentFlowers[0].name)")
            }
            return widgetData
        } catch {
            print("❌ WidgetDataProvider: Failed to decode widget data: \(error)")
            print("🔍 WidgetDataProvider: Raw data preview: \(String(data: data.prefix(200), encoding: .utf8) ?? "not UTF8")")
            return nil
        }
    }
    
    /// Get all discovered flowers (fallback to old method if new data not available)
    var discoveredFlowers: [AIFlower] {
        // Try new lightweight data first
        if let widgetData = widgetDataStore {
            print("✅ WidgetDataProvider: Using new lightweight widget data")
            return widgetData.recentFlowers.map { widgetFlower in
                let flower = AIFlower(
                    name: widgetFlower.name,
                    descriptor: widgetFlower.descriptor,
                    imageData: widgetFlower.thumbnailData,
                    generatedDate: widgetFlower.generatedDate,
                    isFavorite: widgetFlower.isFavorite,
                    discoveryLocationName: widgetFlower.discoveryLocationName,
                    discoveryWeatherCondition: widgetFlower.discoveryWeatherCondition,
                    discoveryTemperature: widgetFlower.discoveryTemperature,
                    discoveryTemperatureUnit: widgetFlower.discoveryTemperatureUnit,
                    discoveryFormattedDate: widgetFlower.discoveryFormattedDate,
                    ownershipHistory: []
                )
                print("🌸 WidgetDataProvider: Created flower '\(flower.name)' with image data size: \(widgetFlower.thumbnailData?.count ?? 0) bytes")
                return flower
            }
        }
        
        // Fallback to old method (for backwards compatibility)
        print("🔍 WidgetDataProvider: Falling back to old discovered flowers data...")
        
        guard let sharedDefaults = sharedDefaults else {
            print("❌ WidgetDataProvider: No shared UserDefaults available!")
            return []
        }
        
        guard let data = sharedDefaults.data(forKey: discoveredFlowersKey) else { 
            print("❌ WidgetDataProvider: No data found for key '\(discoveredFlowersKey)'")
            return [] 
        }
        
        print("✅ WidgetDataProvider: Found legacy data, size: \(data.count) bytes")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let flowers = try decoder.decode([AIFlower].self, from: data)
            print("✅ WidgetDataProvider: Successfully decoded \(flowers.count) discovered flowers from legacy data")
            return flowers
        } catch {
            print("❌ WidgetDataProvider: Failed to decode discovered flowers: \(error)")
            return []
        }
    }
    
    /// Get favorite flowers
    var favoriteFlowers: [AIFlower] {
        guard let data = sharedDefaults?.data(forKey: favoritesKey) else { 
            print("WidgetDataProvider: No shared data found for favorites")
            return [] 
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let favorites = (try? decoder.decode([AIFlower].self, from: data)) ?? []
        print("WidgetDataProvider: Found \(favorites.count) favorite flowers")
        return favorites
    }
    
    /// Get recent flowers for collection widgets (last 9 for grid)
    func getRecentFlowers(limit: Int = 9) -> [AIFlower] {
        let flowers = discoveredFlowers.sorted(by: { $0.generatedDate > $1.generatedDate })
        return Array(flowers.prefix(limit))
    }
    
    /// Get cycling flower for small collection widget
    func getCyclingFlower(at index: Int) -> AIFlower? {
        let flowers = discoveredFlowers
        guard !flowers.isEmpty else { return nil }
        let cycleIndex = index % flowers.count
        return flowers.sorted(by: { $0.generatedDate > $1.generatedDate })[cycleIndex]
    }
    
    // MARK: - Helper Methods
    
    /// Convert image data to SwiftUI Image
    func image(from data: Data?) -> Image? {
        guard let data = data,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    /// Get formatted discovery date
    func formattedDate(for flower: AIFlower) -> String {
        if let formattedDate = flower.discoveryFormattedDate {
            return formattedDate
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: flower.generatedDate)
    }
    
    /// Get location string for flower
    func locationString(for flower: AIFlower) -> String? {
        return flower.discoveryLocationName
    }
    
    /// Get weather info for flower
    func weatherInfo(for flower: AIFlower) -> (condition: String?, temperature: String?) {
        let condition = flower.discoveryWeatherCondition
        
        var temperature: String?
        if let temp = flower.discoveryTemperature,
           let unit = flower.discoveryTemperatureUnit {
            temperature = "\(Int(temp))°\(unit.replacingOccurrences(of: "°", with: ""))"
        }
        
        return (condition, temperature)
    }
    
    // MARK: - Stats
    
    /// Total discovered flowers count
    var totalFlowersCount: Int {
        if let widgetData = widgetDataStore {
            return widgetData.totalCount
        }
        return discoveredFlowers.count
    }
    
    /// Favorite flowers count
    var favoritesCount: Int {
        if let widgetData = widgetDataStore {
            return widgetData.favoritesCount
        }
        return favoriteFlowers.count
    }
    
    /// Check if user has any flowers
    var hasFlowers: Bool {
        return !discoveredFlowers.isEmpty
    }
}

// MARK: - Widget Entry

import WidgetKit

struct FlowerWidgetEntry: TimelineEntry {
    let date: Date
    let mostRecentFlower: AIFlower?
    let pendingFlower: AIFlower?
    let hasUnrevealedFlower: Bool
    let nextFlowerTime: Date?
    let recentFlowers: [AIFlower]
    let totalCount: Int
    let favoritesCount: Int
}

// MARK: - Preview Data

extension WidgetDataProvider {
    static func sampleEntry() -> FlowerWidgetEntry {
        let sampleFlower = AIFlower(
            name: "Morning Glory Rose",
            descriptor: "beautiful morning rose with soft pink petals",
            imageData: nil,
            isFavorite: true,
            discoveryLocationName: "London, United Kingdom",
            discoveryWeatherCondition: "Sunny",
            discoveryTemperature: 22.0,
            discoveryTemperatureUnit: "°C",
            discoveryFormattedDate: "24th July 2025"
        )
        
        return FlowerWidgetEntry(
            date: Date(),
            mostRecentFlower: sampleFlower,
            pendingFlower: nil,
            hasUnrevealedFlower: false,
            nextFlowerTime: Calendar.current.date(byAdding: .hour, value: 6, to: Date()),
            recentFlowers: [sampleFlower],
            totalCount: 15,
            favoritesCount: 3
        )
    }
    
    static func sampleUnrevealedEntry() -> FlowerWidgetEntry {
        let hiddenFlower = AIFlower(
            name: "Mystery Flower",
            descriptor: "a beautiful surprise awaiting discovery",
            imageData: nil,
            isFavorite: false
        )
        
        return FlowerWidgetEntry(
            date: Date(),
            mostRecentFlower: nil,
            pendingFlower: hiddenFlower,
            hasUnrevealedFlower: true,
            nextFlowerTime: nil,
            recentFlowers: [],
            totalCount: 8,
            favoritesCount: 2
        )
    }
}

// MARK: - Lightweight Widget Data Structures

struct WidgetFlower: Codable, Identifiable {
    let id: UUID
    let name: String
    let descriptor: String
    let generatedDate: Date
    let isFavorite: Bool
    let discoveryLocationName: String?
    let discoveryWeatherCondition: String?
    let discoveryTemperature: Double?
    let discoveryTemperatureUnit: String?
    let discoveryFormattedDate: String?
    let thumbnailData: Data? // Compressed thumbnail for widgets
}

struct WidgetDataStore: Codable {
    let recentFlowers: [WidgetFlower]
    let totalCount: Int
    let favoritesCount: Int
    let lastUpdated: Date
}