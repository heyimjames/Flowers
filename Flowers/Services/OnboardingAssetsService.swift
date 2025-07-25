import Foundation
import UIKit
import CoreLocation
import WeatherKit

class OnboardingAssetsService {
    static let shared = OnboardingAssetsService()
    
    private init() {}
    
    // MARK: - Static Onboarding Assets
    
    private let onboardingFlowerDescriptors = [
        "elegant white rose with soft petals on pure white background",
        "vibrant purple lavender stems with delicate flowers on white background", 
        "cheerful yellow sunflower with dark center on clean white background",
        "soft pink cherry blossoms on branch with white background",
        "orange marigold with ruffled petals on pristine white background",
        "deep blue hydrangea cluster with green leaves on white background",
        "delicate baby's breath flowers scattered on white background"
    ]
    
    private let onboardingFlowerNames = [
        "Pure Elegance Rose",
        "Lavender Dreams", 
        "Sunshine Bloom",
        "Cherry Blossom Wonder",
        "Golden Marigold",
        "Azure Hydrangea",
        "Gentle Baby's Breath"
    ]
    
    // UserDefaults keys for storing generated images
    private let onboardingImagesKey = "onboarding_flower_images"
    private let onboardingImagesGeneratedKey = "onboarding_images_generated"
    
    // MARK: - Public Methods
    
    func initializeAssetsIfNeeded() {
        // Check if we need to generate assets and do it in background
        Task {
            if !hasGeneratedImages() || loadStoredOnboardingFlower() == nil {
                print("OnboardingAssetsService: Initializing assets in background")
                _ = await getOnboardingFlowerImages()
                _ = await getOnboardingFlowerForFirstPage()
            }
        }
    }
    
    func getOnboardingFlowerImages() async -> [UIImage] {
        // Check if we already have generated images
        if hasGeneratedImages(), let images = loadStoredImages() {
            print("OnboardingAssetsService: Using cached onboarding images")
            return images
        }
        
        // Generate new images
        print("OnboardingAssetsService: Generating new onboarding images")
        return await generateOnboardingImages()
    }
    
    func getOnboardingFlowerForFirstPage() async -> AIFlower? {
        // Check if we already have a stored onboarding flower
        if let flower = loadStoredOnboardingFlower() {
            print("OnboardingAssetsService: Using cached onboarding flower")
            return flower
        }
        
        // Generate new onboarding flower
        print("OnboardingAssetsService: Generating new onboarding flower")
        return await generateOnboardingFlower()
    }
    
    // MARK: - Private Methods
    
