import SwiftUI
import CoreLocation
import UIKit

struct OnboardingView: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var starterFlowers: [AIFlower] = []
    @State private var selectedStarterIndex: Int?
    @State private var isGeneratingFlowers = false
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.flowerBackground, Color.flowerBackgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                WelcomePageView()
                    .tag(0)
                
                // Page 2: How it works
                HowItWorksPageView()
                    .tag(1)
                
                // Page 3: Location permission
                LocationPermissionPageView(locationManager: locationManager)
                    .tag(2)
                
                // Page 4: Starter flower selection
                StarterFlowerSelectionView(
                    flowers: starterFlowers,
                    selectedIndex: $selectedStarterIndex,
                    isLoading: isGeneratingFlowers,
                    onSelect: { index in
                        selectStarterFlower(at: index)
                    }
                )
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom page indicator
            VStack {
                Spacer()
                
                if currentPage < 3 {
                    VStack(spacing: 24) {
                        // Page dots
                        HStack(spacing: 8) {
                            ForEach(0..<4) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.flowerPrimary : Color.flowerPrimary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut, value: currentPage)
                            }
                        }
                        
                        // Continue button
                        Button(action: {
                            withAnimation {
                                if currentPage == 2 {
                                    // Request location permission before moving to flower selection
                                    locationManager.requestWhenInUseAuthorization()
                                    currentPage += 1
                                    generateStarterFlowers()
                                } else {
                                    currentPage += 1
                                }
                            }
                        }) {
                            HStack {
                                Text(currentPage == 2 ? "Grant Permission & Continue" : "Continue")
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
                    }
                    .padding(.bottom, 50)
                }
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
                ("Sunrise Bloom", "vibrant sunrise colors with warm orange and pink petals", "A flower that captures the warmth and hope of dawn"),
                ("Ocean's Dream", "deep ocean blues with silver-tipped petals like moonlight on water", "Born from sea spray and moonbeams"),
                ("Forest Guardian", "forest greens with golden accents like sunlight through leaves", "A woodland protector with ancient wisdom")
            ]
            
            for (index, (name, theme, description)) in starterThemes.enumerated() {
                do {
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
                    
                    // Add the description as meaning
                    flower.meaning = description
                    
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
        
        // Schedule the next flower for new users
        flowerStore.scheduleNextFlowerIfNeeded()
        
        // Dismiss onboarding
        dismiss()
    }
}

struct WelcomePageView: View {
    @State private var animateFlower = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated flower icon
            Image(systemName: "flower")
                .font(.system(size: 80))
                .foregroundColor(.flowerPrimary)
                .scaleEffect(animateFlower ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlower)
                .onAppear { animateFlower = true }
            
            VStack(spacing: 16) {
                Text("Welcome to Flowers")
                    .font(.system(size: 36, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("A daily journey of discovering beautiful AI-generated flowers")
                    .font(.system(size: 18))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct HowItWorksPageView: View {
    @State private var featuresAppeared = false
    
    var body: some View {
        VStack(spacing: 40) {
            Text("How It Works")
                .font(.system(size: 32, weight: .light, design: .serif))
                .foregroundColor(.flowerTextPrimary)
                .padding(.top, 60)
            
            VStack(spacing: 32) {
                FeatureRow(
                    icon: "sparkles",
                    title: "Daily Discovery",
                    description: "Receive a new unique flower every day",
                    delay: 0.1,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "map",
                    title: "Location Inspired",
                    description: "Flowers influenced by your surroundings",
                    delay: 0.2,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "heart.fill",
                    title: "Build Your Garden",
                    description: "Save favorites and grow your collection",
                    delay: 0.3,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "bell.fill",
                    title: "Gentle Reminders",
                    description: "Notifications when new flowers bloom",
                    delay: 0.4,
                    appeared: featuresAppeared
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .onAppear {
            withAnimation {
                featuresAppeared = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    let appeared: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.flowerPrimary)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.flowerTextPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.flowerTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

struct LocationPermissionPageView: View {
    let locationManager: CLLocationManager
    @State private var animateMap = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated map icon
            ZStack {
                Circle()
                    .fill(Color.flowerPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateMap ? 1.2 : 1.0)
                    .opacity(animateMap ? 0 : 1)
                    .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: animateMap)
                
                Image(systemName: "location.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.flowerPrimary)
            }
            .onAppear { animateMap = true }
            
            VStack(spacing: 16) {
                Text("Location-Inspired Flowers")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Allow location access to discover flowers inspired by your surroundings, weather, and local seasons")
                    .font(.system(size: 16))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct StarterFlowerSelectionView: View {
    let flowers: [AIFlower]
    @Binding var selectedIndex: Int?
    let isLoading: Bool
    let onSelect: (Int) -> Void
    @State private var cardsAppeared = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            VStack(spacing: 12) {
                Text("Pick Your First Flower")
                    .font(.system(size: 32, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                
                Text("Choose the flower that speaks to you")
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
                    
                    Text("Cultivating your starter garden...")
                        .font(.system(size: 16))
                        .foregroundColor(.flowerTextSecondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Flower cards carousel
                GeometryReader { geometry in
                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 24) {
                                ForEach(Array(flowers.enumerated()), id: \.element.id) { index, flower in
                                    StarterFlowerCard(
                                        flower: flower,
                                        isSelected: selectedIndex == index,
                                        onTap: {
                                            // Haptic feedback
                                            let impact = UIImpactFeedbackGenerator(style: .medium)
                                            impact.impactOccurred()
                                            
                                            withAnimation(.spring()) {
                                                selectedIndex = index
                                            }
                                            
                                            // Scroll to center the selected card
                                            withAnimation(.spring()) {
                                                scrollProxy.scrollTo(flower.id, anchor: .center)
                                            }
                                        }
                                    )
                                    .id(flower.id)
                                    .scaleEffect(cardsAppeared ? 1 : 0.8)
                                    .opacity(cardsAppeared ? 1 : 0)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: cardsAppeared)
                                }
                            }
                            .padding(.horizontal, max(24, (geometry.size.width - 300) / 2))
                            .padding(.vertical, 60) // Extra padding for shadows
                        }
                        .onAppear {
                            // Center the middle card on appear
                            if flowers.count > 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    scrollProxy.scrollTo(flowers[1].id, anchor: .center)
                                }
                            }
                            
                            // Animate cards in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                cardsAppeared = true
                            }
                        }
                    }
                }
                .frame(height: 500) // Fixed height for carousel
                
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
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct StarterFlowerCard: View {
    let flower: AIFlower
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Flower image
            if let imageData = flower.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .clipped()
                    .cornerRadius(24)
            }
            
            VStack(spacing: 12) {
                // Flower name
                Text(flower.name)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                // Flower meaning/description
                if let meaning = flower.meaning {
                    Text(meaning)
                        .font(.system(size: 16))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 16)
                }
            }
        }
        .frame(width: 300)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(
                    color: isSelected ? Color.flowerPrimary.opacity(0.3) : Color.black.opacity(0.1),
                    radius: isSelected ? 30 : 20,
                    x: 0,
                    y: isSelected ? 12 : 8
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(
                    isSelected ? Color.flowerPrimary : Color.clear,
                    lineWidth: 3
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .onTapGesture(perform: onTap)
    }
} 