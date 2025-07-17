import SwiftUI
import CoreLocation
import UIKit
import Photos
import EventKit

struct OnboardingView: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int
    @State private var starterFlowers: [AIFlower] = []
    @State private var selectedStarterIndex: Int?
    @State private var isGeneratingFlowers = false
    @State private var locationManager = CLLocationManager()
    
    // UserDefaults keys for onboarding persistence
    private static let onboardingPageKey = "onboardingCurrentPage"
    private static let onboardingStarterFlowersKey = "onboardingStarterFlowers"
    private static let onboardingSelectedIndexKey = "onboardingSelectedIndex"
    
    init(flowerStore: FlowerStore) {
        self.flowerStore = flowerStore
        
        // Restore onboarding progress from UserDefaults
        let savedPage = UserDefaults.standard.integer(forKey: OnboardingView.onboardingPageKey)
        self._currentPage = State(initialValue: savedPage)
    }
    
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
                
                // Page 4: Camera roll permission
                CameraRollPermissionPageView()
                    .tag(3)
                
                // Page 5: Calendar permission
                CalendarPermissionPageView()
                    .tag(4)
                
                // Page 6: Weather permission
                WeatherPermissionPageView()
                    .tag(5)
                
                // Page 7: Starter flower selection - only show when currentPage is 6
                if currentPage == 6 {
                    StarterFlowerSelectionView(
                        flowers: starterFlowers,
                        selectedIndex: $selectedStarterIndex,
                        isLoading: isGeneratingFlowers,
                        onSelect: { index in
                            selectStarterFlower(at: index)
                        }
                    )
                    .tag(6)
                    .gesture(DragGesture()) // Prevents swiping back
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom page indicator
            VStack {
                Spacer()
                
                if currentPage < 6 {
                    VStack(spacing: 24) {
                        // Page dots - only show 6 dots since user can't manually navigate to page 7
                        HStack(spacing: 8) {
                            ForEach(0..<6) { index in
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
                                    // Request location permission and continue to next page
                                    locationManager.requestWhenInUseAuthorization()
                                    currentPage += 1
                                } else if currentPage == 3 {
                                    // Request camera roll permission and continue
                                    requestCameraRollPermission()
                                    currentPage += 1
                                } else if currentPage == 4 {
                                    // Request calendar permission and continue
                                    requestCalendarPermission()
                                    currentPage += 1
                                } else if currentPage == 5 {
                                    // Weather doesn't need explicit permission, jump to flower selection
                                    currentPage = 6
                                } else {
                                    currentPage += 1
                                }
                            }
                        }) {
                            Text(getButtonText(for: currentPage))
                        }
                        .flowerOnboardingButtonStyle()
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            restoreOnboardingState()
            // Start generating flowers immediately when onboarding appears
            generateStarterFlowers()
        }
        .onChange(of: currentPage) { _, newPage in
            saveOnboardingProgress()
        }
        .onChange(of: selectedStarterIndex) { _, newIndex in
            saveOnboardingProgress()
        }
    }
    
    private func generateStarterFlowers() {
        // Don't start generating if already in progress or if we already have flowers
        guard !isGeneratingFlowers && starterFlowers.isEmpty else { 
            print("OnboardingView: Skipping flower generation - already in progress or flowers exist")
            return 
        }
        
        print("OnboardingView: Starting flower generation...")
        isGeneratingFlowers = true
        
        Task {
            // Generate 3 unique starter flowers
            var flowers: [AIFlower] = []
            
            print("OnboardingView: Starting to generate contextual starter flowers")
            
            // Get contextual information for personalized flowers
            let location = ContextualFlowerGenerator.shared.currentLocation
            let placemark = ContextualFlowerGenerator.shared.currentPlacemark
            let cityName = placemark?.locality ?? "your city"
            let country = placemark?.country ?? "your region"
            let currentSeason = ContextualFlowerGenerator.shared.getCurrentSeason()
            let currentHour = Calendar.current.component(.hour, from: Date())
            let timeOfDay = currentHour < 12 ? "morning" : (currentHour < 18 ? "afternoon" : "evening")
            
            // Generate contextual starter themes
            let currentMonth = Calendar.current.monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
            let seasonalColors = currentSeason == .spring ? "soft pastels and fresh greens" : 
                               currentSeason == .summer ? "warm golds and vibrant blues" : 
                               currentSeason == .autumn ? "rich burgundy and copper tones" : 
                               "crisp whites and deep emerald"
            
            let starterThemes = [
                (
                    name: "\(cityName) Bloom",
                    descriptor: "elegant petals that shimmer with \(seasonalColors), inspired by \(cityName) during \(currentMonth)",
                    meaning: "A flower unique to \(cityName), featuring colors and patterns that reflect the character of your city in \(currentSeason.rawValue.lowercased())"
                ),
                (
                    name: "\(currentMonth) Special",
                    descriptor: "luminous blooms in \(seasonalColors) with delicate touches that capture \(currentMonth) in \(country)",
                    meaning: "Created specifically for \(currentMonth) \(Calendar.current.component(.year, from: Date())), this flower marks the exact moment you started using the app"
                ),
                (
                    name: "\(currentSeason.rawValue) Edition",
                    descriptor: "radiant petals in perfect \(seasonalColors) that represent \(currentSeason.rawValue.lowercased()) in your location",
                    meaning: "A seasonal flower that appears only during \(currentSeason.rawValue.lowercased()), featuring the signature colors of this time of year"
                )
            ]
            
            print("OnboardingView: Generated contextual themes for \(cityName), \(country) during \(currentSeason.rawValue) \(timeOfDay)")
            
            // Check if API keys are available
            let hasAPIKeys = AppConfig.shared.hasBuiltInKeys
            let openAIKey = AppConfig.shared.effectiveOpenAIKey
            let falKey = AppConfig.shared.effectiveFALKey
            
            print("OnboardingView: Built-in API keys available: \(hasAPIKeys)")
            print("OnboardingView: OpenAI key length: \(openAIKey.count), starts with: \(openAIKey.prefix(10))")
            print("OnboardingView: FAL key length: \(falKey.count), starts with: \(falKey.prefix(10))")
            
            if !hasAPIKeys {
                print("OnboardingView: ERROR - No valid API keys available!")
                await MainActor.run {
                    // Create fallback flowers without images
                    self.starterFlowers = starterThemes.map { theme in
                        var flower = AIFlower(
                            name: theme.name,
                            descriptor: theme.descriptor,
                            imageData: nil,
                            generatedDate: Date(),
                            isFavorite: false,
                            discoveryDate: Date()
                        )
                        flower.meaning = theme.meaning
                        return flower
                    }
                    self.isGeneratingFlowers = false
                }
                return
            }
            
            for (index, theme) in starterThemes.enumerated() {
                print("OnboardingView: Generating flower \(index + 1)/\(starterThemes.count): \(theme.name)")
                
                do {
                    // Generate image
                    let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: theme.descriptor)
                    guard let imageData = image.pngData() else { 
                        print("OnboardingView: Failed to convert image to PNG data for \(theme.name)")
                        continue 
                    }
                    
                    print("OnboardingView: Successfully generated image for \(theme.name)")
                    
                    // Create flower with special first flower tag
                    var flower = AIFlower(
                        name: theme.name,
                        descriptor: theme.descriptor,
                        imageData: imageData,
                        generatedDate: Date(),
                        isFavorite: false,
                        discoveryDate: Date()
                    )
                    
                    // Add the description as meaning
                    flower.meaning = theme.meaning
                    
                    // Add location data if available
                    if let location = ContextualFlowerGenerator.shared.currentLocation {
                        flower.discoveryLatitude = location.coordinate.latitude
                        flower.discoveryLongitude = location.coordinate.longitude
                        flower.discoveryLocationName = ContextualFlowerGenerator.shared.currentPlacemark?.locality
                    }
                    
                    flowers.append(flower)
                } catch {
                    print("OnboardingView: Failed to generate starter flower \(index): \(error)")
                    
                    // Create a fallback flower with placeholder data
                    var flower = AIFlower(
                        name: theme.name,
                        descriptor: theme.descriptor,
                        imageData: nil, // No image data
                        generatedDate: Date(),
                        isFavorite: false,
                        discoveryDate: Date()
                    )
                    
                    // Add the description as meaning
                    flower.meaning = theme.meaning
                    
                    // Add location data if available
                    if let location = ContextualFlowerGenerator.shared.currentLocation {
                        flower.discoveryLatitude = location.coordinate.latitude
                        flower.discoveryLongitude = location.coordinate.longitude
                        flower.discoveryLocationName = ContextualFlowerGenerator.shared.currentPlacemark?.locality
                    }
                    
                    flowers.append(flower)
                }
            }
            
            print("OnboardingView: Generated \(flowers.count) flowers total")
            
            await MainActor.run {
                self.starterFlowers = flowers
                self.isGeneratingFlowers = false
                
                // Save progress after generating flowers
                self.saveOnboardingProgress()
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
        
        // Clear onboarding progress since it's complete
        clearOnboardingProgress()
        
        // Schedule the next flower for new users
        flowerStore.scheduleNextFlowerIfNeeded()
        
        // Dismiss onboarding
        dismiss()
    }
    
    // MARK: - Onboarding Persistence Methods
    
    private func saveOnboardingProgress() {
        print("OnboardingView: Saving progress - page: \(currentPage), selectedIndex: \(selectedStarterIndex ?? -1)")
        
        UserDefaults.standard.set(currentPage, forKey: OnboardingView.onboardingPageKey)
        UserDefaults.standard.set(selectedStarterIndex ?? -1, forKey: OnboardingView.onboardingSelectedIndexKey)
        
        // Save starter flowers if they exist
        if !starterFlowers.isEmpty {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let flowersData = try encoder.encode(starterFlowers)
                UserDefaults.standard.set(flowersData, forKey: OnboardingView.onboardingStarterFlowersKey)
                print("OnboardingView: Saved \(starterFlowers.count) starter flowers")
            } catch {
                print("OnboardingView: Failed to save starter flowers: \(error)")
            }
        }
    }
    
    private func restoreOnboardingState() {
        print("OnboardingView: Restoring onboarding state - current page: \(currentPage)")
        
        // Restore selected index
        let savedSelectedIndex = UserDefaults.standard.integer(forKey: OnboardingView.onboardingSelectedIndexKey)
        if savedSelectedIndex >= 0 {
            selectedStarterIndex = savedSelectedIndex
            print("OnboardingView: Restored selected index: \(savedSelectedIndex)")
        }
        
        // Restore starter flowers if they exist
        if let flowersData = UserDefaults.standard.data(forKey: OnboardingView.onboardingStarterFlowersKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let savedFlowers = try decoder.decode([AIFlower].self, from: flowersData)
                starterFlowers = savedFlowers
                print("OnboardingView: Restored \(savedFlowers.count) starter flowers")
            } catch {
                print("OnboardingView: Failed to restore starter flowers: \(error)")
                // If restoration fails, we'll regenerate them
            }
        }
    }
    
    private func clearOnboardingProgress() {
        print("OnboardingView: Clearing onboarding progress")
        UserDefaults.standard.removeObject(forKey: OnboardingView.onboardingPageKey)
        UserDefaults.standard.removeObject(forKey: OnboardingView.onboardingStarterFlowersKey)
        UserDefaults.standard.removeObject(forKey: OnboardingView.onboardingSelectedIndexKey)
    }
    
    // MARK: - Permission Methods
    
    private func requestCameraRollPermission() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            print("Camera roll permission status: \(status)")
        }
    }
    
    private func requestCalendarPermission() {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            print("Calendar permission granted: \(granted), error: \(String(describing: error))")
        }
    }
    
    private func getButtonText(for page: Int) -> String {
        switch page {
        case 2: return "Grant Location & Continue"
        case 3: return "Grant Camera Roll & Continue"
        case 4: return "Grant Calendar & Continue"
        case 5: return "Continue"
        default: return "Continue"
        }
    }
}

