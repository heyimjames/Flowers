import SwiftUI

struct WeatherComponentTestSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Sample weather data for testing
    private let weatherVariations: [WeatherTestData] = [
        // Sunny variations
        WeatherTestData(
            title: "Sunny Day - Morning",
            condition: "Sunny",
            temperature: 22.0,
            unit: "°C",
            location: "London, United Kingdom",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            icon: "sun.max.fill"
        ),
        WeatherTestData(
            title: "Hot Summer Day",
            condition: "Clear",
            temperature: 35.0,
            unit: "°C",
            location: "Phoenix, Arizona",
            date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
            icon: "sun.max.fill"
        ),
        WeatherTestData(
            title: "Sunset Discovery",
            condition: "Clear",
            temperature: 18.0,
            unit: "°C",
            location: "Santorini, Greece",
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            icon: "sun.max.fill"
        ),
        
        // Dawn variations
        WeatherTestData(
            title: "Dawn Bloom",
            condition: "Clear",
            temperature: 12.0,
            unit: "°C",
            location: "Tokyo, Japan",
            date: Calendar.current.date(byAdding: .hour, value: -10, to: Date()) ?? Date(),
            icon: "sunrise.fill"
        ),
        
        // Cloudy variations
        WeatherTestData(
            title: "Overcast Day",
            condition: "Cloudy",
            temperature: 16.0,
            unit: "°C",
            location: "Edinburgh, Scotland",
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            icon: "cloud.fill"
        ),
        WeatherTestData(
            title: "Partly Cloudy",
            condition: "Partly Cloudy",
            temperature: 20.0,
            unit: "°C",
            location: "San Francisco, USA",
            date: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
            icon: "cloud.sun.fill"
        ),
        
        // Rainy variations
        WeatherTestData(
            title: "Light Rain",
            condition: "Rainy",
            temperature: 14.0,
            unit: "°C",
            location: "Seattle, Washington",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            icon: "cloud.rain.fill"
        ),
        WeatherTestData(
            title: "Heavy Downpour",
            condition: "Rain",
            temperature: 9.0,
            unit: "°C",
            location: "Vancouver, Canada",
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            icon: "cloud.heavyrain.fill"
        ),
        
        // Cold/Icy variations
        WeatherTestData(
            title: "Winter Frost",
            condition: "Clear",
            temperature: -2.0,
            unit: "°C",
            location: "Reykjavik, Iceland",
            date: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
            icon: "snowflake"
        ),
        WeatherTestData(
            title: "Snowy Morning",
            condition: "Snow",
            temperature: -5.0,
            unit: "°C",
            location: "Stockholm, Sweden",
            date: Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date(),
            icon: "snow"
        ),
        
        // Night variations
        WeatherTestData(
            title: "Clear Night",
            condition: "Clear",
            temperature: 8.0,
            unit: "°C",
            location: "Paris, France",
            date: Calendar.current.date(byAdding: .hour, value: -12, to: Date()) ?? Date(),
            icon: "moon.stars.fill"
        ),
        WeatherTestData(
            title: "Misty Night",
            condition: "Foggy",
            temperature: 11.0,
            unit: "°C",
            location: "San Francisco, USA",
            date: Calendar.current.date(byAdding: .hour, value: -14, to: Date()) ?? Date(),
            icon: "cloud.fog.fill"
        ),
        
        // Additional weather conditions
        WeatherTestData(
            title: "Heat Wave Day",
            condition: "Hot",
            temperature: 38.0,
            unit: "°C",
            location: "Phoenix, Arizona",
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            icon: "sun.max.fill"
        ),
        WeatherTestData(
            title: "Hazy Morning",
            condition: "Hazy",
            temperature: 26.0,
            unit: "°C",
            location: "Los Angeles, USA",
            date: Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date(),
            icon: "sun.haze.fill"
        ),
        WeatherTestData(
            title: "Windy Afternoon",
            condition: "Windy",
            temperature: 18.0,
            unit: "°C",
            location: "Chicago, USA",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            icon: "wind"
        ),
        WeatherTestData(
            title: "Freezing Cold",
            condition: "Frigid",
            temperature: -15.0,
            unit: "°C",
            location: "Anchorage, Alaska",
            date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
            icon: "thermometer.snowflake"
        ),
        WeatherTestData(
            title: "Thunderstorm",
            condition: "Thunderstorms",
            temperature: 22.0,
            unit: "°C",
            location: "Miami, Florida",
            date: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
            icon: "cloud.bolt.rain.fill"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Weather Components")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .foregroundColor(.flowerTextPrimary)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.flowerPrimary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Description
                Text("Test different weather component variations with various conditions, temperatures, and times of day.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(Array(weatherVariations.enumerated()), id: \.offset) { index, weatherData in
                            WeatherTestCard(weatherData: weatherData, index: index)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.flowerSheetBackground)
        }
    }
}

struct WeatherTestData {
    let title: String
    let condition: String
    let temperature: Double
    let unit: String
    let location: String
    let date: Date
    let icon: String
}

