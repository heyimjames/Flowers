import SwiftUI
import CoreLocation
import MapKit
import UIKit
import Photos
import EventKit
import WeatherKit

struct OnboardingView: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int
    @State private var starterFlowers: [AIFlower] = []
    @State private var selectedStarterIndex: Int?
    @State private var isGeneratingFlowers = false
    @State private var locationManager = CLLocationManager()
    
    // Permission tracking states
    @State private var locationPermissionGranted = false
    @State private var cameraRollPermissionGranted = false
    @State private var calendarPermissionGranted = false
    
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
                
                // Page 3: Username setup
                UsernameSetupPageView()
                    .tag(2)
                
                // Page 4: Location permission
                LocationPermissionPageView(locationManager: locationManager)
                    .tag(3)
                
                // Page 5: Camera roll permission
                CameraRollPermissionPageView()
                    .tag(4)
                
                // Page 6: Calendar permission
                CalendarPermissionPageView()
                    .tag(5)
                
                // Page 7: Weather permission
                WeatherPermissionPageView()
                    .tag(6)
                
                // Page 8: Starter flower selection - only show when currentPage is 7
                if currentPage == 7 {
                    StarterFlowerSelectionView(
                        flowers: starterFlowers,
                        selectedIndex: $selectedStarterIndex,
                        isLoading: isGeneratingFlowers,
                        onSelect: { index in
                            selectStarterFlower(at: index)
                        }
                    )
                    .tag(7)
                    .gesture(DragGesture()) // Prevents swiping back
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(
                // Custom gesture to control swiping behavior
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold && currentPage > 0 {
                            // Allow swipe right (backward)
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        // Don't allow forward swiping - users must use the button
                    }
            )
            
            // Page dots - positioned with overlay to avoid keyboard interference
            if currentPage < 7 {
                GeometryReader { geometry in
                    HStack(spacing: 8) {
                        ForEach(0..<7) { index in
                            Circle()
                                .fill(index == currentPage ? Color.flowerPrimary : Color.flowerPrimary.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height - 140 // Fixed distance from bottom
                    )
                }
                .allowsHitTesting(false) // Don't interfere with touch events
                .ignoresSafeArea(.keyboard, edges: .bottom) // Ignore keyboard safe area
            }
            
            // Continue button - positioned with overlay to avoid keyboard interference
            if currentPage < 7 {
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            if currentPage == 3 {
                                // Location permission page
                                if !locationPermissionGranted {
                                    requestLocationPermission()
                                } else {
                                    currentPage += 1
                                }
                            } else if currentPage == 4 {
                                // Camera roll permission page
                                if !cameraRollPermissionGranted {
                                    requestCameraRollPermission()
                                } else {
                                    currentPage += 1
                                }
                            } else if currentPage == 5 {
                                // Calendar permission page
                                if !calendarPermissionGranted {
                                    requestCalendarPermission()
                                } else {
                                    currentPage += 1
                                }
                            } else if currentPage == 6 {
                                // Weather doesn't need explicit permission, jump to flower selection
                                currentPage = 7
                            } else {
                                currentPage += 1
                            }
                        }
                    }) {
                        Text(getButtonText(for: currentPage))
                    }
                    .apply { view in
                        if isCurrentPageGranted() {
                            view.flowerSecondaryButtonStyle()
                        } else {
                            view.flowerOnboardingButtonStyle()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50) // Fixed distance from bottom
                }
            }
        }
        .onAppear {
            restoreOnboardingState()
            // Start generating flowers immediately when onboarding appears
            generateStarterFlowers()
        }
        .onChange(of: currentPage) { oldPage, newPage in
            saveOnboardingProgress()
            
            // Dismiss keyboard when navigating away from username page (page 2)
            if oldPage == 2 && newPage != 2 {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
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
                               currentSeason == .summer ? "gentle yellows and soft sky blues" : 
                               currentSeason == .autumn ? "muted dusty rose and pale copper tones" : 
                               "crisp whites and soft sage green"
            
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
                    // Create fallback flowers with complete metadata but no images
                    self.starterFlowers = starterThemes.map { theme in
                        var flower = AIFlower(
                            name: theme.name,
                            descriptor: theme.descriptor,
                            imageData: nil,
                            generatedDate: Date(),
                            isFavorite: false,
                            discoveryDate: Date(),
                            originalOwner: self.createCurrentOwner()
                        )
                        flower.meaning = theme.meaning
                        
                        // Add location data if available
                        if let location = ContextualFlowerGenerator.shared.currentLocation {
                            flower.discoveryLatitude = location.coordinate.latitude
                            flower.discoveryLongitude = location.coordinate.longitude
                            flower.discoveryLocationName = ContextualFlowerGenerator.shared.currentPlacemark?.locality
                        }
                        
                        // Add weather and date information
                        if let weather = ContextualFlowerGenerator.shared.currentWeather {
                            let weatherCondition = getWeatherConditionString(from: weather.currentWeather.condition)
                            let temperature = weather.currentWeather.temperature.value
                            flower.captureWeatherAndDate(
                                weatherCondition: weatherCondition,
                                temperature: temperature,
                                temperatureUnit: "°C"
                            )
                        } else {
                            // Always capture date even without weather
                            flower.captureWeatherAndDate(
                                weatherCondition: nil,
                                temperature: nil,
                                temperatureUnit: nil
                            )
                        }
                        
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
                    
                    // Create flower with complete metadata
                    var flower = AIFlower(
                        name: theme.name,
                        descriptor: theme.descriptor,
                        imageData: imageData,
                        generatedDate: Date(),
                        isFavorite: false,
                        discoveryDate: Date(),
                        originalOwner: createCurrentOwner()
                    )
                    
                    // Add the description as meaning
                    flower.meaning = theme.meaning
                    
                    // Add location data if available
                    if let location = ContextualFlowerGenerator.shared.currentLocation {
                        flower.discoveryLatitude = location.coordinate.latitude
                        flower.discoveryLongitude = location.coordinate.longitude
                        flower.discoveryLocationName = ContextualFlowerGenerator.shared.currentPlacemark?.locality
                    }
                    
                    // Add weather and date information
                    if let weather = ContextualFlowerGenerator.shared.currentWeather {
                        let weatherCondition = getWeatherConditionString(from: weather.currentWeather.condition)
                        let temperature = weather.currentWeather.temperature.value
                        flower.captureWeatherAndDate(
                            weatherCondition: weatherCondition,
                            temperature: temperature,
                            temperatureUnit: "°C"
                        )
                    } else {
                        // Always capture date even without weather
                        flower.captureWeatherAndDate(
                            weatherCondition: nil,
                            temperature: nil,
                            temperatureUnit: nil
                        )
                    }
                    
                    flowers.append(flower)
                } catch {
                    print("OnboardingView: Failed to generate starter flower \(index): \(error)")
                    
                    // Create a fallback flower with complete metadata
                    var flower = AIFlower(
                        name: theme.name,
                        descriptor: theme.descriptor,
                        imageData: nil, // No image data
                        generatedDate: Date(),
                        isFavorite: false,
                        discoveryDate: Date(),
                        originalOwner: createCurrentOwner()
                    )
                    
                    // Add the description as meaning
                    flower.meaning = theme.meaning
                    
                    // Add location data if available
                    if let location = ContextualFlowerGenerator.shared.currentLocation {
                        flower.discoveryLatitude = location.coordinate.latitude
                        flower.discoveryLongitude = location.coordinate.longitude
                        flower.discoveryLocationName = ContextualFlowerGenerator.shared.currentPlacemark?.locality
                    }
                    
                    // Add weather and date information
                    if let weather = ContextualFlowerGenerator.shared.currentWeather {
                        let weatherCondition = getWeatherConditionString(from: weather.currentWeather.condition)
                        let temperature = weather.currentWeather.temperature.value
                        flower.captureWeatherAndDate(
                            weatherCondition: weatherCondition,
                            temperature: temperature,
                            temperatureUnit: "°C"
                        )
                    } else {
                        // Always capture date even without weather
                        flower.captureWeatherAndDate(
                            weatherCondition: nil,
                            temperature: nil,
                            temperatureUnit: nil
                        )
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
        
        // Save the selected flower (disable auto-save to prevent unwanted photo library saves)
        flowerStore.addToDiscoveredFlowers(selectedFlower, autoSaveToPhotos: false)
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
    
    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        // We'll check the permission status after the request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkLocationPermission()
            // Auto-advance if permission was granted
            if self.locationPermissionGranted {
                withAnimation {
                    self.currentPage += 1
                }
            }
        }
    }
    
    private func requestCameraRollPermission() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                self.cameraRollPermissionGranted = status == .authorized || status == .limited
                print("Camera roll permission status: \(status), granted: \(self.cameraRollPermissionGranted)")
                // Auto-advance if permission was granted
                if self.cameraRollPermissionGranted {
                    withAnimation {
                        self.currentPage += 1
                    }
                }
            }
        }
    }
    
    private func requestCalendarPermission() {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                self.calendarPermissionGranted = granted
                print("Calendar permission granted: \(granted), error: \(String(describing: error))")
                // Auto-advance if permission was granted
                if self.calendarPermissionGranted {
                    withAnimation {
                        self.currentPage += 1
                    }
                }
            }
        }
    }
    
    // Helper functions to check current permission status
    private func checkLocationPermission() {
        let status = locationManager.authorizationStatus
        locationPermissionGranted = status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    private func checkCameraRollPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        cameraRollPermissionGranted = status == .authorized || status == .limited
    }
    
    private func checkCalendarPermission() {
        let eventStore = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        calendarPermissionGranted = status == .authorized || status == .fullAccess
    }
    
    private func getButtonText(for page: Int) -> String {
        switch page {
        case 2: return "Continue"
        case 3: return locationPermissionGranted ? "Granted" : "Grant Location & Continue"
        case 4: return cameraRollPermissionGranted ? "Granted" : "Grant Camera Roll & Continue"
        case 5: return calendarPermissionGranted ? "Granted" : "Grant Calendar & Continue"
        case 6: return "Continue"
        default: return "Continue"
        }
    }
    
    /// Check if the current page's permission is granted
    private func isCurrentPageGranted() -> Bool {
        switch currentPage {
        case 3: return locationPermissionGranted
        case 4: return cameraRollPermissionGranted
        case 5: return calendarPermissionGranted
        default: return false
        }
    }
    
    /// Creates a FlowerOwner instance for the current user
    private func createCurrentOwner() -> FlowerOwner {
        let userName = UserDefaults.standard.string(forKey: "userName") ?? "You"
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        
        // Try to get current location name for the owner
        var locationName: String?
        if let currentPlacemark = ContextualFlowerGenerator.shared.currentPlacemark {
            locationName = currentPlacemark.locality ?? currentPlacemark.name
        }
        
        return FlowerOwner(
            name: userName,
            deviceID: deviceID,
            transferDate: Date(),
            location: locationName
        )
    }
    
    private func getWeatherConditionString(from condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear:
            return "Clear"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .cloudy, .mostlyCloudy:
            return "Cloudy"
        case .rain:
            return "Rain"
        case .drizzle:
            return "Drizzle"
        case .snow:
            return "Snow"
        case .sleet:
            return "Sleet"
        case .hail:
            return "Hail"
        case .thunderstorms:
            return "Thunderstorms"
        case .tropicalStorm:
            return "Tropical Storm"
        case .blizzard:
            return "Blizzard"
        case .freezingRain:
            return "Freezing Rain"
        case .freezingDrizzle:
            return "Freezing Drizzle"
        case .heavyRain:
            return "Heavy Rain"
        case .heavySnow:
            return "Heavy Snow"
        case .isolatedThunderstorms:
            return "Isolated Thunderstorms"
        case .scatteredThunderstorms:
            return "Scattered Thunderstorms"
        case .strongStorms:
            return "Strong Storms"
        case .sunFlurries:
            return "Sun Flurries"
        case .windy:
            return "Windy"
        case .wintryMix:
            return "Wintry Mix"
        default:
            return "Clear"
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
                    .frame(width: 280, height: 280)
                    .cornerRadius(12)
                    .scaleEffect(animateFlower ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlower)
                    .onAppear { animateFlower = true }
            } else {
                // Fallback animated flower icon while loading
                Image(systemName: "flower")
                    .font(.system(size: 80, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                    .scaleEffect(animateFlower ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateFlower)
                    .onAppear { 
                        animateFlower = true
                        generateOnboardingFlower()
                    }
            }
            
            VStack(spacing: 20) {
                Text("Welcome to Flowers")
                    .font(.system(size: 36, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Collect beautiful AI-generated flowers and share them with the people closest to you")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7.2) // 1.4em at 18pt font size
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
        
        // First try to load cached flower synchronously
        if let cachedFlower = loadCachedOnboardingFlower() {
            onboardingFlowerImage = cachedFlower
            print("WelcomePageView: Loaded cached onboarding flower immediately")
            return
        }
        
        // If no cached version, generate asynchronously
        Task {
            if let flower = await OnboardingAssetsService.shared.getOnboardingFlowerForFirstPage(),
               let imageData = flower.imageData,
               let image = UIImage(data: imageData) {
                await MainActor.run {
                    self.onboardingFlowerImage = image
                }
            } else {
                print("Failed to load onboarding flower from service")
                // Keep the fallback SF Symbol
            }
        }
    }
    
    private func loadCachedOnboardingFlower() -> UIImage? {
        guard UserDefaults.standard.bool(forKey: "onboarding_main_flower_generated"),
              let flowerData = UserDefaults.standard.data(forKey: "onboarding_main_flower") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let flower = try decoder.decode(AIFlower.self, from: flowerData)
            
            if let imageData = flower.imageData {
                return UIImage(data: imageData)
            }
        } catch {
            print("WelcomePageView: Failed to decode cached onboarding flower: \(error)")
        }
        
        return nil
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
                    icon: "leaf.fill",
                    title: "Real Botanical Species",
                    description: "Choose from 400+ scientifically accurate flowers",
                    delay: 0.2,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "sparkle",
                    title: "Contextual Magic",
                    description: "Find flowers specific to your location, weather & time",
                    delay: 0.3,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "star.fill",
                    title: "Rarity Progression",
                    description: "Discover rare species as your garden grows",
                    delay: 0.4,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "heart.fill",
                    title: "Build Your Garden",
                    description: "Save favorites and track your collection",
                    delay: 0.5,
                    appeared: featuresAppeared
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Share with Love",
                    description: "Send flowers to friends via AirDrop or messages",
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
                .font(.system(size: 28, design: .rounded))
                .foregroundColor(.flowerPrimary)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
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
    @State private var onboardingFlowerImage: UIImage?
    
    // Create a sample flower with Canary Wharf London coordinates
    private var sampleFlower: AIFlower {
        AIFlower(
            name: "Canary Wharf Rose",
            descriptor: "elegant city rose with glass tower reflections",
            discoveryLatitude: 51.5054,
            discoveryLongitude: -0.0235,
            discoveryLocationName: "Canary Wharf, London"
        )
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Location-Inspired Flowers")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Your location unlocks personalized flower discoveries")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6.4) // 1.4em at 16pt font size
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 24)
            
            // Example map showing Canary Wharf London (non-interactive onboarding version)
            VStack(spacing: 16) {
                OnboardingMapView(
                    flower: sampleFlower,
                    onboardingFlowerImage: $onboardingFlowerImage
                )
                .frame(width: 300, height: 300)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .scaleEffect(animateMap ? 1.0 : 0.9)
                .rotationEffect(.degrees(-2)) // Random rotation: -2 degrees
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animateMap)
                .onAppear { animateMap = true }
                
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
                
                Text("Three flowers created just for you")
                    .font(.system(size: 16, design: .rounded))
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
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your flowers are being prepared while you explore the app")
                        .font(.system(size: 14, design: .rounded))
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
                
                // Contextual description
                Text("These starter flowers were specially generated based on your current location, season, and time. Each one is unique to this moment in your journey.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, -10)
                    .opacity(cardsAppeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.5), value: cardsAppeared)
                
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
                    
                    // Privacy and accuracy note
                    Text("Based on real botanical species • Your data stays private • Only discovery locations are saved")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.flowerTextTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        .opacity(cardsAppeared ? 0.8 : 0)
                        .animation(.easeIn(duration: 0.5).delay(0.7), value: cardsAppeared)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Permission Pages

struct CameraRollPermissionPageView: View {
    @State private var animateAlbum = false
    @State private var onboardingImages: [UIImage] = []
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Save Your Flower Collection")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Build a beautiful gallery of your personalized discoveries")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6.4) // 1.4em at 16pt font size
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 24)
            
            // Camera Roll Album Preview
            VStack(spacing: 16) {
                // Album title
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundColor(.flowerPrimary)
                    Text("Flowers")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.flowerTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Sample flower grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                    ForEach(0..<6) { index in
                        Group {
                            if index < onboardingImages.count {
                                Image(uiImage: onboardingImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.flowerPrimary.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "flower.fill")
                                            .font(.system(size: 24, design: .rounded))
                                            .foregroundColor(.flowerPrimary.opacity(0.6))
                                    )
                            }
                        }
                        .scaleEffect(animateAlbum ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateAlbum)
                    }
                }
                .padding(.horizontal, 16)
                
            }
            .padding(.vertical, 20)
            .background(Color.flowerCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
            .rotationEffect(.degrees(1.5)) // Random rotation: +1.5 degrees
            .onAppear { 
                animateAlbum = true
                Task {
                    onboardingImages = await OnboardingAssetsService.shared.getOnboardingFlowerImages()
                }
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
            
            VStack(spacing: 20) {
                Text("Holiday & Event Flowers")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Celebrate special moments with themed flowers")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6.4) // 1.4em at 16pt font size
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 24)
            
            // Calendar preview with special dates
            VStack(spacing: 16) {
                // Calendar header
                HStack {
                    Text("May 2025")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.flowerTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    // Day headers
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                            .frame(width: 32, height: 20)
                            .multilineTextAlignment(.center)
                    }
                    
                    // May 2025 starts on Thursday, so add 4 empty cells first
                    ForEach(0..<4, id: \.self) { _ in
                        Text("")
                            .frame(width: 32, height: 32)
                    }
                    
                    // Calendar days for May (31 days)
                    ForEach(1..<32) { day in
                        ZStack {
                            Circle()
                                .fill(day == 17 ? Color.flowerPrimary : Color.clear)
                                .frame(width: 32, height: 32)
                            
                            Text("\(day)")
                                .font(.system(size: 14, design: .rounded))
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
                .padding(.horizontal, 12)
                
            }
            .padding(.vertical, 20)
            .background(Color.flowerCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
            .rotationEffect(.degrees(-1)) // Random rotation: -1 degree
            .onAppear { animateCalendar = true }
            
            Spacer()
            Spacer()
        }
    }
}

struct WeatherPermissionPageView: View {
    @State private var animateWeather = false
    
    // Get current date
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Weather-Inspired Flowers")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Every condition creates unique flower meanings")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6.4) // 1.4em at 16pt font size
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 24)
            
            // Weather card preview
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentDateString)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Lisbon, Portugal")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 24, design: .rounded))
                                .foregroundColor(.yellow)
                            
                            Text("31°C")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text("Sunny")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                HStack {
                    Image(systemName: "flower.fill")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Perfect weather for picking flowers")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                        Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
            .rotationEffect(.degrees(2.5)) // Random rotation: +2.5 degrees
            .scaleEffect(animateWeather ? 1.0 : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateWeather)
            .onAppear { animateWeather = true }
            
            
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
                            .font(.system(size: 48, design: .rounded))
                            .foregroundColor(.flowerPrimary.opacity(0.6))
                        
                        Text("Loading...")
                            .font(.system(size: 16, design: .rounded))
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
                        .font(.system(size: 16, design: .rounded))
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

// Non-interactive map view specifically for onboarding
struct OnboardingMapView: View {
    let flower: AIFlower
    @Binding var onboardingFlowerImage: UIImage?
    @State private var region: MKCoordinateRegion
    
    init(flower: AIFlower, onboardingFlowerImage: Binding<UIImage?>) {
        self.flower = flower
        self._onboardingFlowerImage = onboardingFlowerImage
        
        // Initialize region with flower's discovery location
        if let lat = flower.discoveryLatitude,
           let lon = flower.discoveryLongitude {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 51.5054, longitude: -0.0235),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: .constant(region),
                interactionModes: [], // No interaction
                showsUserLocation: false,
                annotationItems: [MapFlower(flower: flower)]) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    OnboardingFlowerMapPin(flower: item.flower, flowerImage: onboardingFlowerImage)
                }
            }
            .disabled(true) // Ensure no interaction
            
            // Location label overlay - bottom left
            VStack {
                Spacer()
                HStack {
                    if let locationName = flower.discoveryLocationName {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10, design: .rounded))
                            Text(locationName)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.7))
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
}

