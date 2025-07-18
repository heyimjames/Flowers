import SwiftUI

struct HerbariumSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: HerbariumFilter = .all
    @State private var searchText = ""
    @State private var selectedSpecies: SpeciesGroup?
    @State private var showingSpeciesDetail = false
    
    // Group flowers by species
    private var speciesGroups: [SpeciesGroup] {
        let grouped = Dictionary(grouping: flowerStore.discoveredFlowers) { flower in
            flower.scientificName ?? "Unknown species"
        }
        
        return grouped.compactMap { (scientificName, flowers) -> SpeciesGroup? in
            guard let firstFlower = flowers.first else { return nil }
            
            let group = SpeciesGroup(
                scientificName: scientificName,
                commonName: firstFlower.commonNames?.first ?? firstFlower.name,
                family: firstFlower.family,
                rarityLevel: firstFlower.rarityLevel,
                isInHerbarium: flowerStore.isSpeciesInHerbarium(scientificName),
                discoveryCount: flowers.count,
                firstDiscovered: flowers.min(by: { 
                    ($0.discoveryDate ?? $0.generatedDate) < ($1.discoveryDate ?? $1.generatedDate) 
                })?.discoveryDate ?? flowers.first?.generatedDate ?? Date(),
                representativeFlower: firstFlower,
                allFlowers: flowers.sorted { 
                    ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
                }
            )
            
            return group
        }
        .sorted { first, second in
            // Sort by rarity first, then by discovery date
            if let firstRarity = first.rarityLevel, let secondRarity = second.rarityLevel {
                if firstRarity.sortOrder != secondRarity.sortOrder {
                    return firstRarity.sortOrder > secondRarity.sortOrder
                }
            }
            return first.firstDiscovered > second.firstDiscovered
        }
    }
    
    private var filteredSpecies: [SpeciesGroup] {
        var filtered = speciesGroups
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .collected:
            filtered = filtered.filter { $0.isInHerbarium }
        case .uncollected:
            filtered = filtered.filter { !$0.isInHerbarium }
        case .rare:
            filtered = filtered.filter { 
                guard let rarity = $0.rarityLevel else { return false }
                return rarity.sortOrder >= RarityLevel.rare.sortOrder
            }
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { species in
                species.commonName.localizedCaseInsensitiveContains(searchText) ||
                species.scientificName.localizedCaseInsensitiveContains(searchText) ||
                (species.family?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Herbarium")
                                .font(.system(size: 28, weight: .light, design: .serif))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Text("\(flowerStore.herbariumSpeciesCount) species collected")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextSecondary)
                        }
                        
                        Spacer()
                        
                        // Progress indicator
                        VStack(spacing: 2) {
                            Text("\(String(format: "%.1f", flowerStore.herbariumCompletionPercentage))%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.flowerPrimary)
                            
                            ProgressView(value: flowerStore.herbariumCompletionPercentage / 100.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .flowerPrimary))
                                .frame(width: 40)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.flowerTextTertiary)
                        
                        TextField("Search species...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.flowerInputBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(HerbariumFilter.allCases, id: \.self) { filter in
                                FilterPill(
                                    title: filter.displayName,
                                    count: countForFilter(filter),
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 20)
                .background(Color.flowerSheetBackground)
                
                // Species grid
                if filteredSpecies.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "leaf")
                            .font(.system(size: 48))
                            .foregroundColor(.flowerTextTertiary)
                        
                        Text(searchText.isEmpty ? "Start discovering flowers to build your herbarium" : "No species found")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerTextSecondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(filteredSpecies, id: \.scientificName) { species in
                                SpeciesCard(
                                    species: species,
                                    action: {
                                        selectedSpecies = species
                                        showingSpeciesDetail = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100) // Extra space for navigation
                    }
                }
            }
            .background(Color.flowerBackground)
        }
        .sheet(isPresented: $showingSpeciesDetail) {
            if let species = selectedSpecies {
                SpeciesDetailSheet(species: species, flowerStore: flowerStore)
            }
        }
    }
    
    private func countForFilter(_ filter: HerbariumFilter) -> Int {
        switch filter {
        case .all:
            return speciesGroups.count
        case .collected:
            return speciesGroups.filter { $0.isInHerbarium }.count
        case .uncollected:
            return speciesGroups.filter { !$0.isInHerbarium }.count
        case .rare:
            return speciesGroups.filter { 
                guard let rarity = $0.rarityLevel else { return false }
                return rarity.sortOrder >= RarityLevel.rare.sortOrder
            }.count
        }
    }
}

// MARK: - Supporting Types

struct SpeciesGroup {
    let scientificName: String
    let commonName: String
    let family: String?
    let rarityLevel: RarityLevel?
    let isInHerbarium: Bool
    let discoveryCount: Int
    let firstDiscovered: Date
    let representativeFlower: AIFlower
    let allFlowers: [AIFlower]
}

enum HerbariumFilter: CaseIterable {
    case all, collected, uncollected, rare
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .collected: return "Collected"
        case .uncollected: return "Uncollected"
        case .rare: return "Rare"
        }
    }
}

// MARK: - Components

struct FilterPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.2) : Color.flowerPrimary.opacity(0.1))
                    .cornerRadius(8)
            }
            .foregroundColor(isSelected ? .white : .flowerPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.flowerPrimary : Color.flowerPrimary.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

struct SpeciesCard: View {
    let species: SpeciesGroup
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Flower image
                if let imageData = species.representativeFlower.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                } else {
                    Rectangle()
                        .fill(Color.flowerInputBackground)
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "flower")
                                .font(.system(size: 32))
                                .foregroundColor(.flowerTextTertiary)
                        )
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Rarity and collection status
                    HStack {
                        if let rarity = species.rarityLevel {
                            Text(rarity.emoji)
                                .font(.system(size: 16))
                        }
                        
                        Spacer()
                        
                        if species.isInHerbarium {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextTertiary)
                        }
                    }
                    
                    // Names
                    Text(species.commonName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.flowerTextPrimary)
                        .lineLimit(1)
                    
                    Text(species.scientificName)
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(.flowerTextSecondary)
                        .italic()
                        .lineLimit(1)
                    
                    if let family = species.family {
                        Text(family)
                            .font(.system(size: 11))
                            .foregroundColor(.flowerTextTertiary)
                            .lineLimit(1)
                    }
                    
                    // Discovery count
                    if species.discoveryCount > 1 {
                        Text("\(species.discoveryCount) discovered")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.flowerPrimary)
                            .padding(.top, 2)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color.flowerCardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// Extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}