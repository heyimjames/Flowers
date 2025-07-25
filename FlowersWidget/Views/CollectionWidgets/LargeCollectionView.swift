//
//  LargeCollectionView.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import WidgetKit

struct LargeCollectionView: View {
    let entry: FlowerWidgetEntry
    private let dataProvider = WidgetDataProvider.shared
    
    var body: some View {
        ZStack {
            // Clear background for widget
            Color.clear
            
            if !entry.recentFlowers.isEmpty {
                // Show flower grid
                flowerGridView
            } else {
                // Empty state
                emptyStateView
            }
        }
        .widgetURL(URL(string: "flowers://collection"))
    }
    
    // MARK: - Flower Grid View
    
    private var flowerGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(Array(entry.recentFlowers.prefix(9).enumerated()), id: \.offset) { index, flower in
                flowerGridItem(flower: flower, index: index)
            }
            
            // Fill empty spots if needed
            if entry.recentFlowers.count < 9 {
                ForEach(entry.recentFlowers.count..<9, id: \.self) { _ in
                    emptyGridItem
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Flower Grid Item
    
    private func flowerGridItem(flower: AIFlower, index: Int) -> some View {
        Link(destination: URL(string: "flowers://flower/\(flower.id.uuidString)") ?? URL(string: "flowers://collection")!) {
            ZStack {
                if let imageData = flower.imageData,
                   let image = dataProvider.image(from: imageData) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    // Placeholder with weather gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: WeatherGradientService.getSimplifiedWeatherGradient(
                                condition: flower.discoveryWeatherCondition,
                                temperature: flower.discoveryTemperature
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "flower.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }
                
                // Subtle overlays only for important info
                VStack {
                    HStack {
                        // Recent indicator for first item
                        if index == 0 {
                            Text("Latest")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.flowerPrimary)
                                .cornerRadius(6)
                        } else {
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // Favorite indicator
                        if flower.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(6)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Empty Grid Item
    
    private var emptyGridItem: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.flowerTextSecondary.opacity(0.1))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "plus")
                    .font(.system(size: 18))
                    .foregroundColor(.flowerTextSecondary.opacity(0.5))
            )
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "flower")
                    .font(.system(size: 72))
                    .foregroundColor(.flowerTextSecondary)
                
                VStack(spacing: 8) {
                    Text("Build Your Garden")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.flowerTextPrimary)
                    
                    Text("Start collecting beautiful flowers to fill this garden grid with your discoveries")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            // Grid preview with placeholders
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.flowerTextSecondary.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: index == 4 ? "flower" : "plus")
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary.opacity(0.3))
                        )
                }
            }
            .frame(maxWidth: 200)
            
            Text("Tap to start discovering")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.flowerPrimary)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    CollectionWidget()
} timeline: {
    // Create sample with many flowers
    let sampleFlowers = (1...9).map { index in
        AIFlower(
            name: "Flower \(index)",
            descriptor: "beautiful flower \(index)",
            isFavorite: index % 3 == 0,
            discoveryDayOfWeek: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"][index % 5]
        )
    }
    
    FlowerWidgetEntry(
        date: Date(),
        mostRecentFlower: sampleFlowers.first,
        pendingFlower: nil,
        hasUnrevealedFlower: false,
        nextFlowerTime: nil,
        recentFlowers: sampleFlowers,
        totalCount: 24,
        favoritesCount: 8
    )
}