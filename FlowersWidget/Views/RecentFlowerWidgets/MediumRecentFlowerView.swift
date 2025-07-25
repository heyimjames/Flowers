//
//  MediumRecentFlowerView.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import WidgetKit

struct MediumRecentFlowerView: View {
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
                // Show most recent flower
                recentFlowerView(flower: flower)
            } else {
                // Empty state
                emptyStateView
            }
        }
        .widgetURL(widgetURL)
    }
    
    // MARK: - Recent Flower View
    
    private func recentFlowerView(flower: AIFlower) -> some View {
        HStack(spacing: 16) {
            // Flower image - left side with rounded corners
            ZStack {
                if let imageData = flower.imageData,
                   let image = dataProvider.image(from: imageData) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    // Placeholder with weather gradient background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: WeatherGradientService.getSimplifiedWeatherGradient(
                                condition: flower.discoveryWeatherCondition,
                                temperature: flower.discoveryTemperature
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "flower.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }
                
                // Favorite indicator
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
            
            // Info section - right side
            VStack(alignment: .leading, spacing: 8) {
                // Flower name
                Text(flower.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                    .lineLimit(2)
                
                // Discovery date
                if let date = flower.discoveryFormattedDate {
                    Text("Discovered \(date)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.flowerTextSecondary)
                }
                
                // Location info
                if let location = dataProvider.locationString(for: flower) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.flowerTextSecondary)
                        
                        Text(location)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                            .lineLimit(1)
                    }
                }
                
                // Weather info
                let weatherInfo = dataProvider.weatherInfo(for: flower)
                if let condition = weatherInfo.condition, let temperature = weatherInfo.temperature {
                    HStack(spacing: 6) {
                        Image(systemName: WeatherGradientService.getWeatherIcon(for: condition))
                            .font(.system(size: 12))
                            .foregroundColor(WeatherGradientService.getIconColor(for: condition))
                        
                        Text("\(condition), \(temperature)")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
                
                Spacer()
                
                // Collection stats
                HStack(spacing: 12) {
                    Text("\(entry.totalCount) flowers")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.flowerTextSecondary)
                    
                    if entry.favoritesCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.flowerPrimary)
                            
                            Text("\(entry.favoritesCount)")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.flowerPrimary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Unrevealed Flower View
    
    private var unrevealedFlowerView: some View {
        HStack(spacing: 16) {
            // Blurred flower image
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.flowerPrimary.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                // Blur effect overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground).opacity(0.8))
                    .blur(radius: 12)
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4) {
                    Image(systemName: "flower.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.flowerPrimary)
                    
                    Text("?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.flowerPrimary)
                }
            }
            
            // Info section
            VStack(alignment: .leading, spacing: 8) {
                Text("New Flower Available!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                
                Text("A beautiful surprise is waiting for you")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .lineLimit(2)
                
                Spacer()
                
                Text("Tap to reveal")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.flowerPrimary.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        HStack(spacing: 16) {
            // Empty image placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.flowerPrimary.opacity(0.1), Color.flowerPrimary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "flower")
                        .font(.system(size: 36))
                        .foregroundColor(.flowerPrimary.opacity(0.6))
                )
            
            // Info section
            VStack(alignment: .leading, spacing: 8) {
                Text("No Flowers Yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                
                Text("Open the app to discover your first flower")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .lineLimit(2)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Deep Link URL
    
    private var widgetURL: URL? {
        if entry.hasUnrevealedFlower {
            return URL(string: "flowers://reveal")
        } else if let flower = entry.mostRecentFlower {
            return URL(string: "flowers://flower/\(flower.id.uuidString)")
        } else {
            return URL(string: "flowers://home")
        }
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    FlowersWidget()
} timeline: {
    WidgetDataProvider.sampleEntry()
    WidgetDataProvider.sampleUnrevealedEntry()
}