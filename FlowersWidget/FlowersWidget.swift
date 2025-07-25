//
//  FlowersWidget.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import WidgetKit
import SwiftUI

// MARK: - Recent Flower Widget

struct FlowersWidgetEntryView: View {
    var entry: FlowerWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallRecentFlowerView(entry: entry)
        case .systemMedium:
            MediumRecentFlowerView(entry: entry)
        case .systemLarge:
            LargeRecentFlowerView(entry: entry)
        default:
            SmallRecentFlowerView(entry: entry)
        }
    }
}

struct FlowersWidget: Widget {
    let kind: String = "RecentFlowerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FlowerTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                FlowersWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FlowersWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Recent Flower")
        .description("Shows your most recent flower discovery or pending flower ready to reveal.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Collection Widget

struct CollectionWidgetEntryView: View {
    var entry: FlowerWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallCollectionView(entry: entry)
        case .systemMedium:
            MediumCollectionView(entry: entry)
        case .systemLarge:
            LargeCollectionView(entry: entry)
        default:
            SmallCollectionView(entry: entry)
        }
    }
}

struct CollectionWidget: Widget {
    let kind: String = "CollectionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CollectionTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                CollectionWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CollectionWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Flower Collection")
        .description("Browse through your flower collection with cycling views and grids.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Countdown Widget

struct CountdownWidgetEntryView: View {
    var entry: FlowerWidgetEntry
    
    var body: some View {
        SmallCountdownFlowerView(entry: entry)
    }
}

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                CountdownWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CountdownWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Flower Countdown")
        .description("Shows a countdown timer to your next flower with a blurred flower background.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    FlowersWidget()
} timeline: {
    WidgetDataProvider.sampleEntry()
    WidgetDataProvider.sampleUnrevealedEntry()
}

#Preview(as: .systemMedium) {
    FlowersWidget()
} timeline: {
    WidgetDataProvider.sampleEntry()
    WidgetDataProvider.sampleUnrevealedEntry()
}

#Preview(as: .systemLarge) {
    FlowersWidget()
} timeline: {
    WidgetDataProvider.sampleEntry()
    WidgetDataProvider.sampleUnrevealedEntry()
}
