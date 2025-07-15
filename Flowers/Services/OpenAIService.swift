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
    
    func generateFlowerImage(descriptor: String) async throws -> (UIImage, String) {
        guard !APIConfiguration.shared.openAIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let apiKey = APIConfiguration.shared.openAIKey
        
        // Build the prompt using the consistent structure from PRD
        let prompt = "A single \(descriptor) flower, botanical illustration style, centered on pure white background, soft watercolor texture, delicate petals, elegant stem with leaves, dreamy and ethereal, pastel colors with subtle gradients, professional botanical art, highly detailed, 4K"
        
        let request = ImageGenerationRequest(prompt: prompt)
        
        guard let url = URL(string: baseURL) else {
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
    
    func generateFlowerDetails(for flower: AIFlower, context: FlowerContext? = nil) async throws -> FlowerDetails {
        guard !APIConfiguration.shared.openAIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let apiKey = APIConfiguration.shared.openAIKey
        
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
            You are a knowledgeable botanist and naturalist who creates detailed information about rare and beautiful flowers. 
            You must respond with a valid JSON object with exactly these fields:
            {
                "meaning": "Cultural and symbolic significance of this flower",
                "properties": "Notable botanical characteristics and growth patterns",
                "origins": "Geographic origins and natural habitat",
                "detailedDescription": "Rich description of appearance and growth",
                "continent": "One of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica"
            }
            Make the information scientifically plausible yet poetic. Include seasonal context when relevant.
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
        } else {
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
    
    func generateFlowerName(descriptor: String) async throws -> String {
        guard !APIConfiguration.shared.openAIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let apiKey = APIConfiguration.shared.openAIKey
        
        let systemPrompt = """
        You are a botanist who names newly discovered flower species. Create elegant, scientifically-plausible names 
        that sound like they could be real flowers. Use combinations of Latin, Greek roots, or poetic English names.
        Respond with just the flower name, nothing else.
        """
        
        let userPrompt = """
        Create a beautiful name for a flower described as: \(descriptor)
        The name should be 2-3 words maximum and sound like it could be a real flower species.
        """
        
        let request = ChatCompletionRequest(
            model: "gpt-4o-mini",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                ChatCompletionRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.9,
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
        
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func generateJennyFlowerName(descriptor: String) async throws -> String {
        guard !APIConfiguration.shared.openAIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let apiKey = APIConfiguration.shared.openAIKey
        
        let systemPrompt = """
        You are a botanist who names newly discovered flower species. Create an elegant name that incorporates "Jenny" or relates to the name Jenny.
        Examples: "Jenny's Rose", "Jennifer Lily", "Jenny's Garden Bloom", "Jenniferia elegans".
        The name should sound like it could be a real flower species named after or dedicated to someone named Jenny.
        Respond with just the flower name, nothing else.
        """
        
        let userPrompt = """
        Create a beautiful flower name that includes or relates to "Jenny" for a flower described as: \(descriptor)
        The name should be 2-4 words maximum and sound elegant and botanical.
        """
        
        let request = ChatCompletionRequest(
            model: "gpt-4o-mini",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: systemPrompt),
                ChatCompletionRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.9,
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
        
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
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
        guard !APIConfiguration.shared.openAIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let systemPrompt = """
        You are a poetic notification writer for a flower discovery app. Create beautiful, engaging push notification messages.
        The notification should feel magical and make the user excited to discover their new flower or bouquet.
        Return a JSON object with "title" and "body" fields.
        Keep the title under 30 characters and the body under 80 characters.
        Use emojis sparingly but effectively.
        Vary your messages - don't always use the same format.
        Sometimes be poetic, sometimes mysterious, sometimes joyful.
        """
        
        let userPrompt: String
        if isBouquet, let holiday = holidayName {
            userPrompt = """
            Create a special push notification for a holiday bouquet for \(holiday).
            Make it sound festive and exciting - this is a special gift, not just a regular flower.
            Reference the holiday but keep it elegant.
            Examples: "🎁 A \(holiday) surprise awaits!" or "✨ Special bouquet for \(holiday)"
            """
        } else {
            userPrompt = """
            Create a push notification for a flower called "\(flowerName)".
            Make it sound like this specific flower has just bloomed and is waiting to be discovered.
            Don't just say "has bloomed" every time - vary the language.
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
        urlRequest.setValue("Bearer \(APIConfiguration.shared.openAIKey)", forHTTPHeaderField: "Authorization")
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
} 