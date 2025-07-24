import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    
    private let baseURL = "https://api.openai.com/v1/images/generations"
    private let chatCompletionURL = "https://api.openai.com/v1/chat/completions"
    
    struct ImageGenerationRequest: Encodable {
        let prompt: String
        let model: String = "dall-e-3"
        let n: Int = 1
        let size: String = "1024x1024"
        let quality: String = "standard"
        let response_format: String = "url"
    }
    
    struct ImageGenerationResponse: Decodable {
        let created: Int
        let data: [ImageData]
    }
    
    struct ImageData: Decodable {
        let url: String
        let revised_prompt: String?
    }
    
    struct ChatCompletionRequest: Encodable {
        let model: String
        let messages: [Message]
        let temperature: Double
        let response_format: ResponseFormat?
        
        struct Message: Encodable {
            let role: String
            let content: String
        }
        
        struct ResponseFormat: Encodable {
            let type: String = "json_object"
        }
    }
    
    struct ChatCompletionResponse: Decodable {
        let choices: [Choice]
        
        struct Choice: Decodable {
            let message: Message
            
            struct Message: Decodable {
                let content: String
            }
        }
    }
    
    enum OpenAIError: Error, LocalizedError {
        case invalidAPIKey
        case invalidURL
        case noImageGenerated
        case noNameGenerated
        case networkError(String)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid or missing OpenAI API key"
            case .invalidURL:
                return "Invalid URL"
            case .noImageGenerated:
                return "No image was generated"
            case .noNameGenerated:
                return "No name was generated"
            case .networkError(let message):
                return "Network error: \(message)"
            case .invalidResponse:
                return "Invalid response from API"
            }
        }
    }
    
    func generateFlowerImage(species: BotanicalSpecies) async throws -> (UIImage, String) {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        // Build botanically accurate prompt using real species data
        let prompt = "ISOLATED on PLAIN WHITE BACKGROUND, \(species.imagePrompt), NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, scientific botanical illustration style, accurate botanical details, realistic flower structure, proper petal arrangement, SOFT NATURAL COLORS, light and delicate tones, NO OVERSATURATED COLORS, gentle pastel hues where appropriate, botanical accuracy, professional scientific illustration, COMPLETELY WHITE BACKGROUND, isolated subject, educational botanical art, highly detailed, 4K"
        
        return try await generateFlowerImageWithPrompt(prompt)
    }
    
    // Legacy method for compatibility with onboarding and custom flowers
    func generateFlowerImage(descriptor: String) async throws -> (UIImage, String) {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        // Build the prompt using the original structure
        let prompt = "ISOLATED on PLAIN WHITE BACKGROUND, a single \(descriptor) flower, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stem with leaves, dreamy and ethereal, VERY SOFT PASTEL COLORS, light and airy palette, muted gentle tones, subtle gradients, NO BRIGHT OR VIVID COLORS, pale delicate hues only, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K"
        
        return try await generateFlowerImageWithPrompt(prompt)
    }
    
    // Shared implementation
    private func generateFlowerImageWithPrompt(_ prompt: String) async throws -> (UIImage, String) {
        let request = ImageGenerationRequest(prompt: prompt)
        
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(APIConfiguration.shared.effectiveOpenAIKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.networkError(message)
            }
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let generationResponse = try decoder.decode(ImageGenerationResponse.self, from: data)
        
        guard let imageData = generationResponse.data.first,
              let imageURL = URL(string: imageData.url) else {
            throw OpenAIError.noImageGenerated
        }
        
        // Download the image
        let (imageDataResponse, _) = try await URLSession.shared.data(from: imageURL)
        
        guard let image = UIImage(data: imageDataResponse) else {
            throw OpenAIError.noImageGenerated
        }
        
        return (image, imageData.revised_prompt ?? prompt)
    }
    
    func generateFlowerDetails(for flower: AIFlower, species: BotanicalSpecies? = nil, context: FlowerContext? = nil) async throws -> FlowerDetails {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        // Get current date context
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let currentDate = dateFormatter.string(from: Date())
        
        let season = getCurrentSeason()
        
        let systemPrompt: String
        if flower.isBouquet {
            systemPrompt = """
            You are a passionate florist who loves creating magical bouquets and sharing the beautiful stories behind holiday flower traditions.
            You must respond with a valid JSON object with exactly these fields:
            {
                "meaning": "What this bouquet means for the holiday - include touching stories about why people give these flowers, emotional connections, and heartwarming traditions (write 3-4 sentences in warm, storytelling style)",
                "properties": "How these flowers work together beautifully - describe the colors, textures, fragrances, and why they're perfect together (write 3-4 sentences in descriptive, enthusiastic tone)",
                "origins": "The fascinating history of this holiday flower tradition - include interesting cultural stories and how it spread around the world (write 3-4 sentences like sharing holiday folklore)",
                "detailedDescription": "Paint a picture of this stunning bouquet - describe its visual impact, the emotions it evokes, and what makes it so special for this celebration (write 4-5 sentences in vivid, emotional language)",
                "continent": "One of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica"
            }
            
            IMPORTANT:
            - Write in warm, enthusiastic language that captures the magic of holidays
            - Make each section longer and more emotionally engaging (3-5 sentences each)
            - Include heartwarming stories and cultural traditions
            - Focus on the emotional impact and celebration aspect
            - Write like you're sharing beloved holiday stories with a friend
            """
        } else {
            systemPrompt = """
            You are an enthusiastic botanist who loves sharing fascinating stories about flowers and plants in a casual, engaging way.
            You must respond with a valid JSON object with exactly these fields:
            {
                "meaning": "What this flower means to people and cultures - include interesting stories, folklore, and emotional connections (write 3-4 sentences in casual, storytelling style)",
                "properties": "Cool characteristics and how it grows - what makes it special, unique traits, interesting behaviors (write 3-4 sentences in conversational tone, avoid scientific jargon)",
                "origins": "Where it comes from and its journey around the world - include interesting historical stories about how it spread (write 3-4 sentences like you're telling a friend)",
                "detailedDescription": "Paint a vivid picture of this flower - describe its beauty, colors, textures, and what it's like to encounter it in real life (write 4-5 sentences in descriptive, engaging language)",
                "continent": "One of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica"
            }
            
            IMPORTANT: 
            - Write in casual, friendly language like you're talking to a friend
            - Make each section longer and more engaging (3-5 sentences each)
            - Include interesting stories, folklore, and fun facts
            - Avoid technical scientific terminology
            - Focus on what makes this flower special and fascinating
            - Be accurate but write in an accessible, storytelling style
            """
        }
        
        var userPrompt: String
        if flower.isBouquet {
            var flowerList = ""
            if let bouquetFlowers = flower.bouquetFlowers {
                flowerList = bouquetFlowers.joined(separator: ", ")
            }
            
            userPrompt = """
            Generate detailed information for a holiday bouquet called "\(flower.name)" for \(flower.holidayName ?? "a special occasion").
            The bouquet contains: \(flowerList)
            
            Remember to:
            1. Explain the holiday significance and why these specific flowers were chosen
            2. Describe how the flowers work together visually and symbolically
            3. Include cultural traditions around giving flowers for this holiday
            4. Create a rich, emotional description of the bouquet arrangement
            5. Choose the continent where this holiday tradition is strongest
            """
        } else if let botanicalSpecies = species {
            // Use real botanical data for accurate information
            userPrompt = """
            Generate detailed information about the real botanical species \(botanicalSpecies.scientificName) (\(botanicalSpecies.primaryCommonName)).
            
            Scientific Information:
            - Scientific name: \(botanicalSpecies.scientificName)
            - Common names: \(botanicalSpecies.commonNames.joined(separator: ", "))
            - Family: \(botanicalSpecies.family)
            - Native regions: \(botanicalSpecies.nativeRegions.joined(separator: ", "))
            - Blooming season: \(botanicalSpecies.bloomingSeason)
            - Conservation status: \(botanicalSpecies.conservationStatus)
            - Uses: \(botanicalSpecies.uses.joined(separator: ", "))
            - Habitat: \(botanicalSpecies.habitat)
            
            Interesting facts to incorporate:
            \(botanicalSpecies.interestingFacts.joined(separator: "\n"))
            
            Remember to:
            1. Use ONLY accurate, factual information about this real species
            2. Include cultural and symbolic significance based on actual history
            3. Describe true botanical characteristics and properties
            4. Mention actual geographic origins and native regions
            5. Set continent to: \(botanicalSpecies.primaryContinent.rawValue)
            6. Create educational, informative content that teaches users about real botany
            """
        } else {
            // Fallback for flowers without botanical species data
            userPrompt = """
            Generate detailed botanical information for a flower called "\(flower.name)" which is described as "\(flower.descriptor)".
            Remember to:
            1. Include cultural significance in the meaning field
            2. Focus on botanical characteristics in the properties field
            3. Describe geographic origins in the origins field
            4. Create a rich description considering it's currently \(season)
            5. Choose the most appropriate continent from the exact list
            """
        }
        
        // Add contextual information if available
        if flower.contextualGeneration, let context = flower.generationContext {
            userPrompt += """
            
            
            CONTEXTUAL DISCOVERY: This flower appeared specifically because of current conditions:
            - Location context: \(context)
            - Current date: \(currentDate) 
            - Season: \(season)
            - Weather: \(flower.discoveryWeatherCondition ?? "Unknown")
            - Location: \(flower.discoveryLocationName ?? "Unknown location")
            
            IMPORTANT: In each section, explain WHY this flower is appearing right now:
            - In "meaning": Connect the cultural significance to the current time/season/location and weather
            - In "properties": Explain why this flower blooms or thrives in these exact current conditions (weather, season, location)
            - In "origins": Tell the story of how this flower came to be in this specific region and why it's perfect for today's weather
            - In "detailedDescription": Describe what makes encountering this flower special RIGHT NOW in this place, time, weather, and season
            
            Make it feel like a magical, perfectly-timed discovery that could only happen today in these exact conditions!
            """
        }
        
        let request = ChatCompletionRequest(
            model: "gpt-4.1-nano-2025-04-14",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                ChatCompletionRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.8,
            response_format: ChatCompletionRequest.ResponseFormat()
        )
        
        guard let url = URL(string: chatCompletionURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.networkError(message)
            }
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        guard let content = completionResponse.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        // Clean the content to ensure it's valid JSON
        let cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanedContent.data(using: .utf8) else {
            throw OpenAIError.invalidResponse
        }
        
        do {
            let flowerDetails = try JSONDecoder().decode(FlowerDetails.self, from: jsonData)
            return flowerDetails
        } catch {
            // If JSON parsing fails, try to extract the content and create a valid response
            print("JSON parsing error: \(error)")
            print("Raw content: \(cleanedContent)")
            
            // Create a fallback response
            return FlowerDetails(
                meaning: "This beautiful flower represents resilience and natural beauty.",
                properties: "A remarkable specimen with unique petal formations and vibrant colors.",
                origins: "Found in diverse habitats across temperate regions.",
                detailedDescription: "A stunning flower that blooms during \(season), showcasing nature's artistry.",
                continent: "North America"
            )
        }
    }
    
    func generateFlowerName(species: BotanicalSpecies, context: FlowerContext? = nil) -> String {
        // For real botanical species, use the actual common name
        // Optionally add contextual prefixes for variety
        let baseName = species.primaryCommonName
        
        // 70% chance to use the standard name, 30% chance to add contextual prefix
        if Int.random(in: 1...10) <= 7 {
            return baseName
        }
        
        // Add contextual prefix based on location or season
        var contextualPrefix: String?
        
        if let city = context?.city, Int.random(in: 1...3) == 1 {
            contextualPrefix = city
        } else if let season = context?.season, Int.random(in: 1...3) == 1 {
            contextualPrefix = season
        } else if let timeOfDay = context?.timeOfDay, Int.random(in: 1...4) == 1 {
            let timeMap = [
                "morning": "Dawn",
                "evening": "Sunset", 
                "night": "Moonlit"
            ]
            contextualPrefix = timeMap[timeOfDay]
        }
        
        if let prefix = contextualPrefix {
            return "\(prefix) \(baseName)"
        }
        
        return baseName
    }
    
    // Legacy method for compatibility with existing code
    func generateFlowerNameLegacy(descriptor: String, existingNames: Set<String> = [], context: FlowerContext? = nil) async throws -> String {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        // Generate contextual names based on location and time
        let systemPrompt = """
        You are a creative botanist who creates poetic names for real flower species.
        Names should sound authentic and relate to the context provided.
        Examples: "London Morning Rose", "Barcelona Sunset Orchid", "Alpine Spring Lily"
        Respond with just the flower name, nothing else.
        The name should be 2-4 words and sound like a real cultivar name.
        """
        
        var contextElements: [String] = []
        
        // Add context-specific information
        if let city = context?.city {
            contextElements.append("City: \(city)")
        }
        if let country = context?.country {
            contextElements.append("Country: \(country)")
        }
        if let season = context?.season {
            contextElements.append("Season: \(season)")
        }
        if let timeOfDay = context?.timeOfDay {
            contextElements.append("Time: \(timeOfDay)")
        }
        
        // Add current date context
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let currentDate = dateFormatter.string(from: Date())
        contextElements.append("Date: \(currentDate)")
        
        var userPrompt = """
        Create a beautiful name for a flower described as: \(descriptor)
        
        Context:
        \(contextElements.joined(separator: "\n"))
        
        The name should relate to the context and sound like a real flower variety name.
        """
        
        if !existingNames.isEmpty {
            userPrompt += """
            
            
            CRITICAL: The name must NOT be any of these already used names:
            \(existingNames.sorted().joined(separator: ", "))
            
            Be creative and generate a completely different, unique name.
            """
        }
        
        // Try up to 5 times to get a unique name
        for attempt in 0..<5 {
            let request = ChatCompletionRequest(
                model: "gpt-4.1-nano-2025-04-14",
                messages: [
                    ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                    ChatCompletionRequest.Message(role: "user", content: userPrompt)
                ],
                temperature: 0.9 + Double(attempt) * 0.05, // Increase temperature with each attempt for more variety
                response_format: nil
            )
            
            guard let url = URL(string: chatCompletionURL) else {
                throw OpenAIError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.networkError("Invalid response")
            }
            
            if httpResponse.statusCode != 200 {
                throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
            
            guard let name = completionResponse.choices.first?.message.content else {
                throw OpenAIError.invalidResponse
            }
            
            let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if this name is unique
            if !existingNames.contains(cleanedName) {
                return cleanedName
            }
            
            // If we're on the last attempt and still getting duplicates, modify the name
            if attempt == 4 {
                // Add a unique suffix to ensure uniqueness
                let suffixes = ["Aurora", "Nova", "Star", "Crystal", "Dream", "Mystic", "Eternal"]
                let randomSuffix = suffixes.randomElement() ?? "Unique"
                return "\(cleanedName) \(randomSuffix)"
            }
        }
        
        // This should never be reached, but just in case
        return "Unique \(descriptor.capitalized) \(UUID().uuidString.prefix(4))"
    }
    
    func generateJennyFlowerName(descriptor: String, existingNames: Set<String> = []) async throws -> String {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let systemPrompt = """
        You are a botanist who names newly discovered flower species. Create an elegant name that incorporates "Jenny" or relates to the name Jenny.
        Examples: "Jenny's Rose", "Jennifer Lily", "Jenny's Garden Bloom", "Jenniferia elegans".
        The name should sound like it could be a real flower species named after or dedicated to someone named Jenny.
        Respond with just the flower name, nothing else.
        IMPORTANT: The name must be completely unique and not match any existing flower names.
        """
        
        var userPrompt = """
        Create a beautiful flower name that includes or relates to "Jenny" for a flower described as: \(descriptor)
        The name should be 2-4 words maximum and sound elegant and botanical.
        """
        
        if !existingNames.isEmpty {
            userPrompt += """
            
            
            CRITICAL: The name must NOT be any of these already used names:
            \(existingNames.sorted().joined(separator: ", "))
            
            Be creative and generate a completely different, unique Jenny-themed name.
            """
        }
        
        // Try up to 5 times to get a unique name
        for attempt in 0..<5 {
            let request = ChatCompletionRequest(
                model: "gpt-4.1-nano-2025-04-14",
                messages: [
                    ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                    ChatCompletionRequest.Message(role: "user", content: userPrompt)
                ],
                temperature: 0.9 + Double(attempt) * 0.05, // Increase temperature with each attempt
                response_format: nil
            )
            
            guard let url = URL(string: chatCompletionURL) else {
                throw OpenAIError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.networkError("Invalid response")
            }
            
            if httpResponse.statusCode != 200 {
                throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
            
            guard let name = completionResponse.choices.first?.message.content else {
                throw OpenAIError.invalidResponse
            }
            
            let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if this name is unique
            if !existingNames.contains(cleanedName) {
                return cleanedName
            }
            
            // If we're on the last attempt and still getting duplicates, modify the name
            if attempt == 4 {
                // Add a unique Jenny-themed suffix
                let suffixes = ["Jenny's Dream", "Jenny Aurora", "Jennifer Star", "Jenny's Crystal", "Jenny Nova"]
                let randomSuffix = suffixes.randomElement() ?? "Jenny's Unique"
                return "\(randomSuffix) \(descriptor.split(separator: " ").last ?? "Bloom")"
            }
        }
        
        // This should never be reached, but just in case
        return "Jenny's \(descriptor.capitalized) \(UUID().uuidString.prefix(4))"
    }
    
    private func getCurrentSeason() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        
        switch month {
        case 3...5: return "Spring"
        case 6...8: return "Summer"
        case 9...11: return "Autumn"
        case 12, 1, 2: return "Winter"
        default: return "Unknown"
        }
    }
    
    func generateFlowerNotification(flowerName: String, isBouquet: Bool = false, holidayName: String? = nil) async throws -> (title: String, body: String) {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let systemPrompt = """
        You are a notification writer for a flower discovery app. Create simple, engaging push notifications that encourage users to open the app.
        Rules:
        - Mention the flower name ONLY ONCE (either in title OR body, not both)
        - Include a clear call to action that prompts the user to tap/open the app
        - Keep it simple and conversational
        - NO em-dashes or complex punctuation
        - Title: max 30 characters
        - Body: max 80 characters
        - Use emojis sparingly (one per notification max)
        - Vary your messages but keep them action-oriented
        Return a JSON object with "title" and "body" fields.
        """
        
        let userPrompt: String
        if isBouquet, let holiday = holidayName {
            userPrompt = """
            Create a notification for a special \(holiday) bouquet.
            Make it sound exciting and prompt them to see their gift.
            Examples: 
            - Title: "Your \(holiday) gift is here 🎁", Body: "Tap to unwrap your special bouquet"
            - Title: "A surprise awaits!", Body: "Your \(holiday) bouquet is ready to reveal"
            Remember: mention the occasion but focus on the action.
            """
        } else {
            userPrompt = """
            Create a notification for discovering "\(flowerName)".
            Examples:
            - Title: "\(flowerName) has arrived", Body: "Tap to see this beautiful bloom 🌸"
            - Title: "A new flower awaits", Body: "\(flowerName) is ready. Come see!"
            - Title: "Time to discover", Body: "Your \(flowerName) is waiting"
            Remember: mention the flower name only ONCE total.
            """
        }
        
        let request = ChatCompletionRequest(
            model: "gpt-4.1-nano-2025-04-14",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                ChatCompletionRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.9,
            response_format: ChatCompletionRequest.ResponseFormat()
        )
        
        guard let url = URL(string: chatCompletionURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorString = String(data: data, encoding: .utf8) {
                throw OpenAIError.networkError(errorString)
            }
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        guard let messageContent = completionResponse.choices.first?.message.content else {
            throw OpenAIError.noNameGenerated
        }
        
        // Parse the JSON response
        guard let jsonData = messageContent.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: String],
              let title = json["title"],
              let body = json["body"] else {
            // Fallback if parsing fails
            return (
                title: "🌸 \(flowerName) awaits!",
                body: "Your new flower discovery is ready to be revealed."
            )
        }
        
        return (title: title, body: body)
    }
    
    func generateShortDescription(for flower: AIFlower) async throws -> String {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let systemPrompt = """
        You are a botanist who creates concise, beautiful descriptions of flowers for mobile app cards.
        Create a short, elegant description that fits in exactly 2 lines on a mobile screen (approximately 60-80 characters total).
        
        Requirements:
        - Maximum 2 lines of text
        - Approximately 60-80 characters total
        - Sentence case (proper capitalization)
        - Poetic and beautiful language
        - Focus on visual characteristics and essence
        - No technical jargon
        - End with a period
        
        Example good responses:
        "Delicate petals dance in morning light, whispering secrets of spring's gentle embrace."
        "Vibrant blooms herald summer's arrival with bold colors and sweet fragrance."
        """
        
        let userPrompt = """
        Flower name: \(flower.name)
        Original description: \(flower.descriptor)
        
        Create a short, poetic description that captures the essence of this flower in exactly 2 lines.
        """
        
        let request = ChatCompletionRequest(
            model: "gpt-4.1-nano-2025-04-14",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                ChatCompletionRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.7,
            response_format: nil
        )
        
        guard let url = URL(string: chatCompletionURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.networkError(message)
            }
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        guard let shortDescription = completionResponse.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        return shortDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // This method is now deprecated in favor of using real botanical species
    func generateFlowerPrompt() async throws -> String {
        // Return a random species from the botanical database instead of generating fantasy flowers
        let species = BotanicalDatabase.shared.getRandomSpecies()
        return species?.imagePrompt ?? "Rosa damascena damask rose with double pink fragrant flowers, velvety petals, botanical illustration style"
    }
    
    func generateInspirationalQuote() async throws -> String {
        let apiKey = APIConfiguration.shared.effectiveOpenAIKey
        guard !apiKey.isEmpty else {
            // Return random quote from curated collection
            return getRandomCuratedQuote()
        }
        
        guard let url = URL(string: chatCompletionURL) else {
            throw OpenAIError.invalidURL
        }
        
        let prompt = """
        Generate ONE short inspiring quote about flowers, plants, or nature. 
        
        STRICT FORMAT: "[Quote text]" — [Author Name]
        
        Requirements:
        - Real historical figure or well-known author
        - Positive and uplifting
        - Maximum 15 words in the quote
        - About flowers, nature, growth, or beauty
        - NO additional text, explanations, or commentary
        - ONLY the quote and author in the exact format shown
        
        Examples: 
        "Where flowers bloom, so does hope." — Lady Bird Johnson
        "The earth laughs in flowers." — Ralph Waldo Emerson
        """
        
        let request = ChatCompletionRequest(
            model: "gpt-4.1-nano-2025-04-14",
            messages: [
                ChatCompletionRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.5,
            response_format: nil
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.networkError(message)
            }
            throw OpenAIError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        guard let quote = completionResponse.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        let cleanedQuote = quote.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate the format - should contain quotes and an em dash
        if cleanedQuote.contains("\"") && cleanedQuote.contains("—") {
            return cleanedQuote
        } else {
            // If format is wrong, return a fallback quote
            return getRandomCuratedQuote()
        }
    }
    
    private func getRandomCuratedQuote() -> String {
        // Keep track of recently used quotes to avoid immediate repeats
        let recentQuotesKey = "recentQuotes"
        let maxRecentQuotes = 10
        
        var recentQuotes = UserDefaults.standard.stringArray(forKey: recentQuotesKey) ?? []
        
        let quotes = [
            "\"The earth laughs in flowers.\" — Ralph Waldo Emerson",
            "\"Where flowers bloom, so does hope.\" — Lady Bird Johnson", 
            "\"A flower does not think of competing with the flower next to it. It just blooms.\" — Zen Proverb",
            "\"Every flower is a soul blossoming in nature.\" — Gerard De Nerval",
            "\"Happiness held is the seed; happiness shared is the flower.\" — John Harrigan",
            "\"The flower that blooms in adversity is the rarest and most beautiful of all.\" — Walt Disney",
            "\"To plant a garden is to believe in tomorrow.\" — Audrey Hepburn",
            "\"In every walk with nature, one receives far more than they seek.\" — John Muir",
            "\"A garden requires patient labor and attention. Plants and flowers teach us that.\" — Liberty Hyde Bailey",
            "\"The garden suggests there might be a place where we can meet nature halfway.\" — Michael Pollan",
            "\"Flowers always make people better, happier, and more helpful.\" — Luther Burbank",
            "\"A flower cannot blossom without sunshine, and man cannot live without love.\" — Max Muller",
            "\"Nature does not hurry, yet everything is accomplished.\" — Lao Tzu",
            "\"The poetry of the earth is never dead.\" — John Keats",
            "\"In nature, nothing exists alone.\" — Rachel Carson",
            "\"Study nature, love nature, stay close to nature. It will never fail you.\" — Frank Lloyd Wright",
            "\"The clearest way into the Universe is through a forest wilderness.\" — John Muir",
            "\"Look deep into nature, and then you will understand everything better.\" — Albert Einstein",
            "\"Nature is not a place to visit. It is home.\" — Terry Tempest Williams",
            "\"Heaven is under our feet as well as over our heads.\" — Henry David Thoreau",
            "\"All flowers in time bend towards the sun.\" — Jeff Buckley",
            "\"A rose by any other name would smell as sweet.\" — William Shakespeare",
            "\"Let us dance in the sun, wearing wild flowers in our hair.\" — Susan Polis Schutz",
            "\"The flower which is single need not envy the thorns that are numerous.\" — Rabindranath Tagore",
            "\"Like wildflowers, you must allow yourself to grow in all the places people thought you never would.\" — E.V.",
            "\"Be like a flower and turn your face to the sun.\" — Kahlil Gibran",
            "\"A beautiful flower does not exist. There's only a moment when a flower looks beautiful.\" — Taigu Ryokan",
            "\"If you tend to a flower, it will bloom, no matter how many weeds surround it.\" — Matshona Dhliwayo",
            "\"Flowers are the music of the ground from earth's lips spoken without sound.\" — Edwin Curran",
            "\"A single flower he sent me, since we met. All tenderly his messenger he chose.\" — Jean Ingelow",
            "\"What is a weed? A plant whose virtues have not yet been discovered.\" — Ralph Waldo Emerson",
            "\"The flower doesn't dream of the bee. It blossoms and the bee comes.\" — Mark Nepo",
            "\"Weeds are flowers too, once you get to know them.\" — A.A. Milne",
            "\"I must have flowers, always, and always.\" — Claude Monet",
            "\"Love is the flower you've got to let grow.\" — John Lennon",
            "\"A flower's fragrance declares to all the world that it is fertile, available, and desirable.\" — James Redfield",
            "\"Plants give us oxygen for the lungs and for the soul.\" — Terri Guillemets",
            "\"Gardens require patient labor and attention. Plants teach us about growth and renewal.\" — Unknown",
            "\"The blossom cannot tell what becomes of its odor, and no person can tell what becomes of their influence.\" — Henry Ward Beecher",
            "\"A society grows great when old men plant trees whose shade they know they shall never sit in.\" — Greek Proverb",
            "\"The best time to plant a tree was 20 years ago. The second best time is now.\" — Chinese Proverb",
            "\"In the garden of memory, in the palace of dreams, that is where you and I shall meet.\" — Alice Through the Looking Glass",
            "\"The glory of gardening: hands in the dirt, head in the sun, heart with nature.\" — Alfred Austin",
            "\"A garden is a grand teacher. It teaches patience and careful watchfulness.\" — Gertrude Jekyll",
            "\"Show me your garden and I shall tell you what you are.\" — Alfred Austin",
            "\"The love of gardening is a seed once sown that never dies.\" — Gertrude Jekyll",
            "\"There are no gardening mistakes, only experiments.\" — Janet Kilburn Phillips",
            "\"Gardening is the art that uses flowers and plants as paint, and the soil and sky as canvas.\" — Elizabeth Murray",
            "\"A garden is a friend you can visit anytime.\" — Unknown",
            "\"In the spring, at the end of the day, you should smell like dirt.\" — Margaret Atwood",
            "\"The best fertilizer is the gardener's footsteps.\" — Unknown",
            "\"Plant seeds of happiness, hope, success, and love; it will all come back to you in abundance.\" — Steve Maraboli",
            "\"Like people, plants respond to care.\" — Liberty Hyde Bailey",
            "\"A flower is an educated weed.\" — Luther Burbank",
            "\"The garden is growth and change and that means loss as well as constant new treasures.\" — May Sarton",
            "\"Gardens are not made by singing 'Oh, how beautiful,' and sitting in the shade.\" — Rudyard Kipling",
            "\"Everything that slows us down and forces patience, everything that sets us back into the slow circles of nature, is a help.\" — May Sarton",
            "\"Nature is painting for us, day after day, pictures of infinite beauty.\" — John Ruskin",
            "\"Spring is nature's way of saying, 'Let's party!'\" — Robin Williams",
            "\"Adopt the pace of nature: her secret is patience.\" — Ralph Waldo Emerson",
            "\"Nature always wears the colors of the spirit.\" — Ralph Waldo Emerson",
            "\"Earth and sky, woods and fields, lakes and rivers, the mountain and the sea, are excellent schoolmasters.\" — John Lubbock"
        ]
        
        // Filter out recently used quotes
        let availableQuotes = quotes.filter { !recentQuotes.contains($0) }
        
        // If we've used too many quotes recently, reset the recent list
        let quotesToChooseFrom = availableQuotes.isEmpty ? quotes : availableQuotes
        
        // Select a random quote from available ones
        let selectedQuote = quotesToChooseFrom.randomElement() ?? "\"The earth laughs in flowers.\" — Ralph Waldo Emerson"
        
        // Add to recent quotes list
        recentQuotes.append(selectedQuote)
        
        // Keep only the most recent quotes
        if recentQuotes.count > maxRecentQuotes {
            recentQuotes = Array(recentQuotes.suffix(maxRecentQuotes))
        }
        
        // Save back to UserDefaults
        UserDefaults.standard.set(recentQuotes, forKey: recentQuotesKey)
        
        return selectedQuote
    }
    
    private func getTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<9: return "Dawn"
        case 9..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<20: return "Evening"
        case 20..<23: return "Twilight"
        default: return "Night"
        }
    }
} 