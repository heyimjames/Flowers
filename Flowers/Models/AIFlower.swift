import Foundation
import SwiftUI
import MapKit

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

struct TransferMetadata: Codable {
    let transferID: UUID
    let transferDate: Date
    let senderInfo: FlowerOwner
    
    init(senderInfo: FlowerOwner) {
        self.transferID = UUID()
        self.transferDate = Date()
        self.senderInfo = senderInfo
    }
}

// MARK: - Flower Document for Transfer
struct FlowerDocument: Codable {
    let flower: AIFlower
    let transferMetadata: TransferMetadata
    let version: Int = 1 // For future compatibility
}

// MARK: - Main AIFlower Model
struct AIFlower: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let descriptor: String
    let imageData: Data?
    let generatedDate: Date
    var isFavorite: Bool
    
    // Botanical information
    var scientificName: String? // e.g., "Rosa damascena"
    var commonNames: [String]? // e.g., ["Damask Rose", "Bulgarian Rose"]
    var family: String? // e.g., "Rosaceae"
    var nativeRegions: [String]? // e.g., ["Middle East", "Central Asia"]
    var bloomingSeason: String? // e.g., "Late spring to early summer"
    var conservationStatus: String? // e.g., "Least Concern", "Endangered"
    var uses: [String]? // e.g., ["Essential oil production", "Culinary", "Medicinal"]
    var interestingFacts: [String]? // Array of fascinating facts about the species
    var careInstructions: String? // Basic growing requirements
    var rarityLevel: RarityLevel? // How rare/common this species is
    
    // Detailed information about the flower
    var meaning: String?
    var properties: String?
    var origins: String?
    var detailedDescription: String?
    var shortDescription: String? // AI-generated short description for map cards
    var continent: Continent?
    var discoveryDate: Date? // When the user "discovered" this flower
    var contextualGeneration: Bool = false // Whether this flower used contextual generation
    var generationContext: String? // Context used for generation (e.g., "Portuguese sunset rose")
    var isBouquet: Bool = false // Whether this is a holiday bouquet
    var bouquetFlowers: [String]? // Names of flowers in the bouquet
    var holidayName: String? // Holiday this bouquet celebrates
    var discoveryLatitude: Double? // Latitude where flower was discovered
    var discoveryLongitude: Double? // Longitude where flower was discovered
    var discoveryLocationName: String? // Human-readable location name
    
    // Herbarium tracking
    var isInHerbarium: Bool = false // Whether user has collected this species in their herbarium
    
    // Weather and date information
    var discoveryWeatherCondition: String? // Weather condition (e.g., "Sunny", "Cloudy", "Rainy")
    var discoveryTemperature: Double? // Temperature in Celsius
    var discoveryTemperatureUnit: String? // Temperature unit (C or F)
    var discoveryDayOfWeek: String? // Day of the week (e.g., "Monday")
    var discoveryFormattedDate: String? // Formatted date (e.g., "15th June 2025")
    
    // Ownership tracking
    var originalOwner: FlowerOwner?
    var ownershipHistory: [FlowerOwner]
    var transferToken: String? // One-time use token for transfers
    var isGiftable: Bool // Whether this flower can be gifted (false for special flowers)
    
    init(id: UUID = UUID(), 
         name: String, 
         descriptor: String, 
         imageData: Data? = nil, 
         generatedDate: Date = Date(), 
         isFavorite: Bool = false,
         scientificName: String? = nil,
         commonNames: [String]? = nil,
         family: String? = nil,
         nativeRegions: [String]? = nil,
         bloomingSeason: String? = nil,
         conservationStatus: String? = nil,
         uses: [String]? = nil,
         interestingFacts: [String]? = nil,
         careInstructions: String? = nil,
         rarityLevel: RarityLevel? = nil,
         meaning: String? = nil,
         properties: String? = nil,
         origins: String? = nil,
         detailedDescription: String? = nil,
         shortDescription: String? = nil,
         continent: Continent? = nil,
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
        self.commonNames = commonNames
        self.family = family
        self.nativeRegions = nativeRegions
        self.bloomingSeason = bloomingSeason
        self.conservationStatus = conservationStatus
        self.uses = uses
        self.interestingFacts = interestingFacts
        self.careInstructions = careInstructions
        self.rarityLevel = rarityLevel
        self.meaning = meaning
        self.properties = properties
        self.origins = origins
        self.detailedDescription = detailedDescription
        self.shortDescription = shortDescription
        self.continent = continent
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

// MARK: - Ownership Transfer Methods
extension AIFlower {
    mutating func prepareForTransfer(from owner: FlowerOwner) -> TransferMetadata {
        // Add current owner to history if this is the first transfer
        if ownershipHistory.isEmpty && originalOwner == nil {
            originalOwner = owner
        } else {
            // Add to ownership history
            ownershipHistory.append(owner)
        }
        
        // Generate one-time transfer token
        transferToken = UUID().uuidString
        
        // Create transfer metadata
        return TransferMetadata(senderInfo: owner)
    }
    
    mutating func completeTransfer() {
        // Clear transfer token after successful transfer
        transferToken = nil
    }
    
    mutating func cancelTransfer() {
        // Remove the last owner if transfer was cancelled
        if !ownershipHistory.isEmpty {
            ownershipHistory.removeLast()
        }
        transferToken = nil
    }
    
    var hasOwnershipHistory: Bool {
        return originalOwner != nil || !ownershipHistory.isEmpty
    }
    
    var currentOwnerCount: Int {
        var count = 0
        if originalOwner != nil { count += 1 }
        count += ownershipHistory.count
        return count + 1 // Plus current owner
    }
    
    // Helper method to capture weather and date information
    mutating func captureWeatherAndDate(weatherCondition: String?, temperature: Double?, temperatureUnit: String?) {
        let now = Date()
        
        // Capture weather data
        self.discoveryWeatherCondition = weatherCondition
        self.discoveryTemperature = temperature
        self.discoveryTemperatureUnit = temperatureUnit
        
        // Capture date information
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Day of the week
        self.discoveryDayOfWeek = dateFormatter.string(from: now)
        
        // Format the date as "15th June 2025"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = dayFormatter.string(from: now)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let month = monthFormatter.string(from: now)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: now)
        
        // Add ordinal suffix to day
        let dayInt = Int(day) ?? 0
        let ordinalSuffix: String
        switch dayInt {
        case 11, 12, 13:
            ordinalSuffix = "th"
        case _ where dayInt % 10 == 1:
            ordinalSuffix = "st"
        case _ where dayInt % 10 == 2:
            ordinalSuffix = "nd"
        case _ where dayInt % 10 == 3:
            ordinalSuffix = "rd"
        default:
            ordinalSuffix = "th"
        }
        
        self.discoveryFormattedDate = "\(day)\(ordinalSuffix) \(month) \(year)"
    }
}

// Rarity levels for species
enum RarityLevel: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon" 
    case rare = "Rare"
    case veryRare = "Very Rare"
    case endangered = "Endangered"
    case extinct = "Extinct in Wild"
    
    var emoji: String {
        switch self {
        case .common: return "🌱"
        case .uncommon: return "🌿"
        case .rare: return "🌺"
        case .veryRare: return "💎"
        case .endangered: return "⚠️"
        case .extinct: return "🚨"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .veryRare: return 3
        case .endangered: return 4
        case .extinct: return 5
        }
    }
}

