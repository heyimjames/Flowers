import Foundation
import WeatherKit
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    
    private let weatherService = WeatherKit.WeatherService()
    
    private init() {}
    
    /// Fetch weather for a specific location
    func weather(for location: CLLocation) async throws -> Weather {
        return try await weatherService.weather(for: location)
    }
    
    // Note: For more complex weather queries (hourly, daily, etc.), 
    // you can extend this service with specific methods as needed
    
    /// Check if WeatherKit is available
    var isWeatherKitAvailable: Bool {
        return WeatherService.isSupported
    }
    
    /// Check if WeatherKit is supported on this device
    static var isSupported: Bool {
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
}

// MARK: - Weather Condition Helpers

extension WeatherService {
    /// Convert WeatherKit condition to a simple string for flower generation
    static func getSimpleWeatherCondition(from condition: WeatherCondition) -> String {
        switch condition {
        case .blizzard, .blowingSnow, .heavySnow, .snow:
            return "Snowy"
        case .drizzle, .heavyRain, .rain:
            return "Rainy"
        case .freezingDrizzle, .freezingRain, .sleet, .wintryMix:
            return "Freezing"
        case .flurries:
            return "Flurries"
        case .foggy:
            return "Foggy"
        case .haze:
            return "Hazy"
        case .mostlyClear:
            return "Mostly Clear"
        case .mostlyCloudy:
            return "Mostly Cloudy"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .smoky:
            return "Smoky"
        case .breezy, .windy:
            return "Windy"
        case .clear:
            return "Clear"
        case .cloudy:
            return "Cloudy"
        case .hot:
            return "Hot"
        case .hurricane, .tropicalStorm, .strongStorms:
            return "Stormy"
        case .isolatedThunderstorms, .scatteredThunderstorms, .thunderstorms:
            return "Thunderstorms"
        case .frigid:
            return "Frigid"
        case .hail:
            return "Hail"
        case .sunShowers:
            return "Sun Showers"
        @unknown default:
            return "Clear"
        }
    }
    
    /// Get temperature in Celsius
    static func getTemperatureInCelsius(from measurement: Measurement<UnitTemperature>) -> Double {
        return measurement.converted(to: .celsius).value
    }
    
    /// Get temperature in Fahrenheit
    static func getTemperatureInFahrenheit(from measurement: Measurement<UnitTemperature>) -> Double {
        return measurement.converted(to: .fahrenheit).value
    }
}

// MARK: - Error Handling

enum WeatherServiceError: LocalizedError {
    case notAvailable
    case locationDenied
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Weather service is not available"
        case .locationDenied:
            return "Location access is required for weather data"
        case .networkError:
            return "Unable to fetch weather data. Check your internet connection."
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}