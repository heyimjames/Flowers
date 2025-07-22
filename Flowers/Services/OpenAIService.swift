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
            You are a knowledgeable florist and botanist who creates detailed information about beautiful flower bouquets for special occasions.
            You must respond with a valid JSON object with exactly these fields:
            {
                "meaning": "Cultural significance and symbolism of this bouquet arrangement for the holiday",
                "properties": "Description of the flowers included and how they complement each other",
                "origins": "Traditional and cultural history of giving these flowers for this occasion",
                "detailedDescription": "Rich description of the bouquet's appearance, arrangement, and emotional impact",
                "continent": "One of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica"
            }
            Make the information culturally relevant and emotionally resonant for the holiday.
            The continent should reflect where this holiday tradition is most celebrated.
            """
        } else {
            systemPrompt = """
            You are a knowledgeable botanist and naturalist who provides accurate, educational information about real botanical species.
            You must respond with a valid JSON object with exactly these fields:
            {
                "meaning": "Cultural and symbolic significance of this species",
                "properties": "Accurate botanical characteristics and growth patterns",
                "origins": "True geographic origins and natural habitat",
                "detailedDescription": "Rich, accurate description of appearance and botanical features",
                "continent": "One of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica"
            }
            IMPORTANT: Provide only factually accurate information about real botanical species.
            Include scientific details, conservation status, and educational content.
            Ensure the continent field EXACTLY matches one of the seven options provided.
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
            
            
            This flower was inspired by real-world context: \(context).
            Please incorporate relevant cultural, geographical, or seasonal elements into the description while maintaining botanical plausibility.
            """
        }
        
        let request = ChatCompletionRequest(
            model: "gpt-4o-mini",
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
                model: "gpt-4o-mini",
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
                model: "gpt-4o-mini",
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
            model: "gpt-4o-mini",
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
            model: "gpt-3.5-turbo",
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