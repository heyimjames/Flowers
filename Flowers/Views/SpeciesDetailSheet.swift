import SwiftUI

struct SpeciesDetailSheet: View {
    let species: SpeciesGroup
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlowerIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with image carousel
                    if species.allFlowers.count > 1 {
                        TabView(selection: $selectedFlowerIndex) {
                            ForEach(Array(species.allFlowers.enumerated()), id: \.offset) { index, flower in
                                FlowerImageView(flower: flower)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 300)
                    } else {
                        FlowerImageView(flower: species.representativeFlower)
                            .frame(height: 300)
                    }
                    
                    // Species information
                    VStack(alignment: .leading, spacing: 24) {
                        // Title section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(species.commonName)
                                        .font(.system(size: 32, weight: .light, design: .serif))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text(species.scientificName)
                                        .font(.system(size: 18, design: .serif))
                                        .foregroundColor(.flowerTextSecondary)
                                        .italic()
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 8) {
                                    // Rarity indicator
                                    if let rarity = species.rarityLevel {
                                        VStack(spacing: 4) {
                                            Text(rarity.emoji)
                                                .font(.system(size: 24))
                                            
                                            Text(rarity.rawValue)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.flowerTextSecondary)
                                        }
                                    }
                                    
                                    // Herbarium status button
                                    Button(action: toggleHerbariumStatus) {
                                        VStack(spacing: 4) {
                                            Image(systemName: species.isInHerbarium ? "checkmark.circle.fill" : "plus.circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(species.isInHerbarium ? .green : .flowerPrimary)
                                            
                                            Text(species.isInHerbarium ? "Collected" : "Collect")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(species.isInHerbarium ? .green : .flowerPrimary)
                                        }
                                    }
                                }
                            }
                            
                            if let family = species.family {
                                Text("Family: \(family)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                        
                        // Discovery stats
                        HStack(spacing: 24) {
                            StatItem(
                                title: "Discovered",
                                value: "\(species.discoveryCount)",
                                subtitle: species.discoveryCount == 1 ? "time" : "times"
                            )
                            
                            StatItem(
                                title: "First Found",
                                value: species.firstDiscovered.formatted(date: .abbreviated, time: .omitted),
                                subtitle: ""
                            )
                        }
                        
                        Divider()
                        
                        // Botanical information
                        if let flower = species.allFlowers.first {
                            VStack(alignment: .leading, spacing: 20) {
                                if let commonNames = flower.commonNames, commonNames.count > 1 {
                                    InfoSection(
                                        title: "Common Names",
                                        content: commonNames.joined(separator: " • "),
                                        icon: "textformat"
                                    )
                                }
                                
                                if let nativeRegions = flower.nativeRegions, !nativeRegions.isEmpty {
                                    InfoSection(
                                        title: "Native Regions",
                                        content: nativeRegions.joined(separator: ", "),
                                        icon: "globe"
                                    )
                                }
                                
                                if let bloomingSeason = flower.bloomingSeason {
                                    InfoSection(
                                        title: "Blooming Season",
                                        content: bloomingSeason,
                                        icon: "calendar"
                                    )
                                }
                                
                                if let uses = flower.uses, !uses.isEmpty {
                                    InfoSection(
                                        title: "Uses",
                                        content: uses.joined(separator: " • "),
                                        icon: "leaf"
                                    )
                                }
                                
                                if let meaning = flower.meaning {
                                    InfoSection(
                                        title: "Meaning & Symbolism",
                                        content: meaning,
                                        icon: "heart"
                                    )
                                }
                                
                                if let properties = flower.properties {
                                    InfoSection(
                                        title: "Characteristics",
                                        content: properties,
                                        icon: "info.circle"
                                    )
                                }
                                
                                if let origins = flower.origins {
                                    InfoSection(
                                        title: "Origins & History",
                                        content: origins,
                                        icon: "map"
                                    )
                                }
                                
                                if let facts = flower.interestingFacts, !facts.isEmpty {
                                    InfoSection(
                                        title: "Interesting Facts",
                                        content: facts.joined(separator: "\n\n"),
                                        icon: "lightbulb"
                                    )
                                }
                                
                                if let care = flower.careInstructions {
                                    InfoSection(
                                        title: "Growing Tips",
                                        content: care,
                                        icon: "hand.raised"
                                    )
                                }
                                
                                if let conservation = flower.conservationStatus {
                                    InfoSection(
                                        title: "Conservation Status",
                                        content: conservation,
                                        icon: "shield"
                                    )
                                }
                            }
                        }
                        
                        // Discovery timeline if multiple instances
                        if species.allFlowers.count > 1 {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Discovery Timeline")
                                    .font(.system(size: 20, weight: .light, design: .serif))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                ForEach(Array(species.allFlowers.enumerated()), id: \.offset) { index, flower in
                                    DiscoveryTimelineItem(
                                        flower: flower,
                                        index: index + 1,
                                        isLatest: index == 0
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: shareSpecies) {
                            Label("Share Species", systemImage: "square.and.arrow.up")
                        }
                        
                        if let selectedFlower = species.allFlowers[safe: selectedFlowerIndex] {
                            Button(action: { shareFlower(selectedFlower) }) {
                                Label("Share This Discovery", systemImage: "flower")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    private func toggleHerbariumStatus() {
        let representative = species.representativeFlower
        
        if species.isInHerbarium {
            flowerStore.removeFromHerbarium(representative)
        } else {
            flowerStore.addToHerbarium(representative)
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func shareSpecies() {
        // Share information about the species
        let text = "Check out this beautiful \(species.commonName) (\(species.scientificName)) I discovered in my Herbarium! 🌸"
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func shareFlower(_ flower: AIFlower) {
        // Share specific flower instance
        // This would integrate with the existing flower sharing system
    }
}

// MARK: - Supporting Views

struct FlowerImageView: View {
    let flower: AIFlower
    
    var body: some View {
        if let imageData = flower.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.flowerInputBackground)
                .overlay(
                    Image(systemName: "flower")
                        .font(.system(size: 48))
                        .foregroundColor(.flowerTextTertiary)
                )
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.flowerTextTertiary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.flowerTextPrimary)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.flowerTextSecondary)
            }
        }
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.flowerPrimary)
                
                Text(title)
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.flowerTextSecondary)
                .lineSpacing(4)
        }
    }
}

struct DiscoveryTimelineItem: View {
    let flower: AIFlower
    let index: Int
    let isLatest: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Timeline indicator
            VStack {
                Circle()
                    .fill(isLatest ? Color.flowerPrimary : Color.flowerTextTertiary)
                    .frame(width: 8, height: 8)
                
                if !isLatest {
                    Rectangle()
                        .fill(Color.flowerTextTertiary.opacity(0.3))
                        .frame(width: 1, height: 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Discovery #\(index)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.flowerTextPrimary)
                    
                    if isLatest {
                        Text("Latest")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.flowerPrimary)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                
                Text((flower.discoveryDate ?? flower.generatedDate).formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundColor(.flowerTextSecondary)
                
                if let location = flower.discoveryLocationName {
                    Text(location)
                        .font(.system(size: 12))
                        .foregroundColor(.flowerTextTertiary)
                }
            }
            
            Spacer()
        }
    }
}

// Safe array subscript extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}