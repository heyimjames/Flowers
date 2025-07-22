import SwiftUI

struct DiscoveryProgressSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Discovery Progress")
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.flowerPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Main Progress Circle
                    let totalSpecies = BotanicalDatabase.shared.allSpecies.count
                    let discoveredCount = flowerStore.uniqueSpeciesDiscoveredCount
                    let percentage = Double(discoveredCount) / Double(totalSpecies)
                    
                    VStack(spacing: 16) {
                        Spacer().frame(height: 20)
                        
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color.flowerPrimary.opacity(0.1), lineWidth: 12)
                                .frame(width: 180, height: 180)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: percentage)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.flowerPrimary, Color.flowerSecondary],
                                        startPoint: .topTrailing,
                                        endPoint: .bottomLeading
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: percentage)
                            
                            // Center content
                            VStack(spacing: 4) {
                                Text("\(Int(percentage * 100))%")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                Text("discovered")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                        
                        Spacer().frame(height: 24)
                        
                        // Stats below circle
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                VStack(spacing: 4) {
                                    Text("\(discoveredCount)")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    Text("unique species")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                                
                                Rectangle()
                                    .fill(Color.flowerTextTertiary.opacity(0.3))
                                    .frame(width: 1, height: 40)
                                
                                VStack(spacing: 4) {
                                    Text("\(totalSpecies)")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    Text("total species")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                                
                                Rectangle()
                                    .fill(Color.flowerTextTertiary.opacity(0.3))
                                    .frame(width: 1, height: 40)
                                
                                VStack(spacing: 4) {
                                    Text("\(flowerStore.totalDiscoveredCount)")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    Text("total flowers")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                    
                    // Progress Categories
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Breakdown")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.flowerTextPrimary)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            // Rarity breakdown
                            ForEach(RarityLevel.allCases, id: \.self) { rarity in
                                let raritySpecies = BotanicalDatabase.shared.getSpeciesByRarity(rarity)
                                let discoveredInRarity = flowerStore.discoveredFlowers.filter { 
                                    $0.rarityLevel == rarity 
                                }.compactMap { $0.scientificName }
                                let uniqueDiscoveredInRarity = Set(discoveredInRarity).count
                                
                                ProgressCategoryRow(
                                    title: rarity.rawValue,
                                    discovered: uniqueDiscoveredInRarity,
                                    total: raritySpecies.count,
                                    color: rarityColor(for: rarity),
                                    emoji: rarity.emoji
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Discovery Locations
                    if !flowerStore.discoveryLocationStats.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Discovery Locations")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.flowerTextPrimary)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(flowerStore.discoveryLocationStats.sorted(by: { 
                                        if $0.value == $1.value {
                                            return $0.key < $1.key // Secondary sort by location name for stability
                                        }
                                        return $0.value > $1.value // Primary sort by count descending
                                    }).prefix(10), id: \.key) { location, count in
                                        VStack(spacing: 4) {
                                            Text("\(count)")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.flowerPrimary)
                                            Text(location)
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(.flowerTextSecondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.flowerPrimary.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                    
                    // Fun Facts
                    if discoveredCount > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fun Facts")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.flowerTextPrimary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 8) {
                                if let oldestFlower = flowerStore.discoveredFlowers.min(by: { $0.generatedDate < $1.generatedDate }) {
                                    FactRow(
                                        icon: "clock.arrow.circlepath",
                                        title: "First Discovery",
                                        description: "\(oldestFlower.name) on \(oldestFlower.generatedDate.formatted(date: .abbreviated, time: .omitted))"
                                    )
                                }
                                
                                if let newestFlower = flowerStore.discoveredFlowers.max(by: { $0.generatedDate < $1.generatedDate }) {
                                    FactRow(
                                        icon: "sparkles",
                                        title: "Latest Discovery",
                                        description: "\(newestFlower.name) on \(newestFlower.generatedDate.formatted(date: .abbreviated, time: .omitted))"
                                    )
                                }
                                
                                let uniqueLocations = Set(flowerStore.discoveredFlowers.compactMap { $0.discoveryLocationName }).count
                                if uniqueLocations > 0 {
                                    FactRow(
                                        icon: "location.fill",
                                        title: "Discovery Locations",
                                        description: "Found flowers in \(uniqueLocations) different locations"
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color.flowerSheetBackground)
    }
    
    private func rarityColor(for rarity: RarityLevel) -> Color {
        switch rarity {
        case .common: return .green
        case .uncommon: return .blue
        case .rare: return .purple
        case .veryRare: return .orange
        case .endangered: return .red
        case .extinct: return .gray
        }
    }
}

struct ProgressCategoryRow: View {
    let title: String
    let discovered: Int
    let total: Int
    let color: Color
    let emoji: String
    
    var progress: Double {
        total > 0 ? Double(discovered) / Double(total) : 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji and title
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                    .lineLimit(1)
                    .frame(minWidth: 100, alignment: .leading)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(color.opacity(0.1))
                        .frame(height: 8)
                    
                    // Progress fill
                    Capsule()
                        .fill(color)
                        .frame(width: progress * geometry.size.width, height: 8)
                        .animation(.easeInOut(duration: 0.8), value: progress)
                }
                .clipShape(Capsule())
            }
            .frame(height: 8)
            
            // Numbers
            Text("\(discovered)/\(total)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.flowerTextSecondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

struct FactRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.flowerPrimary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                
                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.flowerCardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    DiscoveryProgressSheet(flowerStore: FlowerStore())
}