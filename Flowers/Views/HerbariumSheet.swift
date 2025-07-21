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
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.flowerTextSecondary)
                        }
                        
                        Spacer()
                        
                        // Progress indicator
                        VStack(spacing: 2) {
                            Text("\(String(format: "%.1f", flowerStore.herbariumCompletionPercentage))%")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
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
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
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
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 120) // Extra space for navigation
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
                    .font(.system(size: 12, weight: .medium, design: .rounded))
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
            VStack(alignment: .leading, spacing: 0) {
                // Flower image with overlay badges
                ZStack {
                    if let imageData = species.representativeFlower.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.flowerInputBackground)
                            .frame(height: 140)
                            .overlay(
                                Image(systemName: "flower")
                                    .font(.system(size: 36))
                                    .foregroundColor(.flowerTextTertiary)
                            )
                    }
                    
                    // Overlay badges
                    VStack {
                        HStack {
                            // Rarity badge
                            if let rarity = species.rarityLevel {
                                HStack(spacing: 4) {
                                    Text(rarity.emoji)
                                        .font(.system(size: 12, design: .rounded))
                                    
                                    if rarity.sortOrder >= RarityLevel.rare.sortOrder {
                                        Text(rarity.rawValue)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.7))
                                )
                            }
                            
                            Spacer()
                            
                            // Collection status
                            Image(systemName: species.isInHerbarium ? "checkmark.circle.fill" : "plus.circle")
                                .font(.system(size: 20))
                                .foregroundColor(species.isInHerbarium ? .green : .white)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 32, height: 32)
                                )
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 12)
                        
                        Spacer()
                        
                        // Discovery count badge
                        if species.discoveryCount > 1 {
                            HStack {
                                Spacer()
                                
                                Text("\(species.discoveryCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .fill(Color.flowerPrimary)
                                    )
                                    .padding(.trailing, 12)
                                    .padding(.bottom, 12)
                            }
                        }
                    }
                }
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Information section
                VStack(alignment: .leading, spacing: 6) {
                    // Common name
                    Text(species.commonName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.flowerTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Scientific name
                    Text(species.scientificName)
                        .font(.system(size: 13, design: .serif))
                        .foregroundColor(.flowerTextSecondary)
                        .italic()
                        .lineLimit(1)
                    
                    // Family
                    if let family = species.family {
                        Text(family)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.flowerTextTertiary)
                            .lineLimit(1)
                    }
                    
                    // First discovered date
                    Text("Discovered \(species.firstDiscovered.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 11))
                        .foregroundColor(.flowerPrimary)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.flowerCardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: species.isInHerbarium)
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