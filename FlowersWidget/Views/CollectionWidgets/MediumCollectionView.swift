//
//  MediumCollectionView.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import WidgetKit

struct MediumCollectionView: View {
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            ForEach(Array(entry.recentFlowers.prefix(4).enumerated()), id: \.offset) { index, flower in
                flowerGridItem(flower: flower, index: index)
            }
            
            // Fill empty spots if needed
            if entry.recentFlowers.count < 4 {
                ForEach(entry.recentFlowers.count..<4, id: \.self) { _ in
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
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }
                
                // Overlays
                VStack {
                    HStack {
                        // Latest indicator for first item
                        if index == 0 {
                            Text("Latest")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.flowerPrimary)
                                .cornerRadius(8)
                        } else {
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // Favorite indicator
                        if flower.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(8)
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
                    .font(.system(size: 20))
                    .foregroundColor(.flowerTextSecondary.opacity(0.5))
            )
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "flower")
                .font(.system(size: 48))
                .foregroundColor(.flowerTextSecondary)
            
            VStack(spacing: 8) {
                Text("No Collection Yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                
                Text("Discover flowers to see them here in your collection grid")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    CollectionWidget()
} timeline: {
    // Create sample with multiple flowers
    let sampleFlowers = [
        AIFlower(name: "Rose", descriptor: "red rose", isFavorite: true),
        AIFlower(name: "Lily", descriptor: "white lily", isFavorite: false),
        AIFlower(name: "Tulip", descriptor: "yellow tulip", isFavorite: true),
        AIFlower(name: "Daisy", descriptor: "white daisy", isFavorite: false)
    ]
    
    FlowerWidgetEntry(
        date: Date(),
        mostRecentFlower: sampleFlowers.first,
        pendingFlower: nil,
        hasUnrevealedFlower: false,
        nextFlowerTime: nil,
        recentFlowers: sampleFlowers,
        totalCount: 12,
        favoritesCount: 4
    )
}