import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var starterFlowers: [AIFlower] = []
    @State private var selectedStarterIndex: Int?
    @State private var isGeneratingFlowers = false
    @State private var showingJennyFlower = true
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.flowerBackground, Color.flowerBackgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if showingJennyFlower {
                // Jenny flower presentation
                JennyFlowerView(
                    flowerStore: flowerStore,
                    onContinue: {
                        withAnimation {
                            showingJennyFlower = false
                        }
                        generateStarterFlowers()
                    }
                )
            } else {
                // Starter flower selection
                StarterFlowerSelectionView(
                    flowers: starterFlowers,
                    selectedIndex: $selectedStarterIndex,
                    isLoading: isGeneratingFlowers,
                    onSelect: { index in
                        selectStarterFlower(at: index)
                    }
                )
            }
        }
    }
    
    private func generateStarterFlowers() {
        isGeneratingFlowers = true
        
        Task {
            // Generate 3 unique starter flowers
            var flowers: [AIFlower] = []
            
            // Predefined starter themes for variety
            let starterThemes = [
                "vibrant sunrise colors with warm orange and pink petals",
                "deep ocean blues with silver-tipped petals like moonlight on water",
                "forest greens with golden accents like sunlight through leaves"
            ]
            
            for (index, theme) in starterThemes.enumerated() {
                do {
                    // Generate flower with theme
                    let name = try await OpenAIService.shared.generateFlowerName(descriptor: theme)
                    
                    // Generate image
                    let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: theme)
                    guard let imageData = image.pngData() else { continue }
                    
                    // Create flower with special first flower tag
                    var flower = AIFlower(
                        name: name,
                        descriptor: theme,
                        imageData: imageData,
                        generatedDate: Date(),
                        isFavorite: false,
                        discoveryDate: Date()
                    )
                    
                    // Add location data if available
                    if let location = ContextualFlowerGenerator.shared.currentLocation {
                        flower.discoveryLatitude = location.coordinate.latitude
                        flower.discoveryLongitude = location.coordinate.longitude
                        flower.discoveryLocationName = ContextualFlowerGenerator.shared.currentPlacemark?.locality
                    }
                    
                    flowers.append(flower)
                } catch {
                    print("Failed to generate starter flower \(index): \(error)")
                }
            }
            
            await MainActor.run {
                self.starterFlowers = flowers
                self.isGeneratingFlowers = false
            }
        }
    }
    
    private func selectStarterFlower(at index: Int) {
        guard index < starterFlowers.count else { return }
        
        var selectedFlower = starterFlowers[index]
        
        // Add special metadata for first flower
        selectedFlower.properties = "This was your very first flower, chosen at the beginning of your journey. 🌱"
        
        // Save the selected flower
        flowerStore.addToDiscoveredFlowers(selectedFlower)
        flowerStore.currentFlower = selectedFlower
        
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Dismiss onboarding
        dismiss()
    }
}

struct JennyFlowerView: View {
    @ObservedObject var flowerStore: FlowerStore
    let onContinue: () -> Void
    @State private var showContent = false
    
    var jennyFlower: AIFlower? {
        flowerStore.discoveredFlowers.first { $0.name == "Jennifer's Blessing" }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Flower image
                if let flower = jennyFlower,
                   let imageData = flower.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                } else {
                    // Loading state
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.flowerCardBackground)
                        .frame(width: 300, height: 300)
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.flowerPrimary)
                        )
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                }
                
                // Flower name
                Text("Jennifer's Blessing")
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .opacity(showContent ? 1 : 0)
                
                // Special message
                VStack(spacing: 16) {
                    Text("A Gift from James")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.flowerPrimary)
                    
                    Text("This special flower is named after my fiancée Jenny, whose kindness, beauty, and humor light up the lives of everyone she meets. Like this flower, she brings joy and wonder wherever she goes.")
                        .font(.system(size: 16))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text("First picked in Canary Wharf, London")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.flowerTextTertiary)
                    
                    Text("November 25, 2022")
                        .font(.system(size: 14))
                        .foregroundColor(.flowerTextTertiary)
                }
                .padding(.horizontal, 32)
                .opacity(showContent ? 1 : 0)
            }
            
            Spacer()
            
            // Continue button
            Button(action: onContinue) {
                HStack {
                    Text("Choose Your First Flower")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.flowerPrimary)
                .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
            
            Spacer().frame(height: 40)
        }
        .onAppear {
            // Check if Jenny flower exists
            if jennyFlower != nil {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    showContent = true
                }
            } else {
                // Check periodically for the flower
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    if jennyFlower != nil {
                        timer.invalidate()
                        withAnimation(.easeOut(duration: 0.8)) {
                            showContent = true
                        }
                    }
                }
            }
        }
    }
}

struct StarterFlowerSelectionView: View {
    let flowers: [AIFlower]
    @Binding var selectedIndex: Int?
    let isLoading: Bool
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            VStack(spacing: 12) {
                Text("Choose Your First Flower")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.flowerTextPrimary)
                
                Text("Select the flower that speaks to you")
                    .font(.system(size: 16))
                    .foregroundColor(.flowerTextSecondary)
            }
            .padding(.top, 60)
            
            if isLoading {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.flowerPrimary)
                    
                    Text("Growing your starter flowers...")
                        .font(.system(size: 16))
                        .foregroundColor(.flowerTextSecondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Flower cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(flowers.enumerated()), id: \.element.id) { index, flower in
                            StarterFlowerCard(
                                flower: flower,
                                isSelected: selectedIndex == index,
                                onTap: {
                                    withAnimation(.spring()) {
                                        selectedIndex = index
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .frame(maxHeight: .infinity)
                
                // Select button
                if selectedIndex != nil {
                    Button(action: {
                        if let index = selectedIndex {
                            onSelect(index)
                        }
                    }) {
                        HStack {
                            Text("Begin Your Journey")
                            Image(systemName: "sparkles")
                        }
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.flowerPrimary)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            Spacer()
        }
    }
}

struct StarterFlowerCard: View {
    let flower: AIFlower
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Flower image
            if let imageData = flower.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 220, height: 220)
                    .clipped()
                    .cornerRadius(20)
            }
            
            // Flower name
            Text(flower.name)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(.flowerTextPrimary)
                .multilineTextAlignment(.center)
            
            // Theme hint
            Text(getThemeHint(for: flower))
                .font(.system(size: 14))
                .foregroundColor(.flowerTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(
                    color: isSelected ? Color.flowerPrimary.opacity(0.3) : Color.black.opacity(0.1),
                    radius: isSelected ? 20 : 10,
                    y: 5
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    isSelected ? Color.flowerPrimary : Color.clear,
                    lineWidth: 3
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1)
        .onTapGesture(perform: onTap)
    }
    
    private func getThemeHint(for flower: AIFlower) -> String {
        if flower.descriptor.contains("sunrise") {
            return "The Dawn Bloom"
        } else if flower.descriptor.contains("ocean") {
            return "The Tide Dancer"
        } else if flower.descriptor.contains("forest") {
            return "The Wood Whisperer"
        }
        return "A Unique Beauty"
    }
} 