import Foundation
import SwiftUI

struct AIFlower: Identifiable, Codable {
    let id: UUID
    let name: String
    let descriptor: String
    let imageData: Data?
    let generatedDate: Date
    var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String, descriptor: String, imageData: Data? = nil, generatedDate: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.descriptor = descriptor
        self.imageData = imageData
        self.generatedDate = generatedDate
        self.isFavorite = isFavorite
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