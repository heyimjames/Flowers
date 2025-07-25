//
//  SmallCollectionView.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import WidgetKit

struct SmallCollectionView: View {
    let entry: FlowerWidgetEntry
    private let dataProvider = WidgetDataProvider.shared
    
    var body: some View {
        ZStack {
            // Clear background for widget
            Color.clear
            
            if let flower = entry.mostRecentFlower {
                // Show cycling flower - full image
                cyclingFlowerView(flower: flower)
            } else {
                // Empty state
                emptyStateView
            }
        }
        .widgetURL(widgetURL)
    }
    
    // MARK: - Cycling Flower View
    
    private func cyclingFlowerView(flower: AIFlower) -> some View {
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
            
            // Collection indicator overlay
            VStack {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flower")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                        
                        Text("\(entry.totalCount)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Favorite indicator
                if flower.isFavorite {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(8)
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
        if let flower = entry.mostRecentFlower {
            // Deep link to specific flower in collection
            return URL(string: "flowers://flower/\(flower.id.uuidString)")
        } else {
            // Deep link to collection
            return URL(string: "flowers://collection")
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    CollectionWidget()
} timeline: {
    WidgetDataProvider.sampleEntry()
}