// Continent enum for tracking flower origins
enum Continent: String, Codable, CaseIterable {
    case northAmerica = "North America"
    case southAmerica = "South America"
    case europe = "Europe"
    case africa = "Africa"
    case asia = "Asia"
    case oceania = "Oceania"
    case antarctica = "Antarctica"
}

// Flower details generated by AI
struct FlowerDetails: Codable {
    let meaning: String
    let properties: String
    let origins: String
    let detailedDescription: String
    let continent: String
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

// Flower descriptor constants
struct FlowerDescriptors {
    static let descriptors = [
        "delicate alpine rose with morning dew",
        "tropical orchid with soft pastel petals",
        "wildflower lily from mountain meadows",
        "sunset dahlia with gradient colors",
        "deep purple iris with velvety texture",
        "cherry blossom with delicate pink petals",
        "garden bloom with layered petals",
        "meadow flower with soft pastels",
        "blue lotus floating on water",
        "golden sunflower facing the sun",
        "winter rose with frost-kissed edges",
        "desert lily with resilient petals",
        "white jasmine with sweet fragrance",
        "violet with deep purple hues",
        "rainforest orchid with exotic patterns",
        "coastal wildflower with salt-spray resilience",
        "spring tulip with perfect symmetry",
        "climbing vine flower with delicate tendrils",
        "pond lily with floating leaves",
        "mountain wildflower with alpine colors"
    ]
    
    static func random() -> String {
        descriptors.randomElement() ?? descriptors[0]
    }
} 