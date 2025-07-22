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
        
        // Night gradients
        if timeOfDay == "night" {
            return [
                Color(red: 25/255, green: 25/255, blue: 45/255),
                Color(red: 15/255, green: 15/255, blue: 35/255)
            ]
        }
        
        // Dawn gradients
        if timeOfDay == "dawn" {
            return [
                Color(red: 255/255, green: 183/255, blue: 107/255),
                Color(red: 255/255, green: 138/255, blue: 101/255)
            ]
        }
        
        // Sunset gradients
        if timeOfDay == "sunset" || timeOfDay == "evening" {
            return [
                Color(red: 255/255, green: 154/255, blue: 158/255),
                Color(red: 250/255, green: 208/255, blue: 196/255)
            ]
        }
        
        // Weather-based gradients for day/morning/afternoon
        switch conditionLower {
        case let condition where condition.contains("rain") || condition.contains("storm"):
            return [
                Color(red: 107/255, green: 114/255, blue: 128/255),
                Color(red: 75/255, green: 85/255, blue: 99/255)
            ]
        case let condition where condition.contains("cloud"):
            return [
                Color(red: 156/255, green: 163/255, blue: 175/255),
                Color(red: 107/255, green: 114/255, blue: 128/255)
            ]
        case let condition where condition.contains("snow") || condition.contains("frost"):
            return [
                Color(red: 219/255, green: 234/255, blue: 254/255),
                Color(red: 147/255, green: 197/255, blue: 253/255)
            ]
        case let condition where condition.contains("fog") || condition.contains("mist"):
            return [
                Color(red: 229/255, green: 231/255, blue: 235/255),
                Color(red: 156/255, green: 163/255, blue: 175/255)
            ]
        default:
            // Clear/sunny conditions - temperature dependent
            if temperature > 30 {
                // Hot orange gradient
                return [
                    Color(red: 251/255, green: 146/255, blue: 60/255),
                    Color(red: 234/255, green: 88/255, blue: 12/255)
                ]
            } else if temperature < 0 {
                // Icy gradient
                return [
                    Color(red: 219/255, green: 234/255, blue: 254/255),
                    Color(red: 147/255, green: 197/255, blue: 253/255)
                ]
            } else {
                // Normal sunny blue sky
                return [
                    Color(red: 147/255, green: 197/255, blue: 253/255),
                    Color(red: 59/255, green: 130/255, blue: 246/255)
                ]
            }
        }
    }
    
    // Weather icon selection
    private func getWeatherIcon(for condition: String) -> String {
        let conditionLower = condition.lowercased()
        
        switch conditionLower {
        case let c where c.contains("sun") || c.contains("clear"):
            return "sun.max.fill"
        case let c where c.contains("rain"):
            return "cloud.rain.fill"
        case let c where c.contains("cloud"):
            return "cloud.fill"
        case let c where c.contains("snow"):
            return "snow"
        case let c where c.contains("fog") || c.contains("mist"):
            return "cloud.fog.fill"
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