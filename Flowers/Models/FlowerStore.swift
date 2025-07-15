import Foundation
import SwiftUI
import UIKit
import UserNotifications

@MainActor
class FlowerStore: ObservableObject {
    @Published var currentFlower: AIFlower?
    @Published var favorites: [AIFlower] = []
    @Published var discoveredFlowers: [AIFlower] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var hasUnrevealedFlower = false
    @Published var pendingFlower: AIFlower?
    @Published var nextFlowerTime: Date?
    
    private let userDefaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.OCTOBER.Flowers")
    private let favoritesKey = "favorites"
    private let dailyFlowerKey = "dailyFlower"
    private let dailyFlowerDateKey = "dailyFlowerDate"
    private let discoveredFlowersKey = "discoveredFlowers"
    private let pendingFlowerKey = "pendingFlower"
    private let lastScheduledDateKey = "lastScheduledFlowerDate"
    private let nextFlowerTimeKey = "nextFlowerTime"
    private let debugAnytimeGenerationsKey = "debugAnytimeGenerations"
    private let apiConfig = APIConfiguration.shared
    
    // Computed properties for stats
    var totalDiscoveredCount: Int {
        discoveredFlowers.count
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
    
    var debugAnytimeGenerations: Bool {
        get { userDefaults.bool(forKey: debugAnytimeGenerationsKey) }
        set { 
            userDefaults.set(newValue, forKey: debugAnytimeGenerationsKey)
            objectWillChange.send()
        }
    }
    
    init() {
        // Check if first time user before loading data
        let isFirstTimeUser = !UserDefaults.standard.bool(forKey: "hasReceivedJennyFlower")
        
        loadFavorites()
        loadDiscoveredFlowers()
        
        // Add Jenny flower for first-time users
        if isFirstTimeUser &&
           !discoveredFlowers.contains(where: { $0.name == "Jennifer's Blessing" }) {
            addJennyFlower()
        }
        
        checkForPendingFlower()
        loadNextFlowerTime()
        
        // Check if we should have a flower ready based on today's schedule
        checkForScheduledFlowerToday()
        
        // Schedule next flower if needed
        scheduleNextFlowerIfNeeded()
        
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
                    discoveryLocationName: "Canary Wharf, London"
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
    
    // MARK: - Daily Flower Scheduling
    func scheduleNextFlowerIfNeeded() {
        // Check if we already have a pending flower
        if hasUnrevealedFlower {
            return
        }
        
        // Check if we already scheduled for today
        if let lastScheduled = userDefaults.object(forKey: lastScheduledDateKey) as? Date,
           Calendar.current.isDateInToday(lastScheduled) {
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
        if hasUnrevealedFlower {
            // Already have a flower waiting, just reschedule the notification
            guard let flower = pendingFlower else { return }
            
            // Generate notification for existing flower
            var notificationTitle = "Your Daily Flower Has Bloomed! 🌸"
            var notificationBody = "\(flower.name) has been discovered and is waiting for you."
            
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
        
        // Generate the flower now
        await generateNewFlower(isDaily: true)
        
        // Get the generated flower's name
        guard let flower = pendingFlower else { return }
        
        // Generate custom notification message using OpenAI if available
        var notificationTitle = "Your Daily Flower Has Bloomed! 🌸"
        var notificationBody = "\(flower.name) has been discovered and is waiting for you."
        
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
            var notificationTitle = "Your Daily Flower Has Bloomed! 🌸"
            var notificationBody = "\(flower.name) has been discovered and is waiting for you."
            
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
            hasUnrevealedFlower = true
        }
    }
    
    func checkForScheduledFlowerToday() {
        // Only check if we don't already have a pending flower
        guard !hasUnrevealedFlower else { return }
        
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
            
            // Generate the flower now since the time has passed
            Task {
                await generateDailyFlower()
                await MainActor.run {
                    self.userDefaults.set(Date(), forKey: self.lastScheduledDateKey)
                }
            }
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
            var actualDescriptor = descriptor ?? FlowerDescriptors.random()
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
            // Otherwise check if we should use contextual generation (only if no descriptor provided)
            else if descriptor == nil && ContextualFlowerGenerator.shared.shouldUseContextualGeneration() {
                if let contextualResult = ContextualFlowerGenerator.shared.generateContextualDescriptor() {
                    actualDescriptor = contextualResult.descriptor
                    flowerContext = contextualResult.context
                    isContextual = true
                }
            }
            
            // Always use FAL for image generation
            let (image, prompt) = try await FALService.shared.generateFlowerImage(descriptor: actualDescriptor, isBouquet: isBouquet)
            
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
                if let holidayName = holiday?.name {
                    name = "\(holidayName) Bouquet"
                } else {
                    name = "Special Occasion Bouquet"
                }
                
                // Generate list of flowers in the bouquet
                bouquetFlowerNames = generateBouquetFlowerNames(for: holiday)
            } else if apiConfig.hasValidOpenAIKey {
                if isFirstFlower {
                    // Generate a Jenny-related name for the first flower
                    name = try await OpenAIService.shared.generateJennyFlowerName(descriptor: actualDescriptor)
                    userDefaults.set(true, forKey: "hasGeneratedFirstFlower")
                } else {
                    name = try await OpenAIService.shared.generateFlowerName(descriptor: actualDescriptor)
                }
            } else {
                // Fallback to extracting from descriptor if no OpenAI key
                if isFirstFlower {
                    name = "Jenny's \(extractFlowerName(from: actualDescriptor))"
                    userDefaults.set(true, forKey: "hasGeneratedFirstFlower")
                } else {
                    name = extractFlowerName(from: actualDescriptor)
                }
            }
            
            // Capture current location if available
            let currentLocation = ContextualFlowerGenerator.shared.currentLocation
            let currentPlacemark = ContextualFlowerGenerator.shared.currentPlacemark
            
            var flower = AIFlower(
                name: name,
                descriptor: actualDescriptor,
                imageData: imageData,
                generatedDate: Date(),
                isFavorite: false,
                discoveryDate: Date(),
                contextualGeneration: isContextual,
                generationContext: isContextual ? actualDescriptor : nil,
                isBouquet: isBouquet,
                bouquetFlowers: bouquetFlowerNames,
                holidayName: holiday?.name,
                discoveryLatitude: currentLocation?.coordinate.latitude,
                discoveryLongitude: currentLocation?.coordinate.longitude,
                discoveryLocationName: currentPlacemark?.locality ?? currentPlacemark?.name
            )
            
            // Get a random continent for now (will be replaced by AI-generated continent)
            flower.continent = Continent.allCases.randomElement()
            
            // Always generate details for every flower
            if apiConfig.hasValidOpenAIKey {
                do {
                    let details = try await OpenAIService.shared.generateFlowerDetails(for: flower, context: flowerContext)
                    flower.meaning = details.meaning
                    flower.properties = details.properties
                    flower.origins = details.origins
                    flower.detailedDescription = details.detailedDescription
                    flower.continent = Continent(rawValue: details.continent) ?? flower.continent
                    
                    // Add contextual meaning if available
                    if let contextualMeaning = flowerContext?.generateContextualMeaning() {
                        flower.meaning = (flower.meaning ?? "") + " " + contextualMeaning
                    }
                } catch {
                    // Continue without details if generation fails
                    print("Failed to generate flower details: \(error)")
                    errorMessage = "Flower created, but details unavailable"
                }
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
                
                // Add to discovered flowers
                addToDiscoveredFlowers(flower)
                
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
            discoveryDate: Date()
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
        
        // Clear current flower if it's the one being deleted
        if currentFlower?.id == flower.id {
            currentFlower = nil
        }
        
        // Save both collections
        saveFavorites()
        saveDiscoveredFlowers()
    }
    
    // MARK: - Public Refresh Method
    func refreshCollection() {
        loadFavorites()
        loadDiscoveredFlowers()
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([AIFlower].self, from: data) {
            favorites = decoded.sorted { 
                ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
            }
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    // MARK: - Discovered Flowers Management
    func addToDiscoveredFlowers(_ flower: AIFlower) {
        // Check if flower already exists in discovered list
        if !discoveredFlowers.contains(where: { $0.id == flower.id }) {
            discoveredFlowers.insert(flower, at: 0)
            saveDiscoveredFlowers()
        }
    }
    
    private func loadDiscoveredFlowers() {
        if let data = userDefaults.data(forKey: discoveredFlowersKey),
           let decoded = try? JSONDecoder().decode([AIFlower].self, from: data) {
            discoveredFlowers = decoded.sorted { 
                ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
            }
        }
    }
    
    private func saveDiscoveredFlowers() {
        if let encoded = try? JSONEncoder().encode(discoveredFlowers) {
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
        // Generate a test flower for reveal screen
        let testFlower = AIFlower(
            name: "Test Reveal Flower",
            descriptor: "beautiful test flower with rainbow petals",
            imageData: createPlaceholderImage(),
            generatedDate: Date(),
            discoveryDate: Date()
        )
        
        // Set as pending flower to trigger reveal view
        await MainActor.run {
            self.pendingFlower = testFlower
            self.hasUnrevealedFlower = true
        }
    }
} 