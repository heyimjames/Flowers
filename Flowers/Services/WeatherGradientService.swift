//
//  WeatherGradientService.swift
//  Flowers
//
//  Created by James Frewin on 24/07/2025.
//

import SwiftUI
import Foundation

/// Centralized service for generating contextual weather gradients
/// Used across the main app and widgets for consistent visual experience
struct WeatherGradientService {
    
    /// Generate contextual weather gradient colors based on condition, temperature, and time
    static func getWeatherGradient(
        condition: String?,
        temperature: Double?,
        temperatureUnit: String? = "°C",
        discoveryDate: Date? = nil
    ) -> [Color] {
        
        guard let condition = condition else {
            return defaultGradient()
        }
        
        let temp = temperature ?? 20.0
        let timeOfDay = getTimeOfDay(for: discoveryDate ?? Date())
        
        return getContextualWeatherGradient(
            condition: condition,
            temperature: temp,
            timeOfDay: timeOfDay
        )
    }
    
    /// Get a simplified gradient for small widgets (2 colors instead of 3)
    static func getSimplifiedWeatherGradient(
        condition: String?,
        temperature: Double?,
        temperatureUnit: String? = "°C",
        discoveryDate: Date? = nil
    ) -> [Color] {
        
        let fullGradient = getWeatherGradient(
            condition: condition,
            temperature: temperature,
            temperatureUnit: temperatureUnit,
            discoveryDate: discoveryDate
        )
        
        // Return first and last colors for simplified gradient
        if fullGradient.count >= 2 {
            return [fullGradient.first!, fullGradient.last!]
        }
        
        return fullGradient
    }
    
    /// Get weather-based background tint for subtle effects
    static func getWeatherTint(
        condition: String?,
        temperature: Double?,
        alpha: Double = 0.1
    ) -> Color {
        
        guard let condition = condition else {
            return Color.clear
        }
        
        let temp = temperature ?? 20.0
        let conditionLower = condition.lowercased()
        
        switch conditionLower {
        case "sunny", "clear":
            if temp >= 31 {
                return Color.orange.opacity(alpha)
            } else if temp < 0 {
                return Color.blue.opacity(alpha * 0.5)
            } else {
                return Color.blue.opacity(alpha * 0.3)
            }
        case "rainy", "rain", "drizzle":
            return Color.gray.opacity(alpha)
        case "cloudy", "mostly cloudy", "overcast":
            return Color.gray.opacity(alpha * 0.7)
        case "partly cloudy":
            return Color.blue.opacity(alpha * 0.2)
        case "snowy", "snow":
            return Color.blue.opacity(alpha * 0.4)
        case "thunderstorms":
            return Color.purple.opacity(alpha)
        default:
            return Color.clear
        }
    }
    
    // MARK: - Private Helper Methods
    
