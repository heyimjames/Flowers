//
//  SmallRecentFlowerView.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import WidgetKit

struct SmallRecentFlowerView: View {
    let entry: FlowerWidgetEntry
    private let dataProvider = WidgetDataProvider.shared
    
    var body: some View {
        ZStack {
            // Clear background for widget
            Color.clear
            
            if entry.hasUnrevealedFlower {
                // Show unrevealed flower state
                unrevealedFlowerView
            } else if let flower = entry.mostRecentFlower {
                // Show full flower image
                fullFlowerImageView(flower: flower)
            } else {
                // Empty state
                emptyStateView
            }
        }
        .widgetURL(widgetURL)
    }
    
    // MARK: - Full Flower Image View
    
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
    
    // MARK: - Unrevealed Flower View
    
    private var unrevealedFlowerView: some View {
        ZStack {
            // Mystery gradient background
            LinearGradient(
                colors: [Color.flowerPrimary.opacity(0.4), Color.flowerSecondary.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Blur effect for mystery
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .blur(radius: 20)
            
            VStack(spacing: 12) {
                Image(systemName: "flower.fill")
                    .font(.system(size: 42))
                    .foregroundColor(.flowerPrimary.opacity(0.8))
                
                Text("?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.flowerPrimary)
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
                Image(systemName: "flower")
                    .font(.system(size: 36))
                    .foregroundColor(.flowerPrimary.opacity(0.6))
                
                Text("No Flowers")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Deep Link URL
    
    private var widgetURL: URL? {
        if entry.hasUnrevealedFlower {
            // Deep link to reveal flower
            return URL(string: "flowers://reveal")
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
    FlowersWidget()
} timeline: {
    WidgetDataProvider.sampleEntry()
    WidgetDataProvider.sampleUnrevealedEntry()
}