struct WeatherTestCard: View {
    let weatherData: WeatherTestData
    let index: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Title above the component
            Text(weatherData.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.flowerTextPrimary)
                .multilineTextAlignment(.center)
            
            // Weather Component (exact match to onboarding)
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weatherData.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(weatherData.location)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: getWeatherIcon(for: weatherData.condition))
                                .font(.system(size: 24))
                                .foregroundColor(getIconColor(for: weatherData.condition, timeOfDay: getTimeOfDay(for: weatherData.date)))
                            
                            Text("\(Int(weatherData.temperature))°\(weatherData.unit.replacingOccurrences(of: "°", with: ""))")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text(weatherData.condition)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                HStack {
                    Image(systemName: "flower.fill")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(getWeatherMessage(for: weatherData.condition, temperature: weatherData.temperature))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: getContextualWeatherGradient(
                        condition: weatherData.condition,
                        temperature: weatherData.temperature,
                        timeOfDay: getTimeOfDay(for: weatherData.date)
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .frame(maxWidth: 300)
        }
    }
    
    // Time of day calculation
    private func getTimeOfDay(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 5..<7:
            return "dawn"
        case 7..<10:
            return "morning"
        case 10..<16:
            return "day"
        case 16..<19:
            return "afternoon"
        case 19..<21:
            return "sunset"
        case 21..<23:
            return "evening"
        default:
            return "night"
        }
    }
    
    // Contextual weather gradients
    private func getContextualWeatherGradient(condition: String, temperature: Double, timeOfDay: String) -> [Color] {
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
        case "foggy", "fog", "misty", "mist":
            return [
                Color(red: 220/255, green: 220/255, blue: 220/255), // Gainsboro
                Color(red: 192/255, green: 192/255, blue: 192/255), // Silver
                Color(red: 176/255, green: 196/255, blue: 222/255)  // Light steel blue
            ]
        case "breezy", "windy":
            return [
                Color(red: 176/255, green: 196/255, blue: 222/255), // Light steel blue
                Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
            ]
        case "hot":
            return [
                Color(red: 255/255, green: 69/255, blue: 0/255),    // Red orange
                Color(red: 255/255, green: 140/255, blue: 0/255),   // Dark orange
                Color(red: 255/255, green: 165/255, blue: 0/255)    // Orange
            ]
        case "frigid":
            return [
                Color(red: 230/255, green: 240/255, blue: 255/255), // Very light blue
                Color(red: 176/255, green: 224/255, blue: 230/255), // Powder blue
                Color(red: 175/255, green: 238/255, blue: 238/255)  // Pale turquoise
            ]
        default:
            // Default gradient - pleasant blue sky
            return [
                Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
            ]
        }
    }
    
    // Weather icon selection
    private func getWeatherIcon(for condition: String) -> String {
        let conditionLower = condition.lowercased()
        
        switch conditionLower {
        case "sunny", "clear":
            return "sun.max.fill"
        case "hot":
            return "thermometer.sun.fill"
        case "rainy", "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "cloudy", "mostly cloudy":
            return "cloud.fill"
        case "partly cloudy":
            return "cloud.sun.fill"
        case "snowy", "snow":
            return "snow"
        case "sleet":
            return "cloud.sleet.fill"
        case "hail":
            return "cloud.hail.fill"
        case "thunderstorms":
            return "cloud.bolt.rain.fill"
        case "hazy", "haze":
            return "sun.haze.fill"
        case "smoky":
            return "smoke.fill"
        case "foggy", "fog", "misty", "mist":
            return "cloud.fog.fill"
        case "breezy":
            return "wind"
        case "windy":
            return "wind"
        case "frigid":
            return "thermometer.snowflake"
        default:
            return "sun.max.fill"
        }
    }
    
    // Weather icon color based on condition and time
    private func getIconColor(for condition: String, timeOfDay: String) -> Color {
        let conditionLower = condition.lowercased()
        
        if timeOfDay == "night" {
            return .white
        }
        
        switch conditionLower {
        case let c where c.contains("sun") || c.contains("clear"):
            return .yellow
        case let c where c.contains("rain"):
            return .white
        case let c where c.contains("cloud"):
            return .white.opacity(0.8)
        case let c where c.contains("snow"):
            return .white
        default:
            return .yellow
        }
    }
    
    // Weather messages
    private func getWeatherMessage(for condition: String, temperature: Double) -> String {
        let conditionLower = condition.lowercased()
        
        if temperature > 30 {
            return "Perfect weather for vibrant blooms"
        } else if temperature < 0 {
            return "Hardy flowers thrive in winter"
        } else if conditionLower.contains("rain") {
            return "Rain nourishes new growth"
        } else if conditionLower.contains("cloud") {
            return "Gentle light for delicate petals"
        } else if conditionLower.contains("snow") {
            return "Winter wonderland discovery"
        } else {
            return "Perfect weather for picking flowers"
        }
    }
}

#Preview {
    WeatherComponentTestSheet()
}