    private func hasGeneratedImages() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingImagesGeneratedKey)
    }
    
    private func loadStoredImages() -> [UIImage]? {
        guard let imagesData = UserDefaults.standard.data(forKey: onboardingImagesKey) else {
            return nil
        }
        
        do {
            let imageDataArray = try JSONDecoder().decode([Data].self, from: imagesData)
            let images = imageDataArray.compactMap { UIImage(data: $0) }
            
            // Ensure we have all 6 images
            guard images.count == 6 else {
                print("OnboardingAssetsService: Incomplete image set found, regenerating")
                return nil
            }
            
            return images
        } catch {
            print("OnboardingAssetsService: Failed to decode stored images: \(error)")
            return nil
        }
    }
    
    private func storeImages(_ images: [UIImage]) {
        do {
            let imageDataArray = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
            let encodedData = try JSONEncoder().encode(imageDataArray)
            
            UserDefaults.standard.set(encodedData, forKey: onboardingImagesKey)
            UserDefaults.standard.set(true, forKey: onboardingImagesGeneratedKey)
            
            print("OnboardingAssetsService: Successfully stored \(images.count) onboarding images")
        } catch {
            print("OnboardingAssetsService: Failed to store images: \(error)")
        }
    }
    
    private func generateOnboardingImages() async -> [UIImage] {
        var generatedImages: [UIImage] = []
        
        // Use the first 6 descriptors
        let descriptors = Array(onboardingFlowerDescriptors.prefix(6))
        
        for (index, descriptor) in descriptors.enumerated() {
            do {
                print("OnboardingAssetsService: Generating image \(index + 1)/6: \(descriptor)")
                
                // Always use FAL for images (using built-in or user keys)
                let image: UIImage
                let (generatedImage, _) = try await FALService.shared.generateFlowerImage(descriptor: descriptor)
                image = generatedImage
                
                generatedImages.append(image)
                print("OnboardingAssetsService: Successfully generated image \(index + 1)")
                
                // Small delay between requests to avoid rate limiting
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
            } catch {
                print("OnboardingAssetsService: Failed to generate image \(index + 1): \(error)")
                // Add placeholder on error
                if let placeholderImage = createPlaceholderImage(for: descriptor) {
                    generatedImages.append(placeholderImage)
                }
            }
        }
        
        // Store the generated images
        if generatedImages.count == 6 {
            storeImages(generatedImages)
        }
        
        return generatedImages
    }
    
    private func createPlaceholderImage(for descriptor: String) -> UIImage? {
        let size = CGSize(width: 512, height: 512)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // White background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Draw a simple flower shape
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius: CGFloat = 60
        
        // Flower color based on descriptor
        let flowerColor: UIColor
        if descriptor.contains("purple") || descriptor.contains("lavender") {
            flowerColor = UIColor.systemPurple
        } else if descriptor.contains("yellow") || descriptor.contains("sunflower") {
            flowerColor = UIColor.systemYellow
        } else if descriptor.contains("pink") {
            flowerColor = UIColor.systemPink
        } else if descriptor.contains("orange") {
            flowerColor = UIColor.systemOrange
        } else if descriptor.contains("blue") {
            flowerColor = UIColor.systemBlue
        } else {
            flowerColor = UIColor.systemGreen
        }
        
        flowerColor.setFill()
        
        // Draw 5 petals
        for i in 0..<5 {
            let angle = CGFloat(i) * (2 * CGFloat.pi / 5)
            let petalCenter = CGPoint(
                x: center.x + cos(angle) * radius * 0.6,
                y: center.y + sin(angle) * radius * 0.6
            )
            
            let petalRect = CGRect(
                x: petalCenter.x - radius * 0.4,
                y: petalCenter.y - radius * 0.6,
                width: radius * 0.8,
                height: radius * 1.2
            )
            
            UIBezierPath(ovalIn: petalRect).fill()
        }
        
        // Draw center
        UIColor.systemYellow.setFill()
        let centerRect = CGRect(
            x: center.x - radius * 0.3,
            y: center.y - radius * 0.3,
            width: radius * 0.6,
            height: radius * 0.6
        )
        UIBezierPath(ovalIn: centerRect).fill()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - Onboarding Flower for First Page
    
    private let onboardingFlowerKey = "onboarding_main_flower"
    private let onboardingFlowerGeneratedKey = "onboarding_main_flower_generated"
    
    private func loadStoredOnboardingFlower() -> AIFlower? {
        guard UserDefaults.standard.bool(forKey: onboardingFlowerGeneratedKey),
              let flowerData = UserDefaults.standard.data(forKey: onboardingFlowerKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AIFlower.self, from: flowerData)
        } catch {
            print("OnboardingAssetsService: Failed to decode stored onboarding flower: \(error)")
            return nil
        }
    }
    
    private func storeOnboardingFlower(_ flower: AIFlower) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let flowerData = try encoder.encode(flower)
            
            UserDefaults.standard.set(flowerData, forKey: onboardingFlowerKey)
            UserDefaults.standard.set(true, forKey: onboardingFlowerGeneratedKey)
            
            print("OnboardingAssetsService: Successfully stored onboarding flower")
        } catch {
            print("OnboardingAssetsService: Failed to store onboarding flower: \(error)")
        }
    }
    
    private func generateOnboardingFlower() async -> AIFlower? {
        let descriptor = "beautiful Jenny flower with white background, elegant and welcoming, perfect for onboarding"
        let name = "Jenny's Welcome Flower"
        
        do {
            // Always use FAL for images (using built-in or user keys)
            print("OnboardingAssetsService: Calling FAL API to generate onboarding flower")
            let (image, _) = try await FALService.shared.generateFlowerImage(descriptor: descriptor)
            print("OnboardingAssetsService: Successfully generated flower image")
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("OnboardingAssetsService: Failed to convert image to data")
                return createPlaceholderOnboardingFlower()
            }
            
            var flower = AIFlower(
                id: UUID(),
                name: name,
                descriptor: descriptor,
                imageData: imageData,
                generatedDate: Date(),
                meaning: "A warm welcome to your flower journey. This special flower represents the beginning of your daily discovery experience.",
                origins: "Created especially for new users",
                originalOwner: createCurrentOwner()
            )
            
            // Capture current weather and location data
            captureWeatherAndLocation(for: &flower)
            
            storeOnboardingFlower(flower)
            return flower
            
        } catch {
            print("OnboardingAssetsService: Failed to generate onboarding flower: \(error)")
            return createPlaceholderOnboardingFlower()
        }
    }
    
    private func createPlaceholderOnboardingFlower() -> AIFlower? {
        guard let placeholderImage = createPlaceholderImage(for: "welcome flower"),
              let imageData = placeholderImage.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        var flower = AIFlower(
            id: UUID(),
            name: "Jenny's Welcome Flower",
            descriptor: "beautiful welcoming flower with white background",
            imageData: imageData,
            generatedDate: Date(),
            meaning: "A warm welcome to your flower journey. This special flower represents the beginning of your daily discovery experience.",
            origins: "Created especially for new users",
            originalOwner: createCurrentOwner()
        )
        
        // Capture current weather and location data
        captureWeatherAndLocation(for: &flower)
        
        storeOnboardingFlower(flower)
        return flower
    }
    
    // MARK: - Cleanup Methods
    
    func clearStoredAssets() {
        UserDefaults.standard.removeObject(forKey: onboardingImagesKey)
        UserDefaults.standard.removeObject(forKey: onboardingImagesGeneratedKey)
        UserDefaults.standard.removeObject(forKey: onboardingFlowerKey)
        UserDefaults.standard.removeObject(forKey: onboardingFlowerGeneratedKey)
        print("OnboardingAssetsService: Cleared all stored assets")
    }
    
    func regenerateAssets() async {
        clearStoredAssets()
        _ = await getOnboardingFlowerImages()
        _ = await getOnboardingFlowerForFirstPage()
    }
    
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
    
    // MARK: - Weather and Location Capture
    
    private func captureWeatherAndLocation(for flower: inout AIFlower) {
        // Capture current location
        if let currentLocation = ContextualFlowerGenerator.shared.currentLocation {
            flower.discoveryLatitude = currentLocation.coordinate.latitude
            flower.discoveryLongitude = currentLocation.coordinate.longitude
        }
        
        // Capture placemark (human-readable location)
        if let currentPlacemark = ContextualFlowerGenerator.shared.currentPlacemark {
            flower.discoveryLocationName = currentPlacemark.locality ?? currentPlacemark.name
        }
        
        // Capture current weather
        if let weather = ContextualFlowerGenerator.shared.currentWeather {
            let weatherCondition = OnboardingAssetsService.getWeatherConditionString(from: weather.currentWeather.condition)
            let temperature = weather.currentWeather.temperature.value
            
            flower.captureWeatherAndDate(
                weatherCondition: weatherCondition,
                temperature: temperature,
                temperatureUnit: "°C"
            )
        }
    }
    
    static func getWeatherConditionString(from condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear:
            return "Clear"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .cloudy, .mostlyCloudy:
            return "Cloudy"
        case .foggy, .haze:
            return "Foggy"
        case .rain, .drizzle:
            return "Rainy"
        case .heavyRain:
            return "Heavy Rain"
        case .snow, .flurries:
            return "Snowy"
        case .sleet, .freezingRain:
            return "Sleet"
        case .hail:
            return "Hail"
        case .thunderstorms:
            return "Stormy"
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
        case .freezingDrizzle:
            return "Freezing Drizzle"
        @unknown default:
            return "Unknown"
        }
    }
}