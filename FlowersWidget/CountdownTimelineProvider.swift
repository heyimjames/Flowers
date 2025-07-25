//
//  CountdownTimelineProvider.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import WidgetKit
import SwiftUI

struct CountdownTimelineProvider: TimelineProvider {
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
        var entries: [FlowerWidgetEntry] = [currentEntry]
        let currentDate = Date()
        
        // For countdown widget, update frequently when there's a next flower time
        if let nextFlowerTime = dataProvider.nextFlowerTime, nextFlowerTime > currentDate {
            let timeUntilFlower = nextFlowerTime.timeIntervalSince(currentDate)
            
            // Add entries every minute for the next hour, or until flower time (whichever is shorter)
            let minutesToAdd = min(Int(timeUntilFlower / 60), 60)
            
            for minute in 1...minutesToAdd {
                if let futureDate = Calendar.current.date(byAdding: .minute, value: minute, to: currentDate) {
                    let entry = createCurrentEntry(at: futureDate)
                    entries.append(entry)
                }
            }
            
            // Add final entry for when flower is available
            if timeUntilFlower > 60 * 60 { // More than 1 hour away
                let finalEntry = createCurrentEntry(at: nextFlowerTime)
                entries.append(finalEntry)
            }
            
            // Refresh every minute for live countdown
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate) ?? currentDate
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
            return
        }
        
        // No countdown active - refresh less frequently
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func createCurrentEntry(at date: Date = Date()) -> FlowerWidgetEntry {
        let mostRecentFlower = dataProvider.mostRecentFlower
        let pendingFlower = dataProvider.pendingFlower
        let hasUnrevealedFlower = dataProvider.hasUnrevealedFlower
        let nextFlowerTime = dataProvider.nextFlowerTime
        
        // For countdown widgets, get recent flowers
        let recentFlowers = dataProvider.getRecentFlowers(limit: 9)
        
        print("CountdownTimelineProvider: Creating entry with \(dataProvider.totalFlowersCount) total flowers")
        print("CountdownTimelineProvider: Next flower time: \(nextFlowerTime?.description ?? "nil")")
        
        return FlowerWidgetEntry(
            date: date,
            mostRecentFlower: mostRecentFlower,
            pendingFlower: pendingFlower,
            hasUnrevealedFlower: hasUnrevealedFlower,
            nextFlowerTime: nextFlowerTime,
            recentFlowers: recentFlowers,
            totalCount: dataProvider.totalFlowersCount,
            favoritesCount: dataProvider.favoritesCount
        )
    }
}