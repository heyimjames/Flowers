import Foundation
import SwiftUI
import UIKit
import UserNotifications
import WeatherKit

@MainActor
class FlowerStore: ObservableObject {
    @Published var currentFlower: AIFlower?
    @Published var favorites: [AIFlower] = []
    @Published var discoveredFlowers: [AIFlower] = []
    @Published var herbariumSpecies: Set<String> = [] // Scientific names of collected species
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var hasUnrevealedFlower = false
    @Published var pendingFlower: AIFlower?
    @Published var nextFlowerTime: Date?
    @Published var shouldShowOnboarding = false
    
    @AppStorage("autoSaveToPhotos") var autoSaveToPhotos: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.OCTOBER.Flowers")
    private let favoritesKey = "favorites"
    private let dailyFlowerKey = "dailyFlower"
    private let dailyFlowerDateKey = "dailyFlowerDate"
    private let discoveredFlowersKey = "discoveredFlowers"
    private let herbariumSpeciesKey = "herbariumSpecies"
    private let pendingFlowerKey = "pendingFlower"
    private let lastScheduledDateKey = "lastScheduledFlowerDate"
    private let nextFlowerTimeKey = "nextFlowerTime"
    private let lastMilestoneKey = "lastMilestone"
    private let showTestFlowerOnNextLaunchKey = "showTestFlowerOnNextLaunch"
    private let apiConfig = APIConfiguration.shared
    
    // Milestone thresholds for achievement bouquets
    private let milestoneThresholds = [10, 25, 50, 100, 250, 500, 1000]
    
    // Test mode settings
    var showTestFlowerOnNextLaunch: Bool {
        get { userDefaults.bool(forKey: showTestFlowerOnNextLaunchKey) }
        set { 
            userDefaults.set(newValue, forKey: showTestFlowerOnNextLaunchKey)
            objectWillChange.send()
        }
    }
    
    // Computed properties for stats
    var totalDiscoveredCount: Int {
        discoveredFlowers.count
    }
    
    var uniqueSpeciesDiscoveredCount: Int {
        let uniqueScientificNames = Set(discoveredFlowers.compactMap { $0.scientificName })
        return uniqueScientificNames.count
    }
    
    var generatedFlowersCount: Int {
        discoveredFlowers.filter { flower in
            // Generated flowers have no ownership history (only original owner is current user)
            flower.ownershipHistory.isEmpty
        }.count
    }
    
    var receivedFlowersCount: Int {
        discoveredFlowers.filter { flower in
            // Received flowers have ownership history (transferred from others)
            !flower.ownershipHistory.isEmpty
        }.count
    }
    
    var herbariumSpeciesCount: Int {
        herbariumSpecies.count
    }
    
    var uniqueSpeciesDiscovered: Int {
        Set(discoveredFlowers.compactMap { $0.scientificName }).count
    }
    
    var herbariumCompletionPercentage: Double {
        // Estimate based on roughly 400,000 known flowering plant species
        // For UI purposes, we'll use a more achievable number like 10,000
        let totalEstimatedSpecies = 10000.0
        return Double(herbariumSpeciesCount) / totalEstimatedSpecies * 100.0
    }
    
    var allUsedFlowerNames: Set<String> {
        Set(discoveredFlowers.map { $0.name })
    }
    
    var continentStats: [Continent: Int] {
        var stats: [Continent: Int] = [:]
        for flower in discoveredFlowers {
            if let continent = flower.continent {
                stats[continent, default: 0] += 1
            }
        }
        return stats
    }
    
    var discoveryLocationStats: [String: Int] {
        var stats: [String: Int] = [:]
        for flower in discoveredFlowers {
            // Use discovery location name if available, otherwise determine from coordinates
            if let locationName = flower.discoveryLocationName {
                // Extract city/country from location name
                let locationKey = extractLocationKey(from: locationName)
                stats[locationKey, default: 0] += 1
            } else if let lat = flower.discoveryLatitude, let lon = flower.discoveryLongitude {
                // Determine continent from coordinates
                let continent = continentFromCoordinates(latitude: lat, longitude: lon)
                stats[continent.rawValue, default: 0] += 1
            }
        }
        return stats
    }
    
    private func extractLocationKey(from locationName: String) -> String {
        // Extract the most relevant part of the location name
        // Format is typically "City, State/Province, Country"
        let components = locationName.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // If we have a city and country, use "City, Country"
        if components.count >= 2 {
            if components.count == 3 {
                // Format: City, State, Country - use City, Country
                return "\(components[0]), \(components[2])"
            } else {
                // Format: City, Country - use as is
                return "\(components[0]), \(components[1])"
            }
        } else {
            // Just use the full location name if we can't parse it
            return locationName
        }
    }
    
    private func continentFromCoordinates(latitude: Double, longitude: Double) -> Continent {
        // Simplified continent detection based on coordinates
        // This is a rough approximation
        
        // Antarctica (below -60 latitude)
        if latitude < -60 {
            return .antarctica
        }
        
        // Africa (roughly -35 to 37 latitude, -20 to 55 longitude)
        if latitude >= -35 && latitude <= 37 && longitude >= -20 && longitude <= 55 {
            return .africa
        }
        
        // Europe (roughly 35 to 71 latitude, -10 to 60 longitude)
        if latitude >= 35 && latitude <= 71 && longitude >= -10 && longitude <= 60 {
            return .europe
        }
        
        // Asia (roughly -10 to 71 latitude, 60 to 180 longitude)
        if latitude >= -10 && latitude <= 71 && longitude >= 60 && longitude <= 180 {
            return .asia
        }
        
        // Oceania (roughly -50 to -10 latitude, 110 to 180 longitude)
        if latitude >= -50 && latitude <= -10 && longitude >= 110 && longitude <= 180 {
            return .oceania
        }
        
        // South America (roughly -55 to 12 latitude, -80 to -35 longitude)
        if latitude >= -55 && latitude <= 12 && longitude >= -80 && longitude <= -35 {
            return .southAmerica
        }
        
        // North America (roughly 15 to 71 latitude, -170 to -50 longitude)
        if latitude >= 15 && latitude <= 71 && longitude >= -170 && longitude <= -50 {
            return .northAmerica
        }
        
        // Default fallback based on simple longitude
        if longitude < -30 {
            return latitude > 0 ? .northAmerica : .southAmerica
        } else if longitude < 60 {
            return latitude > 0 ? .europe : .africa
        } else {
            return latitude > 0 ? .asia : .oceania
        }
    }
    

    
    init() {
        // Check if first time user before loading data
        let isFirstTimeUser = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        loadFavorites()
        loadDiscoveredFlowers()
        loadHerbariumSpecies()
        
        // Add Jenny flower for first-time users IMMEDIATELY
        if isFirstTimeUser &&
           !discoveredFlowers.contains(where: { $0.name == "Jennifer's Blessing" }) {
            // Create Jenny flower synchronously to ensure it's there when onboarding starts
            createJennyFlowerSynchronously()
        }
        
        checkForPendingFlower()
        loadNextFlowerTime()
        
        // Check if test flower should be shown
        if showTestFlowerOnNextLaunch {
            print("Test flower flag detected, creating test flower...")
            // Reset the flag immediately BEFORE generating to prevent multiple triggers
            self.showTestFlowerOnNextLaunch = false
            
            // Generate and show test flower
            Task { @MainActor in
                await generateTestFlowerForReveal()
            }
        } else if !isFirstTimeUser {
            // Only check for scheduled flowers if not a first-time user
            // This prevents new users from getting flowers for past dates
            checkForScheduledFlowerToday()
            
            // Schedule next flower if needed
            scheduleNextFlowerIfNeeded()
        }
        
        // Check for iCloud data on first launch
        Task { @MainActor in
            await iCloudSyncManager.shared.mergeWithICloudData(flowerStore: self)
        }
    }
    
    // MARK: - Special Flowers
    
