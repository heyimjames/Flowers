import Foundation
import CoreLocation
import WeatherKit

class ContextualFlowerGenerator: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = ContextualFlowerGenerator()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentWeather: Weather?
    
    private let weatherService = WeatherService.shared
    
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
            
            // Get weather for location
            Task {
                await self.updateWeather(for: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    // MARK: - Weather Management
    
    private func updateWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            await MainActor.run {
                self.currentWeather = weather
            }
        } catch {
            print("Weather update error: \(error)")
        }
    }
    
    // MARK: - Contextual Generation
    
    func shouldUseContextualGeneration() -> Bool {
        // 25% chance to use contextual generation
        return Int.random(in: 1...4) == 1
    }
    
    func selectContextualSpecies(existingSpecies: [String] = []) -> (species: BotanicalSpecies, context: FlowerContext)? {
        var context = FlowerContext()
        
        // Location-based context
        var targetContinent: Continent?
        if let placemark = currentPlacemark {
            context.location = placemark
            
            // Country-specific continent mapping
            if let country = placemark.country {
                context.country = country
                targetContinent = getContinent(for: country)
            }
            
            // City/region specific
            if let city = placemark.locality {
                context.city = city
            }
        }
        
        // Date/time-based context
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month, .day, .hour], from: now)
        
        // Seasonal elements
        let season = getCurrentSeason()
        context.season = season.rawValue
        
        // Holiday elements
        if let holiday = getCurrentHoliday() {
            context.holiday = holiday
        }
        
        // Zodiac elements
        if let zodiac = getCurrentZodiacSign() {
            context.zodiacSign = zodiac
        }
        
        // Time of day
        if let hour = components.hour {
            if hour >= 5 && hour < 9 {
                context.timeOfDay = "morning"
            } else if hour >= 17 && hour < 21 {
                context.timeOfDay = "evening"
            } else if hour >= 21 || hour < 5 {
                context.timeOfDay = "night"
            }
        }
        
        // Weather-based context
        if let weather = currentWeather {
            context.weather = weather
        }
        
        // Get appropriate species from botanical database
        let species = BotanicalDatabase.shared.getContextualSpecies(
            continent: targetContinent,
            season: season.rawValue,
            existingSpecies: existingSpecies
        )
        
        guard let selectedSpecies = species else { return nil }
        
        return (selectedSpecies, context)
    }
    
    private func getContinent(for country: String) -> Continent? {
        let continentMap: [String: Continent] = [
            "Portugal": .europe, "Spain": .europe, "France": .europe, "Italy": .europe,
            "Germany": .europe, "United Kingdom": .europe, "Ireland": .europe,
            "Netherlands": .europe, "Greece": .europe, "Sweden": .europe,
            "Norway": .europe, "Denmark": .europe, "Switzerland": .europe,
            "Austria": .europe, "Poland": .europe, "Czech Republic": .europe,
            
            "United States": .northAmerica, "Canada": .northAmerica, "Mexico": .northAmerica,
            "Guatemala": .northAmerica, "Costa Rica": .northAmerica,
            
            "Brazil": .southAmerica, "Argentina": .southAmerica, "Chile": .southAmerica,
            "Peru": .southAmerica, "Colombia": .southAmerica, "Venezuela": .southAmerica,
            
            "Japan": .asia, "China": .asia, "India": .asia, "South Korea": .asia,
            "Thailand": .asia, "Vietnam": .asia, "Indonesia": .asia, "Malaysia": .asia,
            "Singapore": .asia, "Philippines": .asia, "Russia": .asia,
            
            "South Africa": .africa, "Egypt": .africa, "Morocco": .africa,
            "Kenya": .africa, "Nigeria": .africa, "Ghana": .africa,
            
            "Australia": .oceania, "New Zealand": .oceania, "Fiji": .oceania
        ]
        
        return continentMap[country]
    }
    
    func getRandomSpecies(existingSpecies: [String] = []) -> BotanicalSpecies? {
        return BotanicalDatabase.shared.getRandomSpecies(excluding: existingSpecies)
    }
    
    func getCurrentSeason() -> Season {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        
        // Adjust for hemisphere if we have location
        let isNorthernHemisphere = currentLocation?.coordinate.latitude ?? 0 >= 0
        
        if isNorthernHemisphere {
            switch month {
            case 3...5: return .spring
            case 6...8: return .summer
            case 9...11: return .autumn
            case 12, 1, 2: return .winter
            default: return .spring // Fallback
            }
        } else {
            // Southern hemisphere has opposite seasons
            switch month {
            case 3...5: return .autumn
            case 6...8: return .winter
            case 9...11: return .spring
            case 12, 1, 2: return .summer
            default: return .spring // Fallback
            }
        }
    }
    
    func getCurrentHoliday() -> Holiday? {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.month, .day, .year], from: today)
        guard let month = components.month, let day = components.day, let year = components.year else { return nil }
        
        // Major holidays with flower-relevant themes and special bouquet flags
        let holidays: [(month: Int, day: Int, holiday: Holiday)] = [
            // Regular holidays
            (1, 1, Holiday(name: "New Year", descriptor: "celebration sparkle", isBouquetWorthy: true, bouquetTheme: "fresh beginnings with white and gold")),
            (2, 14, Holiday(name: "Valentine's Day", descriptor: "romantic red heart", isBouquetWorthy: true, bouquetTheme: "love and passion with red roses and pink lilies")),
            (3, 17, Holiday(name: "St. Patrick's Day", descriptor: "lucky emerald shamrock", isBouquetWorthy: true, bouquetTheme: "Irish luck with green carnations and white roses")),
            (3, 8, Holiday(name: "International Women's Day", descriptor: "empowering purple", isBouquetWorthy: true, bouquetTheme: "strength and beauty with purple orchids and yellow tulips")),
            (5, 1, Holiday(name: "May Day", descriptor: "spring festival", isBouquetWorthy: true, bouquetTheme: "spring celebration with mixed wildflowers")),
            
            // Personal special dates
            (5, 12, Holiday(
                name: "Yvonne's Birthday", 
                descriptor: "maternal love and appreciation", 
                isBouquetWorthy: true, 
                bouquetTheme: "elegant spring flowers in soft pastels to celebrate a wonderful mother",
                customLocation: (51.7520, -1.2577, "Oxford, United Kingdom"),
                personalMessage: "A special bouquet to celebrate Yvonne, James' wonderful mother, on her birthday. Her love, wisdom, and kindness have shaped the person he has become. These flowers represent the gratitude and love for a mother who has given so much.",
                customFlowerName: "Yvonne's Birthday Bouquet"
            )),
            
            (5, 17, Holiday(
                name: "Jenny's Birthday", 
                descriptor: "birthday celebration", 
                isBouquetWorthy: true, 
                bouquetTheme: "stunning Copo De Leite (Arum Lily) flowers native to Brazil, pure white with elegant curves",
                customLocation: (-23.5505, -46.6333, "São Paulo, Brazil"),
                personalMessage: "A breathtaking bouquet of Copo De Leite flowers to celebrate Jenny, James' beloved fiancée, on her special day. These elegant Brazilian lilies represent the pure love and joy she brings to life. Happy Birthday to the most wonderful person who makes every day brighter!",
                customFlowerName: "Jenny's Birthday Copo De Leite"
            )),
            
            (6, 16, Holiday(name: "Father's Day", descriptor: "paternal strength", isBouquetWorthy: true, bouquetTheme: "strength with sunflowers and blue delphiniums")),
            
            (7, 23, Holiday(
                name: "Ita's Memorial", 
                descriptor: "remembrance and love", 
                isBouquetWorthy: true, 
                bouquetTheme: "beautiful Brazilian-themed flowers in vibrant green, blue and yellow, honoring a beloved grandmother",
                customLocation: (-23.5505, -46.6333, "São Paulo, Brazil"),
                personalMessage: "A special Brazilian bouquet to celebrate and remember Ita, Jenny's amazing grandmother, on her birthday. Her spirit lives on in the love she shared and the memories she created. These flowers in Brazil's colors honor a truly remarkable woman who touched so many lives with her kindness and warmth.",
                customFlowerName: "Ita's Birthday Remembrance"
            )),
            
            (10, 1, Holiday(
                name: "James' Birthday", 
                descriptor: "birthday celebration", 
                isBouquetWorthy: true, 
                bouquetTheme: "majestic Bird of Paradise flower with vibrant orange and blue petals",
                customLocation: (51.5074, -0.1278, "London, United Kingdom"),
                personalMessage: "A stunning Bird of Paradise flower to celebrate James, the creator of this app, on his birthday. May this exotic bloom represent the colorful journey ahead and all the beauty life has to offer.",
                customFlowerName: "James' Bird of Paradise"
            )),
            
            (10, 31, Holiday(name: "Halloween", descriptor: "mystical autumn", isBouquetWorthy: true, bouquetTheme: "mysterious beauty with orange marigolds and deep purple roses")),
            
            (11, 13, Holiday(
                name: "Wedding Anniversary", 
                descriptor: "eternal love", 
                isBouquetWorthy: true, 
                bouquetTheme: "romantic wedding bouquet with white roses, Portuguese lavender, and touches of gold",
                customLocation: (38.7223, -9.1393, "Lisbon, Portugal"),
                personalMessage: "A magnificent wedding bouquet celebrating the beautiful union of James and Jenny. Each year marks another chapter in their love story, which began in Portugal. May these flowers represent the continuing bloom of their love, growing stronger and more beautiful with each passing year.",
                customFlowerName: "Anniversary Wedding Bouquet"
            )),
            
            (11, 25, Holiday(
                name: "First Meeting Anniversary", 
                descriptor: "the beginning of love", 
                isBouquetWorthy: true, 
                bouquetTheme: "romantic flowers symbolizing new beginnings and the spark of first love",
                customLocation: (51.5054, -0.0235, "Canary Wharf, London"),
                personalMessage: "A special bouquet commemorating the magical day when James and Jenny first met. In the heart of Canary Wharf, two paths crossed and a beautiful love story began. These flowers celebrate that fateful moment when two souls found each other.",
                customFlowerName: "First Meeting Flowers"
            )),
            
            (11, 28, Holiday(name: "Thanksgiving", descriptor: "grateful harvest", isBouquetWorthy: true, bouquetTheme: "gratitude with autumn chrysanthemums and wheat stalks")),
            (12, 25, Holiday(name: "Christmas", descriptor: "festive winter holly", isBouquetWorthy: true, bouquetTheme: "festive joy with red poinsettias and white roses"))
        ]
        
        // Find matching holiday
        if let matchingHoliday = holidays.first(where: { $0.month == month && $0.day == day })?.holiday {
            // Special handling for wedding anniversary to update the year
            if matchingHoliday.name == "Wedding Anniversary" && month == 11 && day == 13 {
                let weddingYear = 2025 // Year they got married
                let yearsMarried = year - weddingYear
                let ordinal = yearsMarried == 1 ? "1st" : yearsMarried == 2 ? "2nd" : yearsMarried == 3 ? "3rd" : "\(yearsMarried)th"
                
                return Holiday(
                    name: matchingHoliday.name,
                    descriptor: matchingHoliday.descriptor,
                    isBouquetWorthy: matchingHoliday.isBouquetWorthy,
                    bouquetTheme: matchingHoliday.bouquetTheme,
                    customLocation: matchingHoliday.customLocation,
                    personalMessage: "A magnificent wedding bouquet celebrating the beautiful union of James and Jenny on their \(ordinal) anniversary. Each year marks another chapter in their love story, which began in Portugal. May these flowers represent the continuing bloom of their love, growing stronger and more beautiful with each passing year.",
                    customFlowerName: "\(ordinal) Anniversary Wedding Bouquet"
                )
            }
            return matchingHoliday
        }
        
        return nil
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

