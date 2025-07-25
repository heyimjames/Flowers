//
//  SmallCountdownFlowerView.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import WidgetKit

struct SmallCountdownFlowerView: View {
    let entry: FlowerWidgetEntry
    private let dataProvider = WidgetDataProvider.shared
    
    var body: some View {
        ZStack {
            // Clear background for widget
            Color.clear
            
            if let nextFlowerTime = entry.nextFlowerTime, nextFlowerTime > Date() {
                // Show countdown with blurred flower background
                countdownView(nextFlowerTime: nextFlowerTime)
            } else if let flower = entry.mostRecentFlower {
                // Fall back to most recent flower if no countdown
                fullFlowerImageView(flower: flower)
            } else {
                // Empty state
                emptyStateView
            }
        }
        .widgetURL(widgetURL)
    }
    
    // MARK: - Countdown View
    
    private func countdownView(nextFlowerTime: Date) -> some View {
        ZStack {
            // Blurred background flower image
            if let flower = entry.mostRecentFlower {
                if let imageData = flower.imageData,
                   let image = dataProvider.image(from: imageData) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .blur(radius: 8)
                        .opacity(0.6)
                } else {
                    // Placeholder blurred background
                    LinearGradient(
                        colors: WeatherGradientService.getSimplifiedWeatherGradient(
                            condition: flower.discoveryWeatherCondition,
                            temperature: flower.discoveryTemperature
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 4)
                    .opacity(0.7)
                }
            } else {
                // Generic blurred background
                LinearGradient(
                    colors: [Color.flowerPrimary.opacity(0.3), Color.flowerSecondary.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blur(radius: 4)
            }
            
            // Dark overlay for text readability
            Color.black.opacity(0.3)
            
            // Countdown content
            VStack(spacing: 8) {
                // Flower icon
                Image(systemName: "flower.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                // "Next Flower" text
                Text("Next Flower")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                
                // Countdown timer
                Text(timeUntil(nextFlowerTime))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Full Flower Image View (Fallback)
    
    private func fullFlowerImageView(flower: AIFlower) -> some View {
        ZStack {
            if let imageData = flower.imageData,
               let image = dataProvider.image(from: imageData) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                // Placeholder with weather gradient background
                LinearGradient(
                    colors: WeatherGradientService.getSimplifiedWeatherGradient(
                        condition: flower.discoveryWeatherCondition,
                        temperature: flower.discoveryTemperature
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: "flower.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Subtle overlay for favorites
            if flower.isFavorite {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [Color.flowerPrimary.opacity(0.1), Color.flowerPrimary.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 36))
                    .foregroundColor(.flowerPrimary.opacity(0.6))
                
                Text("No Timer")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func timeUntil(_ date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "Available!"
        }
        
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK: - Deep Link URL
    
    private var widgetURL: URL? {
        if entry.nextFlowerTime != nil && entry.nextFlowerTime! > Date() {
            // Deep link to main app to see countdown
            return URL(string: "flowers://home")
        } else if let flower = entry.mostRecentFlower {
            // Deep link to specific flower
            return URL(string: "flowers://flower/\(flower.id.uuidString)")
        } else {
            // Deep link to main app
            return URL(string: "flowers://home")
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    CountdownWidget()
} timeline: {
    // Sample with countdown
    FlowerWidgetEntry(
        date: Date(),
        mostRecentFlower: WidgetDataProvider.sampleEntry().mostRecentFlower,
        pendingFlower: nil,
        hasUnrevealedFlower: false,
        nextFlowerTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
        recentFlowers: WidgetDataProvider.sampleEntry().recentFlowers,
        totalCount: 5,
        favoritesCount: 2
    )
    
    // Sample without countdown
    WidgetDataProvider.sampleEntry()
}