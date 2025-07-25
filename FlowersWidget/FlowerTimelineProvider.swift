//
//  FlowerTimelineProvider.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import WidgetKit
import SwiftUI

struct FlowerTimelineProvider: TimelineProvider {
    typealias Entry = FlowerWidgetEntry
    private let dataProvider = WidgetDataProvider.shared
    
    func placeholder(in context: Context) -> FlowerWidgetEntry {
        return WidgetDataProvider.sampleEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FlowerWidgetEntry) -> ()) {
        let entry = createCurrentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlowerWidgetEntry>) -> ()) {
        let currentEntry = createCurrentEntry()
        
        // Create timeline with current entry and future refresh points
        var entries: [FlowerWidgetEntry] = [currentEntry]
        let currentDate = Date()
        
        // Add entry for next flower reveal if there's a pending flower
        if dataProvider.hasUnrevealedFlower,
           let nextFlowerTime = dataProvider.nextFlowerTime,
           nextFlowerTime > currentDate {
            // Create entry for when flower should be revealed
            let revealEntry = createCurrentEntry(at: nextFlowerTime)
            entries.append(revealEntry)
        }
        
        // Add daily refresh entries for the next 7 days
        for dayOffset in 1...7 {
            guard let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) else { continue }
            let midnightDate = Calendar.current.startOfDay(for: futureDate)
            let futureEntry = createCurrentEntry(at: midnightDate)
            entries.append(futureEntry)
        }
        
        // Set refresh policy
        let refreshDate: Date
        if dataProvider.hasUnrevealedFlower,
           let nextFlowerTime = dataProvider.nextFlowerTime,
           nextFlowerTime > currentDate {
            // Refresh when flower should be revealed
            refreshDate = nextFlowerTime
        } else {
            // Refresh at next midnight
            refreshDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)
        }
        
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func createCurrentEntry(at date: Date = Date()) -> FlowerWidgetEntry {
        print("🔄 FlowerTimelineProvider: Creating widget entry...")
        
        let mostRecentFlower = dataProvider.mostRecentFlower
        let pendingFlower = dataProvider.pendingFlower
        let hasUnrevealedFlower = dataProvider.hasUnrevealedFlower
        let nextFlowerTime = dataProvider.nextFlowerTime
        let recentFlowers = dataProvider.getRecentFlowers(limit: 9)
        let totalCount = dataProvider.totalFlowersCount
        let favoritesCount = dataProvider.favoritesCount
        
        print("📊 FlowerTimelineProvider: Entry data:")
        print("   - Total flowers: \(totalCount)")
        print("   - Recent flowers: \(recentFlowers.count)")
        print("   - Most recent: \(mostRecentFlower?.name ?? "nil")")
        print("   - Favorites: \(favoritesCount)")
        print("   - Has unrevealed: \(hasUnrevealedFlower)")
        print("   - Next flower time: \(nextFlowerTime?.description ?? "nil")")
        
        return FlowerWidgetEntry(
            date: date,
            mostRecentFlower: mostRecentFlower,
            pendingFlower: pendingFlower,
            hasUnrevealedFlower: hasUnrevealedFlower,
            nextFlowerTime: nextFlowerTime,
            recentFlowers: recentFlowers,
            totalCount: totalCount,
            favoritesCount: favoritesCount
        )
    }
}

// MARK: - Collection Timeline Provider

struct CollectionTimelineProvider: TimelineProvider {
    typealias Entry = FlowerWidgetEntry
    private let dataProvider = WidgetDataProvider.shared
    
    func placeholder(in context: Context) -> FlowerWidgetEntry {
        return WidgetDataProvider.sampleEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FlowerWidgetEntry) -> ()) {
        let entry = createCurrentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlowerWidgetEntry>) -> ()) {
        var entries: [FlowerWidgetEntry] = []
        let currentDate = Date()
        
        // For small collection widget, create cycling entries every 30 minutes
        if context.family == .systemSmall {
            for interval in 0..<48 { // 24 hours worth of 30-minute intervals
                let entryDate = Calendar.current.date(byAdding: .minute, value: interval * 30, to: currentDate) ?? currentDate
                let entry = createCyclingEntry(at: entryDate, cycleIndex: interval)
                entries.append(entry)
            }
        } else {
            // For medium and large collection widgets, update less frequently
            let entry = createCurrentEntry(at: currentDate)
            entries.append(entry)
            
            // Add daily updates for next 7 days
            for dayOffset in 1...7 {
                guard let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) else { continue }
                let midnightDate = Calendar.current.startOfDay(for: futureDate)
                let futureEntry = createCurrentEntry(at: midnightDate)
                entries.append(futureEntry)
            }
        }
        
        let refreshInterval: TimeInterval = context.family == .systemSmall ? 30 * 60 : 24 * 60 * 60 // 30 minutes for small, 24 hours for others
        let refreshDate = currentDate.addingTimeInterval(refreshInterval)
        
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func createCurrentEntry(at date: Date = Date()) -> FlowerWidgetEntry {
        let recentFlowers = dataProvider.getRecentFlowers(limit: 9)
        
        return FlowerWidgetEntry(
            date: date,
            mostRecentFlower: dataProvider.mostRecentFlower,
            pendingFlower: nil,
            hasUnrevealedFlower: false,
            nextFlowerTime: nil,
            recentFlowers: recentFlowers,
            totalCount: dataProvider.totalFlowersCount,
            favoritesCount: dataProvider.favoritesCount
        )
    }
    
    private func createCyclingEntry(at date: Date, cycleIndex: Int) -> FlowerWidgetEntry {
        let cyclingFlower = dataProvider.getCyclingFlower(at: cycleIndex)
        
        return FlowerWidgetEntry(
            date: date,
            mostRecentFlower: cyclingFlower,
            pendingFlower: nil,
            hasUnrevealedFlower: false,
            nextFlowerTime: nil,
            recentFlowers: [cyclingFlower].compactMap { $0 },
            totalCount: dataProvider.totalFlowersCount,
            favoritesCount: dataProvider.favoritesCount
        )
    }
}