    private static func getContextualWeatherGradient(condition: String, temperature: Double, timeOfDay: String) -> [Color] {
        let conditionLower = condition.lowercased()
        
        // Time of day overrides for dramatic gradients
        switch timeOfDay {
        case "dawn":
            return [
                Color(red: 255/255, green: 183/255, blue: 107/255), // Warm orange
                Color(red: 255/255, green: 204/255, blue: 128/255), // Light peach
                Color(red: 135/255, green: 206/255, blue: 250/255)  // Light sky blue
            ]
        case "sunset", "evening":
            return [
                Color(red: 255/255, green: 94/255, blue: 77/255),   // Coral red
                Color(red: 255/255, green: 154/255, blue: 0/255),   // Orange
                Color(red: 255/255, green: 206/255, blue: 84/255)   // Golden yellow
            ]
        case "night":
            return [
                Color(red: 25/255, green: 25/255, blue: 112/255),   // Midnight blue
                Color(red: 72/255, green: 61/255, blue: 139/255),   // Dark slate blue
                Color(red: 106/255, green: 90/255, blue: 205/255)   // Slate blue
            ]
        default:
            break
        }
        
        // Weather condition based gradients for day/morning/afternoon
        switch conditionLower {
        case "sunny", "clear":
            if temperature >= 31 { // Hot summer day - heat wave orange/red
                return [
                    Color(red: 255/255, green: 69/255, blue: 0/255),    // Red orange
                    Color(red: 255/255, green: 140/255, blue: 0/255),   // Dark orange
                    Color(red: 255/255, green: 165/255, blue: 0/255)    // Orange
                ]
            } else if temperature > 25 { // Warm sunny - golden
                return [
                    Color(red: 255/255, green: 215/255, blue: 0/255),   // Gold
                    Color(red: 255/255, green: 165/255, blue: 0/255),   // Orange
                    Color(red: 135/255, green: 206/255, blue: 250/255)  // Sky blue
                ]
            } else if temperature < 0 { // Cold but clear - icy blue
                return [
                    Color(red: 240/255, green: 248/255, blue: 255/255), // Alice blue
                    Color(red: 176/255, green: 224/255, blue: 230/255), // Powder blue
                    Color(red: 230/255, green: 230/255, blue: 250/255)  // Lavender
                ]
            } else { // Regular sunny blue sky
                return [
                    Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                    Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
                ]
            }
        case "rainy", "rain", "drizzle":
            return [
                Color(red: 105/255, green: 105/255, blue: 105/255), // Dim gray
                Color(red: 119/255, green: 136/255, blue: 153/255), // Light slate gray
                Color(red: 176/255, green: 196/255, blue: 222/255)  // Light steel blue
            ]
        case "cloudy", "mostly cloudy", "overcast":
            return [
                Color(red: 169/255, green: 169/255, blue: 169/255), // Dark gray
                Color(red: 192/255, green: 192/255, blue: 192/255), // Silver
                Color(red: 211/255, green: 211/255, blue: 211/255)  // Light gray
            ]
        case "partly cloudy":
            return [
                Color(red: 176/255, green: 196/255, blue: 222/255), // Light steel blue
                Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                Color(red: 211/255, green: 211/255, blue: 211/255)  // Light gray
            ]
        case "snowy", "snow", "sleet":
            return [
                Color(red: 240/255, green: 248/255, blue: 255/255), // Alice blue
                Color(red: 176/255, green: 224/255, blue: 230/255), // Powder blue
                Color(red: 230/255, green: 230/255, blue: 250/255)  // Lavender
            ]
        case "hail":
            return [
                Color(red: 190/255, green: 190/255, blue: 190/255), // Gray
                Color(red: 176/255, green: 224/255, blue: 230/255), // Powder blue
                Color(red: 169/255, green: 169/255, blue: 169/255)  // Dark gray
            ]
        case "thunderstorms":
            return [
                Color(red: 75/255, green: 0/255, blue: 130/255),    // Indigo
                Color(red: 72/255, green: 61/255, blue: 139/255),   // Dark slate blue
                Color(red: 128/255, green: 128/255, blue: 128/255)  // Gray
            ]
        case "hazy", "haze":
            return [
                Color(red: 255/255, green: 248/255, blue: 220/255), // Cornsilk
                Color(red: 240/255, green: 230/255, blue: 140/255), // Khaki
                Color(red: 189/255, green: 183/255, blue: 107/255)  // Dark khaki
            ]
        case "smoky":
            return [
                Color(red: 169/255, green: 169/255, blue: 169/255), // Dark gray
                Color(red: 139/255, green: 139/255, blue: 131/255), // Dark gray-brown
                Color(red: 119/255, green: 136/255, blue: 153/255)  // Light slate gray
            ]
        case "breezy", "windy":
            return [
                Color(red: 176/255, green: 196/255, blue: 222/255), // Light steel blue
                Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                Color(red: 230/255, green: 230/255, blue: 250/255)  // Lavender
            ]
        case "hot":
            return [
                Color(red: 255/255, green: 69/255, blue: 0/255),    // Red orange
                Color(red: 255/255, green: 140/255, blue: 0/255),   // Dark orange
                Color(red: 255/255, green: 165/255, blue: 0/255)    // Orange
            ]
        case "frigid", "freezing":
            return [
                Color(red: 240/255, green: 248/255, blue: 255/255), // Alice blue
                Color(red: 176/255, green: 224/255, blue: 230/255), // Powder blue
                Color(red: 230/255, green: 230/255, blue: 250/255)  // Lavender
            ]
        case "misty", "mist", "fog", "foggy":
            return [
                Color(red: 248/255, green: 248/255, blue: 255/255), // Ghost white
                Color(red: 220/255, green: 220/255, blue: 220/255), // Gainsboro
                Color(red: 169/255, green: 169/255, blue: 169/255)  // Dark gray
            ]
        default:
            return defaultGradient()
        }
    }
    