enum Season: String, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
}

struct FlowerContext {
    var location: CLPlacemark?
    var country: String?
    var city: String?
    var season: String?
    var holiday: Holiday?
    var zodiacSign: ZodiacSign?
    var timeOfDay: String?
    var weather: Weather?
    
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
        
        if let weather = weather {
            let condition = weather.currentWeather.condition
            let temp = weather.currentWeather.temperature
            
            switch condition {
            case .clear:
                elements.append("Flourishing under clear skies")
            case .rain, .drizzle:
                elements.append("Nourished by gentle rain")
            case .snow:
                elements.append("Thriving in winter's embrace")
            default:
                break
            }
            
            if temp.value > 25 {
                elements.append("Warmed by the sun")
            } else if temp.value < 5 {
                elements.append("Resilient in the cold")
            }
        }
        
        return elements.isEmpty ? nil : elements.joined(separator: ". ")
    }
}

struct Holiday {
    let name: String
    let descriptor: String
    let isBouquetWorthy: Bool
    let bouquetTheme: String?
    let customLocation: (latitude: Double, longitude: Double, name: String)?
    let personalMessage: String?
    let customFlowerName: String?
    
    init(name: String, descriptor: String, isBouquetWorthy: Bool = false, bouquetTheme: String? = nil, 
         customLocation: (latitude: Double, longitude: Double, name: String)? = nil,
         personalMessage: String? = nil, customFlowerName: String? = nil) {
        self.name = name
        self.descriptor = descriptor
        self.isBouquetWorthy = isBouquetWorthy
        self.bouquetTheme = bouquetTheme
        self.customLocation = customLocation
        self.personalMessage = personalMessage
        self.customFlowerName = customFlowerName
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