// Simplified map pin for onboarding that uses the onboarding flower image
struct OnboardingFlowerMapPin: View {
    let flower: AIFlower
    let flowerImage: UIImage?
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                
                if let image = flowerImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "flower.fill")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.flowerPrimary)
                }
            }
            
            // Small pin tail
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 4, y: 6))
                path.addLine(to: CGPoint(x: -4, y: 6))
                path.closeSubpath()
            }
            .fill(Color.white)
            .frame(width: 8, height: 6)
            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        }
    }
}

struct UsernameSetupPageView: View {
    @AppStorage("userName") private var userName = ""
    @State private var tempUserName = ""
    @State private var showingUsernameAlert = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top spacer to move content to middle
            Spacer()
            
            // Main content centered
            VStack(spacing: 32) {
                // Icon
                Image(systemName: "at.circle")
                    .font(.system(size: 80, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                    .padding(.bottom, 16)
                
                // Title and description
                VStack(spacing: 16) {
                    Text("Choose your username")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundColor(.flowerTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Your username will be shown when you share flowers with friends. Use only letters and numbers.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Username input with @ prefix
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        // Fixed @ symbol
                        Text("@")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.flowerTextPrimary)
                            .padding(.leading, 16)
                        
                        // Username input field
                        TextField("username", text: $tempUserName)
                            .font(.system(size: 18, design: .rounded))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.asciiCapable)
                            .focused($isInputFocused)
                            .onSubmit {
                                saveUsername()
                            }
                            .onChange(of: tempUserName) { _, newValue in
                                // Filter input to only allow lowercase letters and numbers
                                let filtered = newValue.lowercased().filter { char in
                                    char.isLetter || char.isNumber
                                }
                                if filtered != newValue {
                                    tempUserName = filtered
                                }
                            }
                            .padding(.trailing, 16)
                            .padding(.vertical, 16)
                    }
                    .background(Color.flowerInputBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.flowerPrimary.opacity(0.3), lineWidth: 1)
                    )
                    
                    Text("Only letters and numbers allowed")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.flowerTextTertiary)
                }
                .padding(.horizontal, 40)
            }
            
            // Bottom spacer to keep content centered
            Spacer()
        }
        .onAppear {
            // Remove @ prefix if it exists for editing
            if userName.hasPrefix("@") {
                tempUserName = String(userName.dropFirst())
            } else {
                tempUserName = userName
            }
            // Auto-focus the input field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputFocused = true
            }
        }
        .onChange(of: tempUserName) { _, newValue in
            // Auto-save as user types
            saveUsername()
        }
    }
    
    private func saveUsername() {
        let filtered = tempUserName.lowercased().filter { char in
            char.isLetter || char.isNumber
        }
        
        if !filtered.isEmpty {
            userName = "@" + filtered
        } else {
            userName = ""
        }
    }
}

struct UsernameTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.flowerInputBackground)
            .cornerRadius(12)
            .font(.system(size: 18, design: .rounded))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.flowerPrimary.opacity(0.3), lineWidth: 1)
            )
    }
} 