struct WelcomePageView: View {
    @State private var animateFlower = false
    @State private var onboardingFlowerImage: UIImage?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Beautiful flower image
            if let flowerImage = onboardingFlowerImage {
                Image(uiImage: flowerImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
                    .shadow(color: .flowerPrimary.opacity(0.3), radius: 20, y: 10)
                    .scaleEffect(animateFlower ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlower)
                    .onAppear { animateFlower = true }
            } else {
                // Fallback animated flower icon while loading
                Image(systemName: "flower")
                    .font(.system(size: 80))
                    .foregroundColor(.flowerPrimary)
                    .scaleEffect(animateFlower ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlower)
                    .onAppear { 
                        animateFlower = true
                        generateOnboardingFlower()
                    }
            }
            
            VStack(spacing: 16) {
                Text("Welcome to Flowers")
                    .font(.system(size: 36, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Collect beautiful AI-generated flowers and share them with the people closest to you")
                    .font(.system(size: 18))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            generateOnboardingFlower()
        }
    }
    
    private func generateOnboardingFlower() {
        guard onboardingFlowerImage == nil else { return }
        
        Task {
            do {
                // Generate a beautiful welcome flower
                let descriptor = "elegant welcome flower with soft pastel petals in pink and white, perfect symmetry, gentle morning light, botanical illustration style"
                
                let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: descriptor)
                
                await MainActor.run {
                    self.onboardingFlowerImage = image
                }
            } catch {
                print("Failed to generate onboarding flower: \(error)")
                // Keep the fallback SF Symbol
            }
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
                    icon: "location.fill",
                    title: "Uniquely Yours",
                    description: "Flowers adapt to your location, season & time",
                    delay: 0.2,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "sparkle",
                    title: "Contextual Magic",
                    description: "Each flower reflects your city, weather & calendar",
                    delay: 0.3,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "heart.fill",
                    title: "Build Your Garden",
                    description: "Save favorites and grow your collection",
                    delay: 0.4,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "bell.fill",
                    title: "Gentle Reminders",
                    description: "Notifications when new flowers bloom",
                    delay: 0.5,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Share with Loved Ones",
                    description: "Send flowers to friends and family via AirDrop or messages",
                    delay: 0.6,
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
                
                Text("Allow location access to create flowers that reflect your city's unique character, local weather patterns, and seasonal changes")
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
                
                Text("Select your first flower\nfrom these three options")
                    .font(.system(size: 16))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 60)
            
            if isLoading || flowers.isEmpty {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.flowerPrimary)
                    
                    Text("Cultivating your starter garden...")
                        .font(.system(size: 16))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your flowers are being prepared while you explore the app")
                        .font(.system(size: 14))
                        .foregroundColor(.flowerTextTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Flower cards carousel with proper snap-to-place
                TabView(selection: $selectedIndex) {
                    ForEach(Array(flowers.enumerated()), id: \.offset) { index, flower in
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
                            }
                        )
                        .padding(.horizontal, 30)
                        .tag(index)
                        .scaleEffect(cardsAppeared ? 1 : 0.8)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: cardsAppeared)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 550)
                .onChange(of: selectedIndex) { oldValue, newValue in
                    if let newValue = newValue, oldValue != newValue {
                        // Haptic feedback when card snaps
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                }
                .onAppear {
                    // Start with the middle card selected
                    if flowers.count > 1 && selectedIndex == nil {
                        selectedIndex = 1
                    } else if flowers.count == 1 && selectedIndex == nil {
                        selectedIndex = 0
                    }
                    
                    // Animate cards in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        cardsAppeared = true
                    }
                }
                
                // Select button with page dots
                VStack(spacing: 20) {
                    // Page dots for flower cards
                    HStack(spacing: 8) {
                        ForEach(0..<flowers.count, id: \.self) { index in
                            Circle()
                                .fill(index == selectedIndex ? Color.flowerPrimary : Color.flowerPrimary.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                        }
                    }
                    
                    Button(action: {
                        guard selectedIndex != nil else { return }
                        
                        // Haptic feedback when selecting a flower
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        if let index = selectedIndex {
                            onSelect(index)
                        }
                    }) {
                        Text("Pick This Flower")
                    }
                    .flowerOnboardingButtonStyle(
                        color: selectedIndex != nil ? .flowerPrimary : Color.flowerPrimary.opacity(0.3)
                    )
                    .disabled(selectedIndex == nil)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Permission Pages

struct CameraRollPermissionPageView: View {
    @State private var animateAlbum = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Camera Roll Album Preview
            VStack(spacing: 16) {
                // Album title
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 20))
                        .foregroundColor(.flowerPrimary)
                    Text("Flowers")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.flowerTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Sample flower grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                    ForEach(0..<6) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.flowerPrimary.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "flower.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.flowerPrimary.opacity(0.6))
                            )
                            .scaleEffect(animateAlbum ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateAlbum)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
            .background(Color.flowerCardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
            .onAppear { animateAlbum = true }
            
            VStack(spacing: 16) {
                Text("Save Your Flower Collection")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Automatically save your beautiful flower discoveries to a dedicated album in your Photos app for easy access and sharing")
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

struct CalendarPermissionPageView: View {
    @State private var animateCalendar = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Calendar preview with special dates
            VStack(spacing: 16) {
                // Calendar header
                HStack {
                    Text("July 2025")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.flowerTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // Day headers
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    
                    // Calendar days
                    ForEach(1..<32) { day in
                        ZStack {
                            Circle()
                                .fill(day == 17 ? Color.flowerPrimary : Color.clear)
                                .frame(width: 32, height: 32)
                            
                            Text("\(day)")
                                .font(.system(size: 14))
                                .foregroundColor(day == 17 ? .white : .flowerTextPrimary)
                            
                            if day == 17 {
                                Image(systemName: "flower.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                                    .offset(x: 8, y: -8)
                            }
                        }
                        .scaleEffect(animateCalendar ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(day) * 0.01), value: animateCalendar)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
            .background(Color.flowerCardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
            .onAppear { animateCalendar = true }
            
            VStack(spacing: 16) {
                Text("Holiday & Event Flowers")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Create special bouquets and themed flowers for holidays, birthdays, anniversaries, and important events in your calendar")
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

struct WeatherPermissionPageView: View {
    @State private var animateWeather = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Weather card preview
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monday, 17th July")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.flowerTextPrimary)
                        
                        Text("London, UK")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                            
                            Text("22°C")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                        }
                        
                        Text("Sunny")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                
                HStack {
                    Image(systemName: "flower.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.flowerPrimary)
                    
                    Text("Perfect weather for a Sun-kissed Rose")
                        .font(.system(size: 14))
                        .foregroundColor(.flowerTextSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color.flowerCardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
            .scaleEffect(animateWeather ? 1.0 : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateWeather)
            .onAppear { animateWeather = true }
            
            VStack(spacing: 16) {
                Text("Weather-Inspired Flowers")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Generate flowers that reflect the current weather conditions, creating sun-kissed blooms on bright days or rain-blessed petals during storms")
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

struct StarterFlowerCard: View {
    let flower: AIFlower
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
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
            } else {
                // Placeholder when no image is available
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.flowerCardBackground)
                        .frame(width: 280, height: 280)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "flower.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.flowerPrimary.opacity(0.6))
                        
                        Text("Loading...")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
            }
            
            VStack(spacing: 12) {
                // Flower name
                Text(flower.name)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .black : .flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                // Flower meaning/description
                if let meaning = flower.meaning {
                    Text(meaning)
                        .font(.system(size: 16))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
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
                    color: Color.black.opacity(0.1),
                    radius: 20,
                    x: 0,
                    y: 8
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