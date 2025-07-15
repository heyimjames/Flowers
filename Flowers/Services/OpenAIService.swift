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
    
    func generateFlowerDetails(for flower: AIFlower) async throws -> FlowerDetails {
        guard !APIConfiguration.shared.openAIKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let apiKey = APIConfiguration.shared.openAIKey
        
        // Get current date context
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let currentDate = dateFormatter.string(from: Date())
        
        let season = getCurrentSeason()
        
        let systemPrompt = """
        You are a knowledgeable botanist and naturalist who creates detailed information about rare and beautiful flowers. 
        You should respond with a JSON object containing meaning, properties, origins, detailedDescription, and continent fields.
        Make the information scientifically plausible yet poetic, focusing on natural beauty, botanical characteristics, and ecological significance.
        Include references to the current season (\(season)) when describing blooming patterns or growth cycles.
        The continent should be one of: North America, South America, Europe, Africa, Asia, Oceania, Antarctica.
        """
        
        let userPrompt = """
        Generate detailed botanical information for a flower called "\(flower.name)" which is described as "\(flower.descriptor)".
        Include:
        1. meaning: Cultural and symbolic significance of this flower in various traditions
        2. properties: Notable botanical characteristics, growth patterns, and ecological benefits
        3. origins: Geographic origins and natural habitat, including climate preferences
        4. detailedDescription: A rich description of its appearance, blooming season (considering it's currently \(season)), fragrance, and how it grows in nature
        5. continent: Which continent this flower naturally originates from
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