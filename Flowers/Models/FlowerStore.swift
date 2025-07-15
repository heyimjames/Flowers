import Foundation
import SwiftUI
import UIKit

@MainActor
class FlowerStore: ObservableObject {
    @Published var currentFlower: AIFlower?
    @Published var favorites: [AIFlower] = []
    @Published var discoveredFlowers: [AIFlower] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.OCTOBER.Flowers")
    private let favoritesKey = "favorites"
    private let dailyFlowerKey = "dailyFlower"
    private let dailyFlowerDateKey = "dailyFlowerDate"
    private let discoveredFlowersKey = "discoveredFlowers"
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
    
    init() {
        loadFavorites()
        loadDiscoveredFlowers()
        loadDailyFlower()
    }
    
    // MARK: - Daily Flower Management
    func loadDailyFlower() {
        // Check if we have a daily flower for today
        if let savedDate = userDefaults.object(forKey: dailyFlowerDateKey) as? Date,
           Calendar.current.isDateInToday(savedDate),
           let flowerData = userDefaults.data(forKey: dailyFlowerKey),
           let flower = try? JSONDecoder().decode(AIFlower.self, from: flowerData) {
            currentFlower = flower
        } else {
            // Generate new daily flower
            generateDailyFlower()
        }
    }
    
    func generateDailyFlower() {
        Task {
            await generateNewFlower()
        }
    }
    
    // MARK: - Flower Generation
    func generateNewFlower(descriptor: String? = nil) async {
        isGenerating = true
        errorMessage = nil
        
        do {
            let actualDescriptor = descriptor ?? FlowerDescriptors.random()
            
            // Always use FAL for image generation
            let (image, prompt) = try await FALService.shared.generateFlowerImage(descriptor: actualDescriptor)
            
            // Convert UIImage to Data
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                throw NSError(domain: "FlowerStore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
            }
            
            // Use OpenAI to generate a beautiful flower name
            let name: String
            if apiConfig.hasValidOpenAIKey {
                name = try await OpenAIService.shared.generateFlowerName(descriptor: actualDescriptor)
            } else {
                // Fallback to extracting from descriptor if no OpenAI key
                name = extractFlowerName(from: actualDescriptor)
            }
            
            var flower = AIFlower(
                name: name,
                descriptor: actualDescriptor,
                imageData: imageData,
                generatedDate: Date(),
                isFavorite: false,
                discoveryDate: Date()
            )
            
            // Get a random continent for now (will be replaced by AI-generated continent)
            flower.continent = Continent.allCases.randomElement()
            
            currentFlower = flower
            
            // Add to discovered flowers
            addToDiscoveredFlowers(flower)
            
            // Save to shared container for widget
            if let encoded = try? JSONEncoder().encode(flower) {
                sharedDefaults?.set(encoded, forKey: dailyFlowerKey)
                sharedDefaults?.set(Date(), forKey: dailyFlowerDateKey)
            }
            
        } catch {
            // If API fails or no API key, fall back to mock
            if !apiConfig.hasValidFalKey {
                let flower = createMockFlower(descriptor: descriptor)
                currentFlower = flower
                addToDiscoveredFlowers(flower)
                errorMessage = "No FAL API key configured. Using placeholder images."
            } else {
                errorMessage = error.localizedDescription
                // Create a mock flower as fallback
                let flower = createMockFlower(descriptor: descriptor)
                currentFlower = flower
                addToDiscoveredFlowers(flower)
            }
        }
        
        isGenerating = false
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
            favorites.append(flower)
        } else {
            favorites.removeAll { $0.id == flower.id }
        }
        
        saveFavorites()
    }
    
    func deleteFavorite(_ flower: AIFlower) {
        favorites.removeAll { $0.id == flower.id }
        if currentFlower?.id == flower.id {
            currentFlower?.isFavorite = false
        }
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([AIFlower].self, from: data) {
            favorites = decoded
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
            discoveredFlowers.append(flower)
            saveDiscoveredFlowers()
        }
    }
    
    private func loadDiscoveredFlowers() {
        if let data = userDefaults.data(forKey: discoveredFlowersKey),
           let decoded = try? JSONDecoder().decode([AIFlower].self, from: data) {
            discoveredFlowers = decoded
        }
    }
    
    private func saveDiscoveredFlowers() {
        if let encoded = try? JSONEncoder().encode(discoveredFlowers) {
            userDefaults.set(encoded, forKey: discoveredFlowersKey)
        }
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
} 