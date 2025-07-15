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
            case .networkError(let message):
                return "Network error: \(message)"
            case .invalidResponse:
                return "Invalid response from API"
            }
        }
    }
    
    func generateFlowerImage(descriptor: String) async throws -> (UIImage, String) {
        guard let apiKey = APIConfiguration.shared.currentAPIKey else {
            throw OpenAIError.invalidAPIKey
        }
        
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
    
    func generateFlowerDetails(for flower: AIFlower) async throws -> FlowerDetails {
        guard let apiKey = APIConfiguration.shared.currentAPIKey else {
            throw OpenAIError.invalidAPIKey
        }
        
        // Get current date context
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let currentDate = dateFormatter.string(from: Date())
        
        let zodiacSign = getCurrentZodiacSign()
        let season = getCurrentSeason()
        
        let systemPrompt = """
        You are a mystical botanist who creates detailed information about magical flowers. 
        You should respond with a JSON object containing meaning, properties, origins, detailedDescription, and continent fields.
        Make the information mystical, poetic, and enchanting. Include references to the current date (\(currentDate)), 
        season (\(season)), and zodiac period (\(zodiacSign)) when relevant.
        The continent should be one of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica.
        """
        
        let userPrompt = """
        Generate detailed information for a flower called "\(flower.name)" which is described as "\(flower.descriptor)".
        Include:
        1. meaning: What this flower symbolizes and represents
        2. properties: Magical or mystical properties this flower possesses
        3. origins: Where this flower comes from and its legendary history
        4. detailedDescription: A rich, poetic description incorporating the current \(zodiacSign) zodiac period and \(season) season
        5. continent: Which continent this flower originates from
        """
        
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
        
        guard let content = completionResponse.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw OpenAIError.invalidResponse
        }
        
        let flowerDetails = try JSONDecoder().decode(FlowerDetails.self, from: jsonData)
        return flowerDetails
    }
    
    private func getCurrentZodiacSign() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: Date())
        
        guard let month = components.month, let day = components.day else {
            return "Unknown"
        }
        
        switch (month, day) {
        case (1, 20...31), (2, 1...18): return "Aquarius"
        case (2, 19...29), (3, 1...20): return "Pisces"
        case (3, 21...31), (4, 1...19): return "Aries"
        case (4, 20...30), (5, 1...20): return "Taurus"
        case (5, 21...31), (6, 1...20): return "Gemini"
        case (6, 21...30), (7, 1...22): return "Cancer"
        case (7, 23...31), (8, 1...22): return "Leo"
        case (8, 23...31), (9, 1...22): return "Virgo"
        case (9, 23...30), (10, 1...22): return "Libra"
        case (10, 23...31), (11, 1...21): return "Scorpio"
        case (11, 22...30), (12, 1...21): return "Sagittarius"
        case (12, 22...31), (1, 1...19): return "Capricorn"
        default: return "Unknown"
        }
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
} 