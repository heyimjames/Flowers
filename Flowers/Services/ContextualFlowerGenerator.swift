import Foundation
import CoreLocation

class ContextualFlowerGenerator: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = ContextualFlowerGenerator()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkLocationAuthorization()
    }
    
    // MARK: - Location Management
    
    func checkLocationAuthorization() {
        locationPermissionStatus = locationManager.authorizationStatus
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func requestLocationUpdate() {
        // Request a fresh location update
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        
        // Get placemark for location
        if let location = currentLocation {
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
                self?.currentPlacemark = placemarks?.first
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    // MARK: - Contextual Generation
    
    func shouldUseContextualGeneration() -> Bool {
        // 25% chance to use contextual generation
        return Int.random(in: 1...4) == 1
    }
    
    func generateContextualDescriptor() -> (descriptor: String, context: FlowerContext)? {
        var contextElements: [String] = []
        var context = FlowerContext()
        
        // Location-based context
        if let placemark = currentPlacemark {
            context.location = placemark
            
            // Country-specific elements
            if let country = placemark.country {
                context.country = country
                if let countryColors = getCountryColors(country) {
                    contextElements.append(countryColors)
                }
            }
            
            // City/region specific
            if let city = placemark.locality {
                context.city = city
                if Int.random(in: 1...2) == 1 {
                    contextElements.append("\(city)-inspired")
                }
            }
        }
        
        // Date/time-based context
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month, .day, .hour], from: now)
        
        // Seasonal elements
        if let season = getCurrentSeason() {
            context.season = season
            if Int.random(in: 1...3) == 1 {
                contextElements.append("\(season.lowercased())")
            }
        }
        
        // Holiday elements
        if let holiday = getCurrentHoliday() {
            context.holiday = holiday
            contextElements.append(holiday.descriptor)
        }
        
        // Zodiac elements
        if let zodiac = getCurrentZodiacSign() {
            context.zodiacSign = zodiac
            if Int.random(in: 1...3) == 1 {
                contextElements.append(zodiac.descriptor)
            }
        }
        
        // Time of day
        if let hour = components.hour {
            if hour >= 5 && hour < 9 {
                context.timeOfDay = "morning"
                if Int.random(in: 1...3) == 1 {
                    contextElements.append("dawn-kissed")
                }
            } else if hour >= 17 && hour < 21 {
                context.timeOfDay = "evening"
                if Int.random(in: 1...3) == 1 {
                    contextElements.append("sunset-hued")
                }
            } else if hour >= 21 || hour < 5 {
                context.timeOfDay = "night"
                if Int.random(in: 1...3) == 1 {
                    contextElements.append("moonlit")
                }
            }
        }
        
        // Combine with base flower type
        let baseFlowers = ["rose", "orchid", "lily", "dahlia", "iris", "bloom", "blossom", "wildflower", "lotus"]
        let baseFlower = baseFlowers.randomElement() ?? "flower"
        
        // Build descriptor
        let descriptor: String
        if contextElements.isEmpty {
            return nil
        } else if contextElements.count == 1 {
            descriptor = "\(contextElements[0]) \(baseFlower)"
        } else {
            // Pick 1-2 context elements
            let selectedElements = contextElements.shuffled().prefix(Int.random(in: 1...2))
            descriptor = selectedElements.joined(separator: " ") + " \(baseFlower)"
        }
        
        return (descriptor, context)
    }
    
    private func getCountryColors(_ country: String) -> String? {
        let countryColorMap: [String: String] = [
            "Portugal": "red and green Portuguese",
            "Spain": "red and yellow Spanish",
            "France": "blue, white and red French",
            "Italy": "green, white and red Italian",
            "Germany": "black, red and gold German",
            "Brazil": "green and yellow Brazilian",
            "Japan": "red and white Japanese",
            "India": "saffron, white and green Indian",
            "Mexico": "green, white and red Mexican",
            "Canada": "red and white Canadian maple",
            "Australia": "green and gold Australian",
            "United Kingdom": "red, white and blue British",
            "Ireland": "green, white and orange Irish",
            "Netherlands": "orange Dutch",
            "Greece": "blue and white Greek",
            "Sweden": "blue and yellow Swedish",
            "Norway": "red, white and blue Norwegian",
            "Denmark": "red and white Danish",
            "Switzerland": "red and white Swiss",
            "Austria": "red and white Austrian"
        ]
        
        return countryColorMap[country]
    }
    
    private func getCurrentSeason() -> String? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        
        // Adjust for hemisphere if we have location
        let isNorthernHemisphere = currentLocation?.coordinate.latitude ?? 0 >= 0
        
        if isNorthernHemisphere {
            switch month {
            case 3...5: return "Spring"
            case 6...8: return "Summer"
            case 9...11: return "Autumn"
            case 12, 1, 2: return "Winter"
            default: return nil
            }
        } else {
            // Southern hemisphere has opposite seasons
            switch month {
            case 3...5: return "Autumn"
            case 6...8: return "Winter"
            case 9...11: return "Spring"
            case 12, 1, 2: return "Summer"
            default: return nil
            }
        }
    }
    
    func getCurrentHoliday() -> Holiday? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: Date())
        
        guard let month = components.month, let day = components.day else { return nil }
        
        // Major holidays with flower-relevant themes and special bouquet flags
        let holidays: [(month: Int, day: Int, holiday: Holiday)] = [
            (1, 1, Holiday(name: "New Year", descriptor: "celebration sparkle", isBouquetWorthy: true, bouquetTheme: "fresh beginnings with white and gold")),
            (2, 14, Holiday(name: "Valentine's Day", descriptor: "romantic red heart", isBouquetWorthy: true, bouquetTheme: "love and passion with red roses and pink lilies")),
            (3, 17, Holiday(name: "St. Patrick's Day", descriptor: "lucky emerald shamrock", isBouquetWorthy: true, bouquetTheme: "Irish luck with green carnations and white roses")),
            (3, 8, Holiday(name: "International Women's Day", descriptor: "empowering purple", isBouquetWorthy: true, bouquetTheme: "strength and beauty with purple orchids and yellow tulips")),
            (5, 1, Holiday(name: "May Day", descriptor: "spring festival", isBouquetWorthy: true, bouquetTheme: "spring celebration with mixed wildflowers")),
            (5, 12, Holiday(name: "Mother's Day", descriptor: "maternal love", isBouquetWorthy: true, bouquetTheme: "appreciation with pink peonies and white gardenias")),  // Second Sunday of May (approximate)
            (6, 16, Holiday(name: "Father's Day", descriptor: "paternal strength", isBouquetWorthy: true, bouquetTheme: "strength with sunflowers and blue delphiniums")),  // Third Sunday of June (approximate)
            (10, 31, Holiday(name: "Halloween", descriptor: "mystical autumn", isBouquetWorthy: true, bouquetTheme: "mysterious beauty with orange marigolds and deep purple roses")),
            (11, 28, Holiday(name: "Thanksgiving", descriptor: "grateful harvest", isBouquetWorthy: true, bouquetTheme: "gratitude with autumn chrysanthemums and wheat stalks")),  // Fourth Thursday (approximate)
            (12, 25, Holiday(name: "Christmas", descriptor: "festive winter holly", isBouquetWorthy: true, bouquetTheme: "festive joy with red poinsettias and white roses"))
        ]
        
        return holidays.first { $0.month == month && $0.day == day }?.holiday
    }
    
    private func getCurrentZodiacSign() -> ZodiacSign? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: Date())
        
        guard let month = components.month, let day = components.day else { return nil }
        
        let zodiacSigns: [ZodiacSign] = [
            ZodiacSign(name: "Aries", descriptor: "fiery ram", startMonth: 3, startDay: 21, endMonth: 4, endDay: 19),
            ZodiacSign(name: "Taurus", descriptor: "earthly bull", startMonth: 4, startDay: 20, endMonth: 5, endDay: 20),
            ZodiacSign(name: "Gemini", descriptor: "twin butterfly", startMonth: 5, startDay: 21, endMonth: 6, endDay: 20),
            ZodiacSign(name: "Cancer", descriptor: "lunar crab", startMonth: 6, startDay: 21, endMonth: 7, endDay: 22),
            ZodiacSign(name: "Leo", descriptor: "golden lion", startMonth: 7, startDay: 23, endMonth: 8, endDay: 22),
            ZodiacSign(name: "Virgo", descriptor: "harvest maiden", startMonth: 8, startDay: 23, endMonth: 9, endDay: 22),
            ZodiacSign(name: "Libra", descriptor: "balanced scale", startMonth: 9, startDay: 23, endMonth: 10, endDay: 22),
            ZodiacSign(name: "Scorpio", descriptor: "mysterious scorpion", startMonth: 10, startDay: 23, endMonth: 11, endDay: 21),
            ZodiacSign(name: "Sagittarius", descriptor: "adventurous archer", startMonth: 11, startDay: 22, endMonth: 12, endDay: 21),
            ZodiacSign(name: "Capricorn", descriptor: "mountain goat", startMonth: 12, startDay: 22, endMonth: 1, endDay: 19),
            ZodiacSign(name: "Aquarius", descriptor: "water bearer", startMonth: 1, startDay: 20, endMonth: 2, endDay: 18),
            ZodiacSign(name: "Pisces", descriptor: "dreamy fish", startMonth: 2, startDay: 19, endMonth: 3, endDay: 20)
        ]
        
        return zodiacSigns.first { zodiac in
            if zodiac.startMonth == zodiac.endMonth {
                return month == zodiac.startMonth && day >= zodiac.startDay && day <= zodiac.endDay
            } else if zodiac.startMonth > zodiac.endMonth { // Crosses year boundary
                return (month == zodiac.startMonth && day >= zodiac.startDay) ||
                       (month == zodiac.endMonth && day <= zodiac.endDay)
            } else {
                return (month == zodiac.startMonth && day >= zodiac.startDay) ||
                       (month > zodiac.startMonth && month < zodiac.endMonth) ||
                       (month == zodiac.endMonth && day <= zodiac.endDay)
            }
        }
    }
}