    private static func getTimeOfDay(for date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        switch hour {
        case 5...7:
            return "dawn"
        case 8...11:
            return "morning"
        case 12...16:
            return "afternoon"
        case 17...19:
            return "evening"
        case 20...21:
            return "sunset"
        case 22...23, 0...4:
            return "night"
        default:
            return "day"
        }
    }
    
    private static func defaultGradient() -> [Color] {
        return [
            Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
            Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
        ]
    }
}

// MARK: - Widget Extensions

extension WeatherGradientService {
    
    /// Get weather icon for widget display
    static func getWeatherIcon(for condition: String?) -> String {
        guard let condition = condition else { return "sun.max.fill" }
        
        let conditionLower = condition.lowercased()
        
        switch conditionLower {
        case let c where c.contains("sun") || c.contains("clear"):
            return "sun.max.fill"
        case let c where c.contains("rain"):
            return "cloud.rain.fill"
        case let c where c.contains("drizzle"):
            return "cloud.drizzle.fill"
        case let c where c.contains("cloud"):
            if c.contains("partly") {
                return "cloud.sun.fill"
            } else {
                return "cloud.fill"
            }
        case let c where c.contains("snow"):
            return "snow"
        case let c where c.contains("sleet"):
            return "cloud.sleet.fill"
        case let c where c.contains("hail"):
            return "cloud.hail.fill"
        case let c where c.contains("thunder"):
            return "cloud.bolt.fill"
        case let c where c.contains("fog") || c.contains("mist"):
            return "cloud.fog.fill"
        case let c where c.contains("wind") || c.contains("breezy"):
            return "wind"
        case let c where c.contains("hot"):
            return "thermometer.sun.fill"
        case let c where c.contains("frigid") || c.contains("freezing"):
            return "thermometer.snowflake"
        case let c where c.contains("haze") || c.contains("smoky"):
            return "sun.haze.fill"
        default:
            return "sun.max.fill"
        }
    }
    
    /// Get icon color based on weather condition and time of day
    static func getIconColor(for condition: String?, timeOfDay: String? = nil) -> Color {
        guard let condition = condition else { return .white }
        
        let conditionLower = condition.lowercased()
        let time = timeOfDay ?? getTimeOfDay(for: Date())
        
        // Time-specific colors
        switch time {
        case "dawn":
            return Color(red: 255/255, green: 204/255, blue: 128/255) // Light peach
        case "sunset", "evening":
            return Color(red: 255/255, green: 206/255, blue: 84/255) // Golden yellow
        case "night":
            return Color(red: 200/255, green: 200/255, blue: 220/255) // Light purple-gray
        default:
            break
        }
        
        // Weather-specific colors
        switch conditionLower {
        case let c where c.contains("sun") || c.contains("clear"):
            return Color(red: 255/255, green: 223/255, blue: 0/255) // Golden
        case let c where c.contains("rain") || c.contains("drizzle"):
            return Color(red: 176/255, green: 196/255, blue: 222/255) // Light steel blue
        case let c where c.contains("snow"):
            return Color.white
        case let c where c.contains("thunder"):
            return Color(red: 255/255, green: 255/255, blue: 0/255) // Electric yellow
        default:
            return Color.white
        }
    }
}