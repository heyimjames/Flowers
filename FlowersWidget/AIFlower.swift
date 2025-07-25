import Foundation
import SwiftUI

// MARK: - Ownership Tracking

struct FlowerOwner: Codable, Equatable {
    let id: UUID
    let name: String
    let deviceID: String
    let transferDate: Date
    let location: String?
    
    init(name: String, deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown", transferDate: Date = Date(), location: String? = nil) {
        self.id = UUID()
        self.name = name
        self.deviceID = deviceID
        self.transferDate = transferDate
        self.location = location
    }
}

// MARK: - Widget-compatible AIFlower Model
// This is a simplified version of the main AIFlower model for widget use

struct AIFlower: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let descriptor: String
    let imageData: Data?
    let generatedDate: Date
    var isFavorite: Bool
    
    // Botanical information
    var scientificName: String?
    var family: String?
    var nativeRegions: [String]?
    var bloomingSeason: String?
    var conservationStatus: String?
    var uses: [String]?
    var interestingFacts: [String]?
    var careInstructions: String?
    
    // Detailed information
    var meaning: String?
    var properties: String?
    var origins: String?
    var detailedDescription: String?
    var shortDescription: String?
    var discoveryDate: Date?
    var contextualGeneration: Bool = false
    var generationContext: String?
    var isBouquet: Bool = false
    var bouquetFlowers: [String]?
    var holidayName: String?
    var discoveryLatitude: Double?
    var discoveryLongitude: Double?
    var discoveryLocationName: String?
    
    // Herbarium tracking
    var isInHerbarium: Bool = false
    
    // Weather and date information
    var discoveryWeatherCondition: String?
    var discoveryTemperature: Double?
    var discoveryTemperatureUnit: String?
    var discoveryDayOfWeek: String?
    var discoveryFormattedDate: String?
    
    // Ownership tracking
    var originalOwner: FlowerOwner?
    var ownershipHistory: [FlowerOwner] = []
    var transferToken: String?
    var isGiftable: Bool = true
    
    init(id: UUID = UUID(), 
         name: String, 
         descriptor: String, 
         imageData: Data? = nil, 
         generatedDate: Date = Date(), 
         isFavorite: Bool = false,
         scientificName: String? = nil,
         family: String? = nil,
         nativeRegions: [String]? = nil,
         bloomingSeason: String? = nil,
         conservationStatus: String? = nil,
         uses: [String]? = nil,
         interestingFacts: [String]? = nil,
         careInstructions: String? = nil,
         meaning: String? = nil,
         properties: String? = nil,
         origins: String? = nil,
         detailedDescription: String? = nil,
         shortDescription: String? = nil,
         discoveryDate: Date? = nil,
         contextualGeneration: Bool = false,
         generationContext: String? = nil,
         isBouquet: Bool = false,
         bouquetFlowers: [String]? = nil,
         holidayName: String? = nil,
         discoveryLatitude: Double? = nil,
         discoveryLongitude: Double? = nil,
         discoveryLocationName: String? = nil,
         isInHerbarium: Bool = false,
         discoveryWeatherCondition: String? = nil,
         discoveryTemperature: Double? = nil,
         discoveryTemperatureUnit: String? = nil,
         discoveryDayOfWeek: String? = nil,
         discoveryFormattedDate: String? = nil,
         originalOwner: FlowerOwner? = nil,
         ownershipHistory: [FlowerOwner] = [],
         transferToken: String? = nil,
         isGiftable: Bool = true) {
        self.id = id
        self.name = name
        self.descriptor = descriptor
        self.imageData = imageData
        self.generatedDate = generatedDate
        self.isFavorite = isFavorite
        self.scientificName = scientificName
        self.family = family
        self.nativeRegions = nativeRegions
        self.bloomingSeason = bloomingSeason
        self.conservationStatus = conservationStatus
        self.uses = uses
        self.interestingFacts = interestingFacts
        self.careInstructions = careInstructions
        self.meaning = meaning
        self.properties = properties
        self.origins = origins
        self.detailedDescription = detailedDescription
        self.shortDescription = shortDescription
        self.discoveryDate = discoveryDate
        self.contextualGeneration = contextualGeneration
        self.generationContext = generationContext
        self.isBouquet = isBouquet
        self.bouquetFlowers = bouquetFlowers
        self.holidayName = holidayName
        self.discoveryLatitude = discoveryLatitude
        self.discoveryLongitude = discoveryLongitude
        self.discoveryLocationName = discoveryLocationName
        self.isInHerbarium = isInHerbarium
        self.discoveryWeatherCondition = discoveryWeatherCondition
        self.discoveryTemperature = discoveryTemperature
        self.discoveryTemperatureUnit = discoveryTemperatureUnit
        self.discoveryDayOfWeek = discoveryDayOfWeek
        self.discoveryFormattedDate = discoveryFormattedDate
        self.originalOwner = originalOwner
        self.ownershipHistory = ownershipHistory
        self.transferToken = transferToken
        self.isGiftable = isGiftable
    }
    
    // Sample flower for preview/placeholder
    static var sample: AIFlower {
        AIFlower(
            name: "Moonlight Rose",
            descriptor: "moonlight rose with silver petals",
            imageData: nil,
            isFavorite: false
        )
    }
}

// Flower name generator
struct FlowerNameGenerator {
    static let adjectives = ["Crystal", "Moonlight", "Stardust", "Aurora", "Velvet", "Mystic", "Ethereal", "Celestial"]
    static let nouns = ["Rose", "Lily", "Orchid", "Dahlia", "Iris", "Blossom", "Bloom", "Petal"]
    
    static func generateName() -> String {
        let adjective = adjectives.randomElement() ?? "Beautiful"
        let noun = nouns.randomElement() ?? "Flower"
        return "\(adjective) \(noun)"
    }
    
    static func generateDescriptor() -> String {
        let adjective = adjectives.randomElement()?.lowercased() ?? "beautiful"
        let noun = nouns.randomElement()?.lowercased() ?? "flower"
        return "\(adjective) \(noun) with ethereal petals"
    }
} 