// MARK: - Supporting Types

struct FlowerContext {
    var location: CLPlacemark?
    var country: String?
    var city: String?
    var season: String?
    var holiday: Holiday?
    var zodiacSign: ZodiacSign?
    var timeOfDay: String?
    
    func generateContextualMeaning() -> String? {
        var elements: [String] = []
        
        if let city = city {
            elements.append("Inspired by the beauty of \(city)")
        }
        
        if let holiday = holiday {
            elements.append("Celebrating \(holiday.name)")
        }
        
        if let zodiac = zodiacSign {
            elements.append("Embodying the spirit of \(zodiac.name)")
        }
        
        if let season = season {
            elements.append("Blooming in the heart of \(season)")
        }
        
        return elements.isEmpty ? nil : elements.joined(separator: ". ")
    }
}

struct Holiday {
    let name: String
    let descriptor: String
    let isBouquetWorthy: Bool
    let bouquetTheme: String?
    
    init(name: String, descriptor: String, isBouquetWorthy: Bool = false, bouquetTheme: String? = nil) {
        self.name = name
        self.descriptor = descriptor
        self.isBouquetWorthy = isBouquetWorthy
        self.bouquetTheme = bouquetTheme
    }
}

struct ZodiacSign {
    let name: String
    let descriptor: String
    let startMonth: Int
    let startDay: Int
    let endMonth: Int
    let endDay: Int
} 