    private func addJennyFlower() {
        Task {
            do {
                // Generate the Jennifer's Blessing flower image
                let descriptor = "elegant pink and white rose with delicate petals, soft romantic colors, graceful and beautiful"
                let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: descriptor)
                guard let imageData = image.pngData() else { return }
                
                // Create the Jenny flower with specific attributes
                let jennyFlower = AIFlower(
                    name: "Jennifer's Blessing",
                    descriptor: descriptor,
                    imageData: imageData,
                    generatedDate: Date(timeIntervalSince1970: 1669334400), // Nov 25, 2022
                    isFavorite: true, // Auto-favorite this special flower
                    meaning: "A symbol of kindness, beauty, and joy. This flower represents the light that special people bring into our lives.",
                    properties: "This special flower is a personal gift to you from James, the creator of this app, named in celebration of his fiancée Jenny. Her kindness, beauty, and humor light up the lives of everyone she meets. Like this flower, she brings joy wherever she goes. 💝",
                    origins: "First discovered in Canary Wharf, London, where love bloomed alongside the Thames.",
                    detailedDescription: "Jennifer's Blessing is more than just a flower – it's a gift from the app's creator to you. James named this flower after his fiancée Jenny, whose remarkable ability to brighten any space she inhabits mirrors this flower's beauty. It stands as a testament to love and the joy that special people bring into our world. Consider this flower a personal welcome gift as you begin your journey.",
                    continent: nil,
                    discoveryDate: Date(timeIntervalSince1970: 1669334400),
                    contextualGeneration: false,
                    generationContext: nil,
                    isBouquet: false,
                    bouquetFlowers: nil,
                    holidayName: nil,
                    discoveryLatitude: 51.5054, // Canary Wharf coordinates
                    discoveryLongitude: -0.0235,
                    discoveryLocationName: "Canary Wharf, London",
                    originalOwner: FlowerOwner(name: "James (App Creator)", deviceID: "Creator", transferDate: Date(timeIntervalSince1970: 1669334400), location: "Canary Wharf, London"),
                    isGiftable: false // Special flower cannot be gifted
                )
                
                await MainActor.run {
                    // Add to discovered flowers
                    self.discoveredFlowers.insert(jennyFlower, at: 0)
                    self.favorites.insert(jennyFlower, at: 0)
                    self.saveDiscoveredFlowers()
                    self.saveFavorites()
                    
                    // Mark as received
                    UserDefaults.standard.set(true, forKey: "hasReceivedJennyFlower")
                }
            } catch {
                print("Failed to create Jenny flower: \(error)")
            }
        }
    }
    
    private func createJennyFlowerSynchronously() {
        // Use a placeholder image for Jenny flower to ensure it's available immediately
        var jennyFlower = AIFlower(
            name: "Jennifer's Blessing",
            descriptor: "elegant pink and white rose with delicate petals, soft romantic colors, graceful and beautiful",
            imageData: UIImage(systemName: "flower.fill")?.pngData(), // Placeholder initially
            generatedDate: Date(timeIntervalSince1970: 1669334400), // Nov 25, 2022
            isFavorite: true, // Auto-favorite this special flower
            meaning: "A symbol of kindness, beauty, and joy. This flower represents the light that special people bring into our lives.",
            properties: "This special flower is a personal gift to you from James, the creator of this app, named in celebration of his fiancée Jenny. Her kindness, beauty, and humor light up the lives of everyone she meets. Like this flower, she brings joy wherever she goes. 💝",
            origins: "First discovered in Canary Wharf, London, where love bloomed alongside the Thames.",
            detailedDescription: "Jennifer's Blessing is more than just a flower – it's a gift from the app's creator to you. James named this flower after his fiancée Jenny, whose remarkable ability to brighten any space she inhabits mirrors this flower's beauty. It stands as a testament to love and the joy that special people bring into our world. Consider this flower a personal welcome gift as you begin your journey.",
            continent: nil,
            discoveryDate: Date(timeIntervalSince1970: 1669334400),
            contextualGeneration: false,
            generationContext: nil,
            isBouquet: false,
            bouquetFlowers: nil,
            holidayName: nil,
            discoveryLatitude: 51.5055, // London coordinates
            discoveryLongitude: -0.0196,
            discoveryLocationName: "Canary Wharf, London",
            originalOwner: FlowerOwner(name: "James (App Creator)", deviceID: "Creator", transferDate: Date(timeIntervalSince1970: 1669334400), location: "Canary Wharf, London"),
            isGiftable: false // Special flower cannot be gifted
        )
        
        // Set weather data for Jennifer's Blessing (a beautiful autumn day in London)
        jennyFlower.captureWeatherAndDate(
            weatherCondition: "Partly Cloudy",
            temperature: 15.0,
            temperatureUnit: "°C"
        )
        
        // Add to discovered flowers immediately
        self.discoveredFlowers.insert(jennyFlower, at: 0)
        self.favorites.insert(jennyFlower, at: 0)
        self.saveDiscoveredFlowers()
        self.saveFavorites()
        
        // Mark as received
        UserDefaults.standard.set(true, forKey: "hasReceivedJennyFlower")
        
        // Generate the actual image asynchronously to replace the placeholder
        Task {
            do {
                let descriptor = "elegant pink and white rose with delicate petals, soft romantic colors, graceful and beautiful"
                let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: descriptor)
                guard let imageData = image.pngData() else { return }
                
                await MainActor.run {
                    // Find and update the Jenny flower with the real image
                    if let index = self.discoveredFlowers.firstIndex(where: { $0.name == "Jennifer's Blessing" }) {
                        let oldFlower = self.discoveredFlowers[index]
                        
                        // Create a new flower with updated imageData
                        var updatedFlower = AIFlower(
                            id: oldFlower.id,
                            name: oldFlower.name,
                            descriptor: oldFlower.descriptor,
                            imageData: imageData,
                            generatedDate: oldFlower.generatedDate,
                            isFavorite: oldFlower.isFavorite,
                            meaning: oldFlower.meaning,
                            properties: oldFlower.properties,
                            origins: oldFlower.origins,
                            detailedDescription: oldFlower.detailedDescription,
                            continent: oldFlower.continent,
                            discoveryDate: oldFlower.discoveryDate,
                            contextualGeneration: oldFlower.contextualGeneration,
                            generationContext: oldFlower.generationContext,
                            isBouquet: oldFlower.isBouquet,
                            bouquetFlowers: oldFlower.bouquetFlowers,
                            holidayName: oldFlower.holidayName,
                            discoveryLatitude: oldFlower.discoveryLatitude,
                            discoveryLongitude: oldFlower.discoveryLongitude,
                            discoveryLocationName: oldFlower.discoveryLocationName,
                            originalOwner: oldFlower.originalOwner,
                            ownershipHistory: oldFlower.ownershipHistory,
                            transferToken: oldFlower.transferToken,
                            isGiftable: oldFlower.isGiftable
                        )
                        
                        // Preserve weather data
                        updatedFlower.discoveryWeatherCondition = oldFlower.discoveryWeatherCondition
                        updatedFlower.discoveryTemperature = oldFlower.discoveryTemperature
                        updatedFlower.discoveryTemperatureUnit = oldFlower.discoveryTemperatureUnit
                        updatedFlower.discoveryDayOfWeek = oldFlower.discoveryDayOfWeek
                        updatedFlower.discoveryFormattedDate = oldFlower.discoveryFormattedDate
                        
                        self.discoveredFlowers[index] = updatedFlower
                        
                        // Update in favorites too
                        if let favIndex = self.favorites.firstIndex(where: { $0.name == "Jennifer's Blessing" }) {
                            self.favorites[favIndex] = updatedFlower
                        }
                        
                        self.saveDiscoveredFlowers()
                        self.saveFavorites()
                    }
                }
            } catch {
                print("Failed to generate real image for Jenny flower: \(error)")
            }
        }
    }
    
    // MARK: - Daily Flower Scheduling
    func scheduleNextFlowerIfNeeded() {
        // Check if we already have a pending flower
        if hasUnrevealedFlower || pendingFlower != nil {
            return
        }
        
        // Check if we've already shown a flower today
        if hasShownFlowerToday() {
            return
        }
        
        // Get today's scheduled time
        guard let todayScheduledTime = FlowerNotificationSchedule.getScheduledTime(for: Date()) else { 
            print("No scheduled time found for today")
            return 
        }
        
        // If the time hasn't passed yet, schedule it
        if todayScheduledTime > Date() {
            scheduleFlowerForToday()
        } else {
            // Time has passed, schedule for next available time
            if let nextTime = FlowerNotificationSchedule.getNextScheduledTime() {
                Task {
                    await generateDailyFlowerAndScheduleNotification(at: nextTime)
                    await MainActor.run {
                        self.nextFlowerTime = nextTime
                        self.userDefaults.set(nextTime, forKey: self.nextFlowerTimeKey)
                    }
                }
            }
        }
    }
    
    func scheduleFlowerForToday() {
        // Get the pre-chosen time for today from our schedule
        guard let scheduledDate = FlowerNotificationSchedule.getScheduledTime(for: Date()) else { 
            print("No scheduled time found for today")
            return 
        }
        
        // If the time has already passed today, generate the flower now
        if scheduledDate < Date() {
            Task {
                await generateDailyFlower()
            }
            nextFlowerTime = nil
        } else {
            // Generate the flower first, then schedule notification with its name
            Task {
                await generateDailyFlowerAndScheduleNotification(at: scheduledDate)
            }
            nextFlowerTime = scheduledDate
            userDefaults.set(scheduledDate, forKey: nextFlowerTimeKey)
        }
        
        userDefaults.set(Date(), forKey: lastScheduledDateKey)
    }
    
    func scheduleFlowerForTomorrow() {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) else { return }
        
        // Get the pre-chosen time for tomorrow from our schedule
        guard let scheduledDate = FlowerNotificationSchedule.getScheduledTime(for: tomorrow) else { 
            print("No scheduled time found for tomorrow")
            return 
        }
        
        // Generate the flower first, then schedule notification with its name
        Task {
            await generateDailyFlowerAndScheduleNotification(at: scheduledDate)
        }
        nextFlowerTime = scheduledDate
        userDefaults.set(scheduledDate, forKey: nextFlowerTimeKey)
        userDefaults.set(tomorrow, forKey: lastScheduledDateKey)
    }
    
    func generateDailyFlowerAndScheduleNotification(at date: Date) async {
        // Check if we already have a pending flower
        if hasUnrevealedFlower || pendingFlower != nil {
            // Already have a flower waiting, just reschedule the notification
            guard let flower = pendingFlower else { return }
            
            // Generate notification for existing flower
            var notificationTitle = "A new flower awaits 🌸"
            var notificationBody = "\(flower.name) is ready. Tap to discover its beauty."
            
            if apiConfig.hasValidOpenAIKey {
                do {
                    let customMessage = try await OpenAIService.shared.generateFlowerNotification(
                        flowerName: flower.name,
                        isBouquet: flower.isBouquet,
                        holidayName: flower.holidayName
                    )
                    notificationTitle = customMessage.title
                    notificationBody = customMessage.body
                } catch {
                    print("Failed to generate custom notification: \(error)")
                }
            }
            
            scheduleFlowerNotification(at: date, title: notificationTitle, body: notificationBody)
            return
        }
        
        // Additional safety check - don't generate if we've shown a flower today
        if hasShownFlowerToday() {
            print("Already shown a flower today, skipping generation")
            return
        }
        
        // Generate the flower now
        await generateNewFlower(isDaily: true)
        
        // Get the generated flower's name
        guard let flower = pendingFlower else { return }
        
        // Generate custom notification message using OpenAI if available
        var notificationTitle = "A new flower awaits 🌸"
        var notificationBody = "\(flower.name) is ready. Tap to discover its beauty."
        
        if apiConfig.hasValidOpenAIKey {
            do {
                let customMessage = try await OpenAIService.shared.generateFlowerNotification(
                    flowerName: flower.name,
                    isBouquet: flower.isBouquet,
                    holidayName: flower.holidayName
                )
                notificationTitle = customMessage.0
                notificationBody = customMessage.1
            } catch {
                // Use default messages if generation fails
                print("Failed to generate custom notification: \(error)")
            }
        }
        
        // Schedule the notification
        scheduleFlowerNotification(at: date, title: notificationTitle, body: notificationBody)
    }
    
    func scheduleFlowerNotification(at date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        // Ensure the app icon is used in the notification
        content.interruptionLevel = .timeSensitive
        
        // Convert the Lisbon time to user's local time
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "daily.flower",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Scheduled notification for \(date)")
            }
        }
    }
    
    // MARK: - Debug Methods
    func scheduleDebugNotification(in seconds: Int) {
        Task {
            // Generate the flower first
            await generateNewFlower(isDaily: true)
            
            // Get the generated flower's name
            guard let flower = pendingFlower else { return }
            
            // Generate custom notification message
            var notificationTitle = "A new flower awaits 🌸"
            var notificationBody = "\(flower.name) is ready. Tap to discover its beauty."
            
            if apiConfig.hasValidOpenAIKey {
                do {
                    let customMessage = try await OpenAIService.shared.generateFlowerNotification(
                        flowerName: flower.name,
                        isBouquet: flower.isBouquet,
                        holidayName: flower.holidayName
                    )
                    notificationTitle = customMessage.0
                    notificationBody = customMessage.1
                } catch {
                    print("Failed to generate custom notification: \(error)")
                }
            }
            
            // Schedule the notification
            let content = UNMutableNotificationContent()
            content.title = notificationTitle
            content.body = notificationBody
            content.sound = .default
            content.badge = 1
            // Ensure the app icon is used in the notification
            content.interruptionLevel = .timeSensitive
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "debug.flower",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling debug notification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Daily Flower Management
    func loadNextFlowerTime() {
        // Always use the pre-chosen schedule to determine next flower time
        nextFlowerTime = FlowerNotificationSchedule.getNextScheduledTime()
    }
    
    func checkForPendingFlower() {
        // Check if we have a pending flower to reveal
        if let flowerData = userDefaults.data(forKey: pendingFlowerKey),
           let flower = try? JSONDecoder().decode(AIFlower.self, from: flowerData) {
            pendingFlower = flower
            // Don't automatically show the reveal screen on app launch
            // Only show it when explicitly triggered by notification tap or test mode
            hasUnrevealedFlower = false
            
            // Clear any stale pending flower from previous days
            if !Calendar.current.isDateInToday(flower.generatedDate) {
                // This is an old flower, clear it
                pendingFlower = nil
                userDefaults.removeObject(forKey: pendingFlowerKey)
            }
        }
    }
    
    func checkForScheduledFlowerToday() {
        // Don't generate if we already have a pending flower
        if pendingFlower != nil {
            return
        }
        
        // Get today's scheduled time
        guard let todayScheduledTime = FlowerNotificationSchedule.getScheduledTime(for: Date()) else { return }
        
        // If the scheduled time has passed and we haven't generated today's flower yet
        if todayScheduledTime < Date() {
            // Check if we've already generated a flower today
            if let lastScheduled = userDefaults.object(forKey: lastScheduledDateKey) as? Date,
               Calendar.current.isDateInToday(lastScheduled) {
                // We've already handled today
                return
            }
            
            // Check if we've already revealed a flower today
            if let lastFlower = currentFlower, 
               let discoveryDate = lastFlower.discoveryDate,
               Calendar.current.isDateInToday(discoveryDate) {
                // User already revealed today's flower
                return
            }
            
            // Generate the flower now since the time has passed
            Task {
                await generateDailyFlower()
                await MainActor.run {
                    self.userDefaults.set(Date(), forKey: self.lastScheduledDateKey)
                }
            }
        }
    }
    
    // Call this when the app becomes active from a notification
    func showPendingFlowerIfAvailable() {
        if pendingFlower != nil {
            hasUnrevealedFlower = true
        }
    }
    
    func revealPendingFlower() {
        guard var flower = pendingFlower else { return }
        
        // Update discovery date to current time and capture current location
        flower.discoveryDate = Date()
        if let currentLocation = ContextualFlowerGenerator.shared.currentLocation {
            flower.discoveryLatitude = currentLocation.coordinate.latitude
            flower.discoveryLongitude = currentLocation.coordinate.longitude
        }
        if let currentPlacemark = ContextualFlowerGenerator.shared.currentPlacemark {
            flower.discoveryLocationName = currentPlacemark.locality ?? currentPlacemark.name
        }
        
        // Capture current weather data
        if let weather = ContextualFlowerGenerator.shared.currentWeather {
            let weatherCondition = OnboardingAssetsService.getWeatherConditionString(from: weather.currentWeather.condition)
            let temperature = weather.currentWeather.temperature.value
            flower.captureWeatherAndDate(
                weatherCondition: weatherCondition,
                temperature: temperature,
                temperatureUnit: "°C"
            )
        }
        
        currentFlower = flower
        hasUnrevealedFlower = false
        pendingFlower = nil
        
        // Add to discovered flowers
        addToDiscoveredFlowers(flower)
        
        // Save to shared container for widget
        if let encoded = try? JSONEncoder().encode(flower) {
            sharedDefaults?.set(encoded, forKey: dailyFlowerKey)
            sharedDefaults?.set(Date(), forKey: dailyFlowerDateKey)
        }
        
        // Clear pending flower from storage
        userDefaults.removeObject(forKey: pendingFlowerKey)
        
        // Clear notification badge
        UNUserNotificationCenter.current().setBadgeCount(0)
        
        // Get the next scheduled flower time
        nextFlowerTime = FlowerNotificationSchedule.getNextScheduledTime()
        
        // Schedule the next flower if there is one
        if let nextTime = nextFlowerTime {
            Task {
                await generateDailyFlowerAndScheduleNotification(at: nextTime)
            }
        }
    }
    
    func generateDailyFlower() {
        Task {
            await generateNewFlower(isDaily: true)
        }
    }
    
    // MARK: - Flower Generation
    func generateNewFlower(descriptor: String? = nil, isDaily: Bool = false) async {
        isGenerating = true
        errorMessage = nil
        
        do {
            var selectedSpecies: BotanicalSpecies?
            var actualDescriptor: String
            var flowerContext: FlowerContext?
            var isContextual = false
            var isBouquet = false
            var holiday: Holiday?
            
            // Check for holidays first - bouquets take priority
            if let currentHoliday = ContextualFlowerGenerator.shared.getCurrentHoliday(),
               currentHoliday.isBouquetWorthy && descriptor == nil {
                holiday = currentHoliday
                isBouquet = true
                actualDescriptor = currentHoliday.bouquetTheme ?? "festive holiday bouquet"
                isContextual = true
            }
            // Otherwise select a real botanical species
            else if descriptor == nil {
                // Get list of existing species to avoid duplicates
                let existingSpecies = discoveredFlowers.compactMap { $0.scientificName }
                
                // Try contextual selection first
                if let contextualResult = ContextualFlowerGenerator.shared.selectContextualSpecies(existingSpecies: existingSpecies) {
                    selectedSpecies = contextualResult.species
                    flowerContext = contextualResult.context
                    isContextual = true
                    actualDescriptor = selectedSpecies!.imagePrompt
                } else {
                    // Fallback to random species
                    selectedSpecies = ContextualFlowerGenerator.shared.getRandomSpecies(existingSpecies: existingSpecies)
                    actualDescriptor = selectedSpecies?.imagePrompt ?? "Rosa damascena damask rose with double pink fragrant flowers"
                }
            }
            else {
                // Use provided descriptor (for custom flowers)
                actualDescriptor = descriptor ?? "beautiful flower with elegant petals"
            }
            
            // Use FAL for image generation with botanically accurate prompts
            let imageDescriptor = selectedSpecies?.imagePrompt ?? actualDescriptor
            let (image, prompt) = try await FALService.shared.generateFlowerImage(
                descriptor: imageDescriptor, 
                isBouquet: isBouquet,
                personalMessage: holiday?.personalMessage
            )
            
            // Convert UIImage to Data
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                throw NSError(domain: "FlowerStore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
            }
            
            // Check if this is the user's first flower
            let isFirstFlower = discoveredFlowers.isEmpty && userDefaults.object(forKey: "hasGeneratedFirstFlower") == nil
            
            // Generate appropriate name based on type
            let name: String
            var bouquetFlowerNames: [String]?
            
            if isBouquet {
                // Generate bouquet name
                if let customName = holiday?.customFlowerName {
                    name = customName
                } else if let holidayName = holiday?.name {
                    name = "\(holidayName) Bouquet"
                } else {
                    name = "Special Occasion Bouquet"
                }
                
                // Generate list of flowers in the bouquet
                bouquetFlowerNames = generateBouquetFlowerNames(for: holiday)
            } else if let species = selectedSpecies {
                // Use real botanical species name
                if isFirstFlower {
                    name = "Jenny's \(species.primaryCommonName)"
                    userDefaults.set(true, forKey: "hasGeneratedFirstFlower")
                } else {
                    name = OpenAIService.shared.generateFlowerName(species: species, context: flowerContext)
                }
            } else if apiConfig.hasValidOpenAIKey {
                // Fallback to OpenAI generation for custom flowers
                if isFirstFlower {
                    name = try await OpenAIService.shared.generateJennyFlowerName(
                        descriptor: actualDescriptor,
                        existingNames: allUsedFlowerNames
                    )
                    userDefaults.set(true, forKey: "hasGeneratedFirstFlower")
                } else {
                    name = try await OpenAIService.shared.generateFlowerNameLegacy(
                        descriptor: actualDescriptor,
                        existingNames: allUsedFlowerNames,
                        context: flowerContext
                    )
                }
            } else {
                // Final fallback if no API key
                if isFirstFlower {
                    name = "Jenny's \(extractFlowerName(from: actualDescriptor))"
                    userDefaults.set(true, forKey: "hasGeneratedFirstFlower")
                } else {
                    name = extractFlowerName(from: actualDescriptor)
                }
            }
            
            // Determine location to use
            let latitude: Double?
            let longitude: Double?
            let locationName: String?
            
            if let customLocation = holiday?.customLocation {
                // Use custom holiday location
                latitude = customLocation.latitude
                longitude = customLocation.longitude
                locationName = customLocation.name
            } else {
                // Use current location
                let currentLocation = ContextualFlowerGenerator.shared.currentLocation
                let currentPlacemark = ContextualFlowerGenerator.shared.currentPlacemark
                latitude = currentLocation?.coordinate.latitude
                longitude = currentLocation?.coordinate.longitude
                locationName = currentPlacemark?.locality ?? currentPlacemark?.name
            }
            
            // Create flower with real botanical information
            var flower = AIFlower(
                name: name,
                descriptor: selectedSpecies?.description ?? actualDescriptor,
                imageData: imageData,
                generatedDate: Date(),
                isFavorite: false,
                scientificName: selectedSpecies?.scientificName,
                commonNames: selectedSpecies?.commonNames,
                family: selectedSpecies?.family,
                nativeRegions: selectedSpecies?.nativeRegions,
                bloomingSeason: selectedSpecies?.bloomingSeason,
                conservationStatus: selectedSpecies?.conservationStatus,
                uses: selectedSpecies?.uses,
                interestingFacts: selectedSpecies?.interestingFacts,
                careInstructions: selectedSpecies?.careInstructions,
                rarityLevel: selectedSpecies?.rarityLevel,
                discoveryDate: Date(),
                contextualGeneration: isContextual,
                generationContext: isContextual ? "\(selectedSpecies?.scientificName ?? actualDescriptor)" : nil,
                isBouquet: isBouquet,
                bouquetFlowers: bouquetFlowerNames,
                holidayName: holiday?.name,
                discoveryLatitude: latitude,
                discoveryLongitude: longitude,
                discoveryLocationName: locationName,
                isInHerbarium: false, // Will be set when added to herbarium
                originalOwner: createCurrentOwner()
            )
            
            // Set continent from botanical species data
            flower.continent = selectedSpecies?.primaryContinent ?? Continent.allCases.randomElement()
            
            // Capture weather and date information
            if let weather = ContextualFlowerGenerator.shared.currentWeather {
                let condition = weather.currentWeather.condition
                let temperature = weather.currentWeather.temperature
                
                // Convert weather condition to readable string
                let weatherCondition: String
                switch condition {
                case .clear:
                    weatherCondition = "Sunny"
                case .cloudy:
                    weatherCondition = "Cloudy"
                case .mostlyCloudy:
                    weatherCondition = "Mostly Cloudy"
                case .partlyCloudy:
                    weatherCondition = "Partly Cloudy"
                case .rain:
                    weatherCondition = "Rainy"
                case .drizzle:
                    weatherCondition = "Drizzle"
                case .snow:
                    weatherCondition = "Snowy"
                case .sleet:
                    weatherCondition = "Sleet"
                case .hail:
                    weatherCondition = "Hail"
                case .thunderstorms:
                    weatherCondition = "Thunderstorms"
                case .haze:
                    weatherCondition = "Hazy"
                case .smoky:
                    weatherCondition = "Smoky"
                case .breezy:
                    weatherCondition = "Breezy"
                case .windy:
                    weatherCondition = "Windy"
                case .hot:
                    weatherCondition = "Hot"
                case .frigid:
                    weatherCondition = "Frigid"
                default:
                    weatherCondition = "Unknown"
                }
                
                flower.captureWeatherAndDate(
                    weatherCondition: weatherCondition,
                    temperature: temperature.value,
                    temperatureUnit: temperature.unit == .celsius ? "°C" : "°F"
                )
            } else {
                // Capture date info even without weather
                flower.captureWeatherAndDate(
                    weatherCondition: nil,
                    temperature: nil,
                    temperatureUnit: nil
                )
            }
            
            // Generate accurate botanical details for real species
            if apiConfig.hasValidOpenAIKey {
                do {
                    let details = try await OpenAIService.shared.generateFlowerDetails(
                        for: flower, 
                        species: selectedSpecies, 
                        context: flowerContext
                    )
                    flower.meaning = details.meaning
                    flower.properties = details.properties
                    flower.origins = details.origins
                    flower.detailedDescription = details.detailedDescription
                    
                    // Only override continent if not already set from species data
                    if selectedSpecies == nil {
                        flower.continent = Continent(rawValue: details.continent) ?? flower.continent
                    }
                    
                    // Add contextual meaning if available
                    if let contextualMeaning = flowerContext?.generateContextualMeaning() {
                        flower.meaning = (flower.meaning ?? "") + " " + contextualMeaning
                    }
                    
                    // Add personal message to properties if this is a special holiday flower
                    if let personalMessage = holiday?.personalMessage {
                        flower.properties = (flower.properties ?? "") + "\n\n" + personalMessage
                    }
                } catch {
                    // Use botanical species data as fallback
                    if let species = selectedSpecies {
                        flower.meaning = "This \(species.primaryCommonName) represents the natural beauty and diversity of our botanical world."
                        flower.properties = species.description
                        flower.origins = "Native to \(species.nativeRegions.joined(separator: ", ")). \(species.habitat)."
                        flower.detailedDescription = "\(species.description) Blooms \(species.bloomingSeason.lowercased()). Conservation status: \(species.conservationStatus)."
                    } else {
                        print("Failed to generate flower details: \(error)")
                        errorMessage = "Flower created, but details unavailable"
                    }
                }
            } else if let species = selectedSpecies {
                // Use botanical species data when no API key
                flower.meaning = createMeaningForSpecies(species)
                flower.properties = species.interestingFacts.first ?? species.description
                flower.origins = createOriginsForSpecies(species)
                flower.detailedDescription = createDetailedDescriptionForSpecies(species)
            }
            
            if isDaily {
                // Store as pending flower instead of current
                pendingFlower = flower
                hasUnrevealedFlower = true
                
                // Save pending flower
                if let encoded = try? JSONEncoder().encode(flower) {
                    userDefaults.set(encoded, forKey: pendingFlowerKey)
                }
                
                // Clear next flower time since the flower has bloomed
                nextFlowerTime = nil
                userDefaults.removeObject(forKey: nextFlowerTimeKey)
            } else {
                // Immediate reveal for manual generation
                currentFlower = flower
                
                // Add to discovered flowers and herbarium if it's a new species
                addToDiscoveredFlowers(flower, autoSaveToPhotos: true)
                
                // Save to shared container for widget
                if let encoded = try? JSONEncoder().encode(flower) {
                    sharedDefaults?.set(encoded, forKey: dailyFlowerKey)
                    sharedDefaults?.set(Date(), forKey: dailyFlowerDateKey)
                }
            }
            
        } catch {
            // If API fails or no API key, fall back to mock
            if !apiConfig.hasValidFalKey {
                let flower = createMockFlower(descriptor: descriptor)
                if isDaily {
                    pendingFlower = flower
                    hasUnrevealedFlower = true
                } else {
                    currentFlower = flower
                    addToDiscoveredFlowers(flower)
                }
                errorMessage = "No FAL API key configured. Using placeholder images."
            } else {
                errorMessage = error.localizedDescription
                // Create a mock flower as fallback
                let flower = createMockFlower(descriptor: descriptor)
                if isDaily {
                    pendingFlower = flower
                    hasUnrevealedFlower = true
                } else {
                    currentFlower = flower
                    addToDiscoveredFlowers(flower)
                }
            }
        }
        
        isGenerating = false
    }
    
    private func generateBouquetFlowerNames(for holiday: Holiday?) -> [String] {
        // Generate appropriate flower names based on the holiday
        if let holiday = holiday {
            switch holiday.name {
            case "Valentine's Day":
                return ["Red Roses", "Pink Lilies", "White Carnations", "Baby's Breath"]
            case "Mother's Day":
                return ["Pink Peonies", "White Gardenias", "Lavender", "Yellow Roses"]
            case "Christmas":
                return ["Red Poinsettias", "White Roses", "Holly Berries", "Pine Branches"]
            case "Halloween":
                return ["Orange Marigolds", "Deep Purple Roses", "Black Dahlias", "Autumn Leaves"]
            case "St. Patrick's Day":
                return ["Green Carnations", "White Roses", "Shamrocks", "Green Bells of Ireland"]
            case "New Year":
                return ["White Roses", "Gold Chrysanthemums", "Silver Dusty Miller", "Sparkle Baby's Breath"]
            case "International Women's Day":
                return ["Purple Orchids", "Yellow Tulips", "Pink Roses", "White Daisies"]
            case "Father's Day":
                return ["Sunflowers", "Blue Delphiniums", "White Roses", "Green Ferns"]
            case "Thanksgiving":
                return ["Orange Chrysanthemums", "Burgundy Dahlias", "Wheat Stalks", "Fall Berries"]
            case "May Day":
                return ["Mixed Wildflowers", "Daisies", "Lavender", "Sweet Peas"]
            default:
                return ["Mixed Roses", "Seasonal Blooms", "Garden Flowers", "Fresh Greens"]
            }
        }
        return ["Assorted Flowers", "Mixed Blooms", "Garden Varieties"]
    }
    
    private func extractFlowerName(from descriptor: String) -> String {
        // Extract the main flower type from the descriptor
        let components = descriptor.components(separatedBy: " ")
        if components.count >= 2 {
            // Try to find the flower type (usually the last word or two)
            if descriptor.contains("rose") {
                return components.filter { $0.contains("rose") || components.firstIndex(of: $0)! == components.firstIndex(of: "rose")! - 1 }.joined(separator: " ").capitalized
            } else if descriptor.contains("orchid") {
                return components.filter { $0.contains("orchid") || components.firstIndex(of: $0)! == components.firstIndex(of: "orchid")! - 1 }.joined(separator: " ").capitalized
            } else if descriptor.contains("lily") {
                return components.filter { $0.contains("lily") || components.firstIndex(of: $0)! == components.firstIndex(of: "lily")! - 1 }.joined(separator: " ").capitalized
            } else {
                // Default: take first two words and capitalize
                return components.prefix(2).joined(separator: " ").capitalized
            }
        }
        return descriptor.capitalized
    }
    
    private func createMockFlower(descriptor: String? = nil) -> AIFlower {
        let name = FlowerNameGenerator.generateName()
        let desc = descriptor ?? FlowerNameGenerator.generateDescriptor()
        
        // Create a gradient image as placeholder
        let imageData = createPlaceholderImage()
        
        return AIFlower(
            name: name,
            descriptor: desc,
            imageData: imageData,
            continent: Continent.allCases.randomElement(),
            discoveryDate: Date(),
            originalOwner: createCurrentOwner()
        )
    }
    
    private func createPlaceholderImage() -> Data? {
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Create a beautiful gradient placeholder
            let colors = [
                UIColor(red: 0.9, green: 0.7, blue: 0.9, alpha: 1.0).cgColor,
                UIColor(red: 0.7, green: 0.5, blue: 0.8, alpha: 1.0).cgColor,
                UIColor(red: 0.5, green: 0.6, blue: 0.9, alpha: 1.0).cgColor
            ]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0.0, 0.5, 1.0]
            )!
            
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                startRadius: 0,
                endCenter: CGPoint(x: size.width * 0.7, y: size.height * 0.7),
                endRadius: size.width * 0.8,
                options: []
            )
        }
        
        return image.pngData()
    }
    
    // MARK: - Helper Methods
    
    private func hasShownFlowerToday() -> Bool {
        // Check if we have a current flower that was discovered today
        if let currentFlower = currentFlower,
           let discoveryDate = currentFlower.discoveryDate,
           Calendar.current.isDateInToday(discoveryDate) {
            return true
        }
        
        // Check if we have a pending flower from today
        if let pendingFlower = pendingFlower,
           Calendar.current.isDateInToday(pendingFlower.generatedDate) {
            return true
        }
        
        // Check the last scheduled date
        if let lastScheduled = userDefaults.object(forKey: lastScheduledDateKey) as? Date,
           Calendar.current.isDateInToday(lastScheduled) {
            return true
        }
        
        return false
    }
    
    // MARK: - Favorites Management
    func toggleFavorite() {
        guard var flower = currentFlower else { return }
        
        flower.isFavorite.toggle()
        currentFlower = flower
        
        if flower.isFavorite {
            // Make sure we're adding the flower with all its current details
            favorites.insert(flower, at: 0)
        } else {
            favorites.removeAll { $0.id == flower.id }
        }
        
        // Also update in discovered flowers to keep everything in sync
        if let index = discoveredFlowers.firstIndex(where: { $0.id == flower.id }) {
            discoveredFlowers[index] = flower
        }
        
        saveFavorites()
        saveDiscoveredFlowers()
    }
    
    func deleteFavorite(_ flower: AIFlower) {
        favorites.removeAll { $0.id == flower.id }
        if currentFlower?.id == flower.id {
            currentFlower?.isFavorite = false
        }
        saveFavorites()
    }
    
    func deleteFlower(_ flower: AIFlower) {
        // Remove from favorites
        favorites.removeAll { $0.id == flower.id }
        
        // Remove from discovered flowers
        discoveredFlowers.removeAll { $0.id == flower.id }
        
        // Clear from current if needed
        if currentFlower?.id == flower.id {
            currentFlower = nil
        }
        
        // Save changes
        saveFavorites()
        saveDiscoveredFlowers()
    }
    
    func removeFlower(_ flower: AIFlower) {
        // This is used when gifting a flower - it's permanently removed
        deleteFlower(flower)
        
        // Sync to iCloud after removal
        Task {
            await iCloudSyncManager.shared.syncToICloud()
        }
    }
    
    func addReceivedFlower(_ flower: AIFlower) {
        // Add to discovered flowers
        var receivedFlower = flower
        receivedFlower.discoveryDate = Date()
        receivedFlower.isFavorite = false // Reset favorite status for new owner
        
        // Add to collection
        discoveredFlowers.insert(receivedFlower, at: 0)
        
        // Set as current flower
        currentFlower = receivedFlower
        
        // Save and sync
        saveDiscoveredFlowers()
        Task {
            await iCloudSyncManager.shared.syncToICloud()
        }
        
        // Show success notification
        let message = "You received \(flower.name) from \(flower.ownershipHistory.last?.name ?? flower.originalOwner?.name ?? "someone special")"
        print(message)
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    // MARK: - Public Refresh Method
    func refreshCollection() {
        loadFavorites()
        loadDiscoveredFlowers()
        loadHerbariumSpecies()
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([AIFlower].self, from: data) {
                favorites = decoded.sorted { 
                    ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
                }
            }
        }
    }
    
    private func saveFavorites() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    // MARK: - Discovered Flowers Management
    func addToDiscoveredFlowers(_ flower: AIFlower, autoSaveToPhotos: Bool? = nil) {
        // Check if flower already exists in discovered list
        if !discoveredFlowers.contains(where: { $0.id == flower.id }) {
            var updatedFlower = flower
            
            // Auto-add to herbarium if this is a new species with scientific name
            if let scientificName = flower.scientificName, 
               !scientificName.isEmpty,
               !isSpeciesInHerbarium(scientificName) {
                herbariumSpecies.insert(scientificName)
                updatedFlower.isInHerbarium = true
                saveHerbariumSpecies()
                print("🌿 New species added to Herbarium: \(scientificName)")
            }
            
            discoveredFlowers.insert(updatedFlower, at: 0)
            saveDiscoveredFlowers()
            
            // Auto-save to photo library if enabled (use parameter or default setting)
            let shouldAutoSave = autoSaveToPhotos ?? self.autoSaveToPhotos
            if shouldAutoSave {
                PhotoLibraryService.shared.saveFlowerToLibrary(flower) { success, error in
                    if success {
                        print("Successfully saved flower to photo library")
                    } else if let error = error {
                        print("Failed to save flower to photo library: \(error.localizedDescription)")
                    }
                }
            }
            
            // Check for milestone achievements
            checkForMilestoneAchievement()
        }
    }
    
    func checkForMilestoneAchievement() {
        let currentCount = discoveredFlowers.count
        let lastMilestone = userDefaults.integer(forKey: lastMilestoneKey)
        
        // Find the highest milestone we've reached
        for milestone in milestoneThresholds {
            if currentCount >= milestone && lastMilestone < milestone {
                // We've hit a new milestone!
                userDefaults.set(milestone, forKey: lastMilestoneKey)
                
                // Generate achievement bouquet
                Task {
                    await generateMilestoneBouquet(for: milestone)
                }
                break
            }
        }
    }
    
    func generateMilestoneBouquet(for milestone: Int) async {
        // Generate a special achievement bouquet
        let descriptor = "luxurious celebratory bouquet with golden accents and sparkling ribbons"
        
        do {
            let (image, prompt) = try await FALService.shared.generateFlowerImage(descriptor: descriptor, isBouquet: true)
            
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                throw NSError(domain: "FlowerStore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
            }
            
            // Create milestone flower names based on the achievement
            let bouquetFlowerNames = [
                "Golden Achievement Roses",
                "Celebration Orchids",
                "Victory Lilies",
                "Success Peonies",
                "Milestone Carnations"
            ]
            
            var flower = AIFlower(
                name: "\(milestone) Flowers Celebration Bouquet",
                descriptor: descriptor,
                imageData: imageData,
                generatedDate: Date(),
                isFavorite: true, // Auto-favorite milestone bouquets
                discoveryDate: Date(),
                contextualGeneration: false,
                generationContext: nil,
                isBouquet: true,
                bouquetFlowers: bouquetFlowerNames,
                holidayName: "Achievement Milestone",
                discoveryLatitude: ContextualFlowerGenerator.shared.currentLocation?.coordinate.latitude,
                discoveryLongitude: ContextualFlowerGenerator.shared.currentLocation?.coordinate.longitude,
                discoveryLocationName: ContextualFlowerGenerator.shared.currentPlacemark?.locality,
                originalOwner: createCurrentOwner()
            )
            
            // Set continent
            flower.continent = Continent.allCases.randomElement()
            
            // Generate special achievement details
            if apiConfig.hasValidOpenAIKey {
                do {
                    let details = FlowerDetails(
                        meaning: "This special bouquet commemorates your incredible achievement of discovering \(milestone) flowers. Each bloom represents a moment of wonder and discovery on your journey.",
                        properties: "A stunning arrangement featuring golden roses symbolizing achievement, shimmering orchids for elegance, and victory lilies representing your dedication to discovery. The arrangement is adorned with celebratory ribbons and golden accents.",
                        origins: "This achievement bouquet is a tradition dating back to ancient botanical societies, where reaching significant milestones in flower discovery was celebrated with special ceremonial arrangements.",
                        detailedDescription: "Your dedication to discovering the beauty of nature has reached a remarkable milestone. This celebration bouquet, awarded for discovering \(milestone) unique flowers, stands as a testament to your journey of botanical exploration. May it inspire you to continue discovering the wonders that await.",
                        continent: flower.continent?.rawValue ?? "Global"
                    )
                    
                    flower.meaning = details.meaning
                    flower.properties = details.properties
                    flower.origins = details.origins
                    flower.detailedDescription = details.detailedDescription
                } catch {
                    print("Failed to generate milestone details: \(error)")
                }
            }
            
            await MainActor.run {
                // Set as pending flower to show reveal screen
                self.pendingFlower = flower
                self.hasUnrevealedFlower = true
                
                // Save pending flower
                if let encoded = try? JSONEncoder().encode(flower) {
                    self.userDefaults.set(encoded, forKey: self.pendingFlowerKey)
                }
            }
        } catch {
            print("Failed to generate milestone bouquet: \(error)")
        }
    }
    
    private func loadDiscoveredFlowers() {
        if let data = userDefaults.data(forKey: discoveredFlowersKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([AIFlower].self, from: data) {
                discoveredFlowers = decoded.sorted { 
                    ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
                }
            }
        }
    }
    
    private func loadHerbariumSpecies() {
        if let data = userDefaults.data(forKey: herbariumSpeciesKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(Set<String>.self, from: data) {
                herbariumSpecies = decoded
            }
        }
    }
    
    private func saveHerbariumSpecies() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(herbariumSpecies) {
            userDefaults.set(encoded, forKey: herbariumSpeciesKey)
        }
    }
    
    private func saveDiscoveredFlowers() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(discoveredFlowers) {
            userDefaults.set(encoded, forKey: discoveredFlowersKey)
        }
        
        // Sync to iCloud
        Task {
            await iCloudSyncManager.shared.syncToICloud()
        }
    }
    
    func saveFlowers() {
        saveFavorites()
        saveDiscoveredFlowers()
    }
    
    // Update a flower's details (used after fetching details from AI)
    func updateFlowerDetails(_ flower: AIFlower, with details: FlowerDetails) {
        // Update in current flower
        if currentFlower?.id == flower.id {
            currentFlower?.meaning = details.meaning
            currentFlower?.properties = details.properties
            currentFlower?.origins = details.origins
            currentFlower?.detailedDescription = details.detailedDescription
            currentFlower?.continent = Continent(rawValue: details.continent)
        }
        
        // Update in favorites
        if let index = favorites.firstIndex(where: { $0.id == flower.id }) {
            favorites[index].meaning = details.meaning
            favorites[index].properties = details.properties
            favorites[index].origins = details.origins
            favorites[index].detailedDescription = details.detailedDescription
            favorites[index].continent = Continent(rawValue: details.continent)
        }
        
        // Update in discovered flowers
        if let index = discoveredFlowers.firstIndex(where: { $0.id == flower.id }) {
            discoveredFlowers[index].meaning = details.meaning
            discoveredFlowers[index].properties = details.properties
            discoveredFlowers[index].origins = details.origins
            discoveredFlowers[index].detailedDescription = details.detailedDescription
            discoveredFlowers[index].continent = Continent(rawValue: details.continent)
        }
        
        saveFavorites()
        saveDiscoveredFlowers()
    }
    
    // Refresh details for a flower if they're missing
    func refreshFlowerDetailsIfNeeded(_ flower: AIFlower) async {
        // Only refresh if details are missing
        if flower.meaning == nil && flower.properties == nil && flower.origins == nil {
            if apiConfig.hasValidOpenAIKey {
                do {
                    let details = try await OpenAIService.shared.generateFlowerDetails(for: flower, context: nil)
                    updateFlowerDetails(flower, with: details)
                } catch {
                    print("Failed to refresh flower details: \(error)")
                }
            }
        }
    }
    
    // MARK: - Test Methods
    
    func generateTestFlowerForReveal() async {
        // Generate a proper test bouquet with real flower generation
        let descriptor = "spring garden bouquet with pink roses, white lilies, purple lavender, and yellow daffodils"
        let bouquetFlowerNames = ["Pink Garden Roses", "White Asiatic Lilies", "Purple Lavender", "Yellow Daffodils", "Baby's Breath"]
        
        do {
            // Generate actual flower image using FAL service
            let (image, prompt) = try await FALService.shared.generateFlowerImage(
                descriptor: descriptor,
                isBouquet: true,
                personalMessage: "A beautiful test bouquet to demonstrate the magic of flower discovery."
            )
            
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                throw NSError(domain: "FlowerStore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
            }
            
            // Create a beautiful test bouquet
            var testFlower = AIFlower(
                name: "Developer's Garden Bouquet",
                descriptor: descriptor,
                imageData: imageData,
                generatedDate: Date(),
                isFavorite: false,
                meaning: "A special bouquet created to celebrate the art of app development and the beauty of digital gardens. This arrangement represents the harmony between technology and nature, bringing together the most beloved spring flowers in a perfect symphony of colors and fragrances.",
                properties: "This exquisite bouquet combines the romantic elegance of pink garden roses with the pure beauty of white Asiatic lilies. The purple lavender adds a soothing fragrance and represents devotion, while the cheerful yellow daffodils symbolize new beginnings and rebirth. Delicate baby's breath creates a dreamy, cloud-like backdrop that ties all the elements together in perfect harmony.",
                origins: "This bouquet draws inspiration from traditional English cottage gardens, where these flowers have been cultivated together for centuries. The combination represents the timeless appeal of classic garden favorites, carefully selected to create a balanced and visually stunning arrangement.",
                detailedDescription: "The Developer's Garden Bouquet is a testament to the beauty that can emerge from careful planning and attention to detail - much like great software development. Each flower was chosen not just for its individual beauty, but for how it complements the others, creating a whole that is greater than the sum of its parts. This bouquet serves as a reminder that the most beautiful creations often come from the perfect balance of different elements working in harmony.",
                continent: .europe,
                discoveryDate: Date(),
                contextualGeneration: false,
                generationContext: nil,
                isBouquet: true,
                bouquetFlowers: bouquetFlowerNames,
                holidayName: "Development Testing",
                discoveryLatitude: 37.7749, // San Francisco coordinates (tech hub)
                discoveryLongitude: -122.4194,
                discoveryLocationName: "San Francisco, CA",
                originalOwner: createCurrentOwner()
            )
            
            // Capture current weather for test flower
            if let weather = ContextualFlowerGenerator.shared.currentWeather {
                let weatherCondition = OnboardingAssetsService.getWeatherConditionString(from: weather.currentWeather.condition)
                let temperature = weather.currentWeather.temperature.value
                
                testFlower.captureWeatherAndDate(
                    weatherCondition: weatherCondition,
                    temperature: temperature,
                    temperatureUnit: "°C"
                )
            }
            
            // Set as pending flower to trigger reveal view
            await MainActor.run {
                self.pendingFlower = testFlower
                self.hasUnrevealedFlower = true
            }
            
        } catch {
            // Fallback to enhanced placeholder if API fails
            var testFlower = AIFlower(
                name: "Developer's Garden Bouquet",
                descriptor: descriptor,
                imageData: createPlaceholderImage(),
                generatedDate: Date(),
                isFavorite: false,
                meaning: "A special bouquet created to celebrate the art of app development and the beauty of digital gardens. This arrangement represents the harmony between technology and nature.",
                properties: "This placeholder bouquet showcases the framework for beautiful flower generation. When API keys are configured, this becomes a stunning arrangement of pink roses, white lilies, purple lavender, and yellow daffodils.",
                origins: "Created in the digital realm where code meets creativity, this bouquet represents the potential for beauty in every line of code.",
                detailedDescription: "The Developer's Garden Bouquet demonstrates the app's capability to create detailed, meaningful flower descriptions. This test arrangement shows how each flower in the app tells a story and carries meaning.",
                continent: .northAmerica,
                discoveryDate: Date(),
                contextualGeneration: false,
                generationContext: nil,
                isBouquet: true,
                bouquetFlowers: bouquetFlowerNames,
                holidayName: "Development Testing",
                discoveryLatitude: 37.7749,
                discoveryLongitude: -122.4194,
                discoveryLocationName: "San Francisco, CA",
                originalOwner: createCurrentOwner()
            )
            
            // Capture current weather for fallback test flower
            if let weather = ContextualFlowerGenerator.shared.currentWeather {
                let weatherCondition = OnboardingAssetsService.getWeatherConditionString(from: weather.currentWeather.condition)
                let temperature = weather.currentWeather.temperature.value
                
                testFlower.captureWeatherAndDate(
                    weatherCondition: weatherCondition,
                    temperature: temperature,
                    temperatureUnit: "°C"
                )
            }
            
            await MainActor.run {
                self.pendingFlower = testFlower
                self.hasUnrevealedFlower = true
            }
        }
    }
    
    func triggerTestFlowerReveal() {
        // Generate a real flower from botanical database for testing
        Task {
            // Get a random species from the botanical database
            let existingSpecies = discoveredFlowers.compactMap { $0.scientificName }
            let randomSpecies = BotanicalDatabase.shared.getRandomSpecies(excluding: existingSpecies)
            
            if let species = randomSpecies {
                // Create flower with real botanical data
                let flower = AIFlower(
                    id: UUID(),
                    name: species.primaryCommonName,
                    descriptor: species.imagePrompt,
                    imageData: nil, // Will be generated if API is available
                    generatedDate: Date(),
                    isFavorite: false,
                    scientificName: species.scientificName,
                    commonNames: species.commonNames,
                    family: species.family,
                    nativeRegions: species.nativeRegions,
                    bloomingSeason: species.bloomingSeason,
                    conservationStatus: species.conservationStatus,
                    uses: species.uses,
                    interestingFacts: species.interestingFacts,
                    careInstructions: species.careInstructions,
                    rarityLevel: species.rarityLevel,
                    meaning: createMeaningForSpecies(species),
                    properties: species.interestingFacts.first ?? species.description,
                    origins: createOriginsForSpecies(species),
                    detailedDescription: createDetailedDescriptionForSpecies(species),
                    shortDescription: nil,
                    continent: species.primaryContinent,
                    discoveryDate: nil,
                    contextualGeneration: false,
                    generationContext: nil,
                    isBouquet: false,
                    bouquetFlowers: nil,
                    holidayName: nil,
                    discoveryLatitude: 51.5074,
                    discoveryLongitude: -0.1278,
                    discoveryLocationName: "London, United Kingdom",
                    isInHerbarium: false,
                    discoveryWeatherCondition: "Sunny",
                    discoveryTemperature: 22.0,
                    discoveryTemperatureUnit: "°C",
                    discoveryDayOfWeek: "Tuesday",
                    discoveryFormattedDate: "22nd July 2025",
                    originalOwner: nil,
                    ownershipHistory: []
                )
                
                // Set as pending flower to trigger reveal view
                pendingFlower = flower
                hasUnrevealedFlower = true
                
                // Save pending flower so it persists
                if let encoded = try? JSONEncoder().encode(flower) {
                    userDefaults.set(encoded, forKey: pendingFlowerKey)
                }
                
                // Generate image if API is available, otherwise use placeholder
                if apiConfig.hasValidFalKey || apiConfig.hasValidOpenAIKey {
                    Task {
                        await generateFlowerImage(for: flower)
                    }
                } else {
                    // Add placeholder image data for testing without API
                    if let placeholderImage = createPlaceholderFlowerImage() {
                        var updatedFlower = flower
                        // Create new flower with image data
                        updatedFlower = AIFlower(
                            id: flower.id,
                            name: flower.name,
                            descriptor: flower.descriptor,
                            imageData: placeholderImage.pngData(),
                            generatedDate: flower.generatedDate,
                            isFavorite: flower.isFavorite,
                            scientificName: flower.scientificName,
                            commonNames: flower.commonNames,
                            family: flower.family,
                            nativeRegions: flower.nativeRegions,
                            bloomingSeason: flower.bloomingSeason,
                            conservationStatus: flower.conservationStatus,
                            uses: flower.uses,
                            interestingFacts: flower.interestingFacts,
                            careInstructions: flower.careInstructions,
                            rarityLevel: flower.rarityLevel,
                            meaning: flower.meaning,
                            properties: flower.properties,
                            origins: flower.origins,
                            detailedDescription: flower.detailedDescription,
                            shortDescription: flower.shortDescription,
                            continent: flower.continent,
                            discoveryDate: flower.discoveryDate,
                            contextualGeneration: flower.contextualGeneration,
                            generationContext: flower.generationContext,
                            isBouquet: flower.isBouquet,
                            bouquetFlowers: flower.bouquetFlowers,
                            holidayName: flower.holidayName,
                            discoveryLatitude: flower.discoveryLatitude,
                            discoveryLongitude: flower.discoveryLongitude,
                            discoveryLocationName: flower.discoveryLocationName,
                            isInHerbarium: flower.isInHerbarium,
                            discoveryWeatherCondition: flower.discoveryWeatherCondition,
                            discoveryTemperature: flower.discoveryTemperature,
                            discoveryTemperatureUnit: flower.discoveryTemperatureUnit,
                            discoveryDayOfWeek: flower.discoveryDayOfWeek,
                            discoveryFormattedDate: flower.discoveryFormattedDate,
                            originalOwner: flower.originalOwner,
                            ownershipHistory: flower.ownershipHistory
                        )
                        
                        pendingFlower = updatedFlower
                        
                        // Save updated flower
                        if let encoded = try? JSONEncoder().encode(updatedFlower) {
                            userDefaults.set(encoded, forKey: pendingFlowerKey)
                        }
                    }
                }
            } else {
                // Fallback to mock if no species available
                let testFlower = createMockFlower(descriptor: "beautiful test flower for development")
                pendingFlower = testFlower
                hasUnrevealedFlower = true
                
                if let encoded = try? JSONEncoder().encode(testFlower) {
                    userDefaults.set(encoded, forKey: pendingFlowerKey)
                }
            }
        }
    }
    
    private func createPlaceholderFlowerImage() -> UIImage? {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Create a simple flower-like shape as placeholder
            let rect = CGRect(origin: .zero, size: size)
            
            // Background gradient
            let gradient = CAGradientLayer()
            gradient.frame = rect
            gradient.colors = [
                UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
                UIColor(red: 0.8, green: 0.9, blue: 0.95, alpha: 1.0).cgColor
            ]
            gradient.render(in: context.cgContext)
            
            // Simple flower icon
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius: CGFloat = 100
            
            // Petals
            for i in 0..<8 {
                let angle = CGFloat(i) * (2 * .pi / 8)
                let petalCenter = CGPoint(
                    x: center.x + cos(angle) * radius * 0.6,
                    y: center.y + sin(angle) * radius * 0.6
                )
                
                let petalPath = UIBezierPath(
                    ovalIn: CGRect(
                        x: petalCenter.x - radius/3,
                        y: petalCenter.y - radius/6,
                        width: radius * 2/3,
                        height: radius/3
                    )
                )
                
                UIColor(red: 1.0, green: 0.8, blue: 0.9, alpha: 0.8).setFill()
                petalPath.fill()
            }
            
            // Center
            let centerPath = UIBezierPath(
                ovalIn: CGRect(
                    x: center.x - radius/4,
                    y: center.y - radius/4,
                    width: radius/2,
                    height: radius/2
                )
            )
            
            UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0).setFill()
            centerPath.fill()
        }
    }
    
    private func generateFlowerImage(for flower: AIFlower) async {
        do {
            let imageData: Data?
            
            if apiConfig.hasValidFalKey {
                let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: flower.descriptor)
                imageData = image.pngData()
            } else if apiConfig.hasValidOpenAIKey {
                let (image, _) = try await OpenAIService.shared.generateFlowerImage(descriptor: flower.descriptor)
                imageData = image.pngData()
            } else {
                return
            }
            
            // Update the pending flower with the generated image
            if let imageData = imageData {
                var updatedFlower = flower
                updatedFlower = AIFlower(
                    id: flower.id,
                    name: flower.name,
                    descriptor: flower.descriptor,
                    imageData: imageData,
                    generatedDate: flower.generatedDate,
                    isFavorite: flower.isFavorite,
                    scientificName: flower.scientificName,
                    commonNames: flower.commonNames,
                    family: flower.family,
                    nativeRegions: flower.nativeRegions,
                    bloomingSeason: flower.bloomingSeason,
                    conservationStatus: flower.conservationStatus,
                    uses: flower.uses,
                    interestingFacts: flower.interestingFacts,
                    careInstructions: flower.careInstructions,
                    rarityLevel: flower.rarityLevel,
                    meaning: flower.meaning,
                    properties: flower.properties,
                    origins: flower.origins,
                    detailedDescription: flower.detailedDescription,
                    shortDescription: flower.shortDescription,
                    continent: flower.continent,
                    discoveryDate: flower.discoveryDate,
                    contextualGeneration: flower.contextualGeneration,
                    generationContext: flower.generationContext,
                    isBouquet: flower.isBouquet,
                    bouquetFlowers: flower.bouquetFlowers,
                    holidayName: flower.holidayName,
                    discoveryLatitude: flower.discoveryLatitude,
                    discoveryLongitude: flower.discoveryLongitude,
                    discoveryLocationName: flower.discoveryLocationName,
                    isInHerbarium: flower.isInHerbarium,
                    discoveryWeatherCondition: flower.discoveryWeatherCondition,
                    discoveryTemperature: flower.discoveryTemperature,
                    discoveryTemperatureUnit: flower.discoveryTemperatureUnit,
                    discoveryDayOfWeek: flower.discoveryDayOfWeek,
                    discoveryFormattedDate: flower.discoveryFormattedDate,
                    originalOwner: flower.originalOwner,
                    ownershipHistory: flower.ownershipHistory
                )
                
                pendingFlower = updatedFlower
                
                // Save updated flower
                if let encoded = try? JSONEncoder().encode(updatedFlower) {
                    userDefaults.set(encoded, forKey: pendingFlowerKey)
                }
            }
        } catch {
            print("Failed to generate test flower image: \(error)")
        }
    }
    
    func resetProfile() {
        // Clear all stored data
        userDefaults.removeObject(forKey: favoritesKey)
        userDefaults.removeObject(forKey: discoveredFlowersKey)
        userDefaults.removeObject(forKey: dailyFlowerKey)
        userDefaults.removeObject(forKey: dailyFlowerDateKey)
        userDefaults.removeObject(forKey: pendingFlowerKey)
        userDefaults.removeObject(forKey: lastScheduledDateKey)
        userDefaults.removeObject(forKey: nextFlowerTimeKey)
        userDefaults.removeObject(forKey: lastMilestoneKey)
        userDefaults.removeObject(forKey: showTestFlowerOnNextLaunchKey)
        userDefaults.removeObject(forKey: "hasGeneratedFirstFlower")
        userDefaults.removeObject(forKey: "hasCompletedOnboarding")
        userDefaults.removeObject(forKey: "hasReceivedJennyFlower")
        
        // Clear shared defaults for widget
        sharedDefaults?.removeObject(forKey: dailyFlowerKey)
        
        // Clear notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0)
        
        // Reset all published properties
        currentFlower = nil
        favorites = []
        discoveredFlowers = []
        isGenerating = false
        errorMessage = nil
        hasUnrevealedFlower = false
        pendingFlower = nil
        nextFlowerTime = nil
        
        // Add Jennifer's Blessing for the fresh start
        createJennyFlowerSynchronously()
        
        shouldShowOnboarding = true // Set this to true after reset
        
        // Force UI update
        objectWillChange.send()
    }
    
    func resetOnboardingState() {
        // Only reset onboarding-related keys, keep flowers
        userDefaults.removeObject(forKey: "hasCompletedOnboarding")
        userDefaults.removeObject(forKey: "hasReceivedJennyFlower")
        shouldShowOnboarding = true
        
        // Force UI update
        objectWillChange.send()
    }
    
    func generateCustomFlower(prompt: String, name: String? = nil) async throws {
        isGenerating = true
        errorMessage = nil
        
        do {
            // Generate image using the custom prompt
            let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: prompt)
            let imageData = image.pngData()
            
            // Generate flower details using OpenAI
            let flowerName = name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? name! : "Custom Creation"
            var flower = AIFlower(
                name: flowerName,
                descriptor: prompt,
                imageData: imageData,
                generatedDate: Date(),
                isFavorite: false,
                discoveryDate: Date(),
                originalOwner: createCurrentOwner()
            )
            
            // Generate details if OpenAI is available
            if apiConfig.hasValidOpenAIKey {
                do {
                    let details = try await OpenAIService.shared.generateFlowerDetails(for: flower, context: nil)
                    flower.meaning = details.meaning
                    flower.properties = details.properties
                    flower.origins = details.origins
                    flower.detailedDescription = details.detailedDescription
                    flower.continent = Continent(rawValue: details.continent)
                } catch {
                    print("Failed to generate flower details: \(error)")
                    // Use fallback details
                    flower.meaning = "A unique custom creation that reflects your personal vision and creativity."
                    flower.properties = "This flower was created from your custom description, making it one-of-a-kind in your collection."
                    flower.origins = "Born from imagination and brought to life through AI artistry."
                    flower.detailedDescription = "This custom flower represents your creative vision, generated specifically from your unique description. It stands as a testament to the power of imagination and the beauty that emerges when technology meets creativity."
                }
            }
            
            // Set current flower and add to collection
            currentFlower = flower
            addToDiscoveredFlowers(flower)
            
            // Save to shared container for widget
            if let encoded = try? JSONEncoder().encode(flower) {
                sharedDefaults?.set(encoded, forKey: dailyFlowerKey)
            }
            
            // Auto-save to photos if enabled
            if autoSaveToPhotos {
                PhotoLibraryService.shared.saveFlowerToLibrary(flower) { success, error in
                    if success {
                        print("Successfully saved custom flower to photo library")
                    } else if let error = error {
                        print("Failed to save custom flower to photos: \(error)")
                    }
                }
            }
            
            // Sync to iCloud
            await iCloudSyncManager.shared.syncToICloud()
            
        } catch {
            errorMessage = "Failed to generate custom flower: \(error.localizedDescription)"
            throw error
        }
        
        isGenerating = false
    }
    
    // MARK: - Helper Methods
    
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
    
    
    // MARK: - Herbarium Management
    
    func addToHerbarium(_ flower: AIFlower) {
        guard let scientificName = flower.scientificName, !scientificName.isEmpty else { 
            print("Cannot add flower to herbarium: missing scientific name")
            return 
        }
        
        // Add to herbarium species set
        herbariumSpecies.insert(scientificName)
        
        // Update the flower's herbarium status
        if let index = discoveredFlowers.firstIndex(where: { $0.id == flower.id }) {
            discoveredFlowers[index].isInHerbarium = true
        }
        
        // Save changes
        saveHerbariumSpecies()
        saveDiscoveredFlowers()
        
        print("Added \(scientificName) to herbarium. Total species: \(herbariumSpeciesCount)")
    }
    
    func removeFromHerbarium(_ flower: AIFlower) {
        guard let scientificName = flower.scientificName else { return }
        
        herbariumSpecies.remove(scientificName)
        
        // Update all flowers with this scientific name
        for index in discoveredFlowers.indices {
            if discoveredFlowers[index].scientificName == scientificName {
                discoveredFlowers[index].isInHerbarium = false
            }
        }
        
        saveHerbariumSpecies()
        saveDiscoveredFlowers()
    }
    
    func isSpeciesInHerbarium(_ scientificName: String) -> Bool {
        return herbariumSpecies.contains(scientificName)
    }
    
    func hasDiscoveredSpecies(_ scientificName: String) -> Bool {
        return discoveredFlowers.contains { $0.scientificName == scientificName }
    }
    
    // Get a random species that hasn't been discovered yet
    func getRandomUndiscoveredSpecies() -> String? {
        // This would ideally come from a comprehensive botanical database
        // For now, return nil to indicate we should generate any real species
        return nil
    }
    
    // MARK: - Helper methods for creating species descriptions
    
    private func createMeaningForSpecies(_ species: BotanicalSpecies) -> String {
        let colorDescription = species.imagePrompt.contains("bright") ? "vibrant" : 
                             species.imagePrompt.contains("soft") ? "delicate" : 
                             species.imagePrompt.contains("white") ? "pure" : "colorful"
        
        let seasonMeaning = species.bloomingSeason == "Spring" ? "renewal and fresh beginnings" :
                           species.bloomingSeason == "Summer" ? "warmth and abundance" :
                           species.bloomingSeason == "Autumn" ? "transition and harvest" :
                           species.bloomingSeason == "Winter" ? "resilience and hope" : "natural cycles"
        
        return "The \(species.primaryCommonName) symbolizes \(seasonMeaning). With its \(colorDescription) blooms, it brings joy and beauty to \(species.bloomingSeason.lowercased()) gardens."
    }
    
    private func createOriginsForSpecies(_ species: BotanicalSpecies) -> String {
        if species.nativeRegions.first == "Garden hybrid" {
            return "A cultivated hybrid developed by gardeners. \(species.interestingFacts.first ?? "Popular in ornamental gardens worldwide.")"
        } else {
            return "Native to \(species.nativeRegions.joined(separator: " and ")). Thrives in \(species.habitat.lowercased())."
        }
    }
    
    private func createDetailedDescriptionForSpecies(_ species: BotanicalSpecies) -> String {
        var detailParts: [String] = []
        detailParts.append(species.description)
        
        if species.bloomingSeason != "Year-round" {
            detailParts.append("Blooms in \(species.bloomingSeason.lowercased())")
        }
        
        if let fact = species.interestingFacts.dropFirst().first {
            detailParts.append(fact)
        }
        
        if !species.uses.isEmpty {
            detailParts.append("Commonly used for \(species.uses.first?.lowercased() ?? "ornamental purposes")")
        }
        
        return detailParts.joined(separator: ". ") + "."
    }
} 