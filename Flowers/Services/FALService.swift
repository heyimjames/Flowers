import Foundation
import UIKit

class FALService {
    static let shared = FALService()
    
    private let baseURL = "https://fal.run/fal-ai/flux/schnell"
    
    struct ImageGenerationRequest: Encodable {
        let prompt: String
        let image_size: String = "square_hd"
        let num_images: Int = 1
        let num_inference_steps: Int = 4
        let guidance_scale: Double = 3.5
        let enable_safety_checker: Bool = true
    }
    
    struct ImageGenerationResponse: Decodable {
        let images: [ImageData]
    }
    
    struct ImageData: Decodable {
        let url: String
        let width: Int
        let height: Int
    }
    
    enum FALError: Error, LocalizedError {
        case invalidAPIKey
        case invalidURL
        case noImageGenerated
        case networkError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid or missing FAL API key"
            case .invalidURL:
                return "Invalid URL"
            case .noImageGenerated:
                return "No image was generated"
            case .networkError(let message):
                return "Network error: \(message)"
            }
        }
    }
    
    func generateFlowerImage(descriptor: String, isBouquet: Bool = false, personalMessage: String? = nil) async throws -> (UIImage, String) {
        let apiKey = APIConfiguration.shared.effectiveFALKey
        print("FALService: Using API key: \(apiKey.isEmpty ? "EMPTY" : "Present (\(apiKey.count) chars)")")
        guard !apiKey.isEmpty else {
            print("FALService: API key is empty, throwing invalidAPIKey error")
            throw FALError.invalidAPIKey
        }
        
        // Build the prompt based on whether it's a bouquet or single flower
        let prompt: String
        if isBouquet {
            let basePrompt = "ISOLATED on PLAIN WHITE BACKGROUND, a beautiful bouquet of \(descriptor), NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, elegant botanical illustration style, soft watercolor texture, multiple flower types harmoniously arranged, wrapped with delicate ribbon, dreamy and ethereal, pastel colors with subtle gradients, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed flowers, 4K"
            if let message = personalMessage {
                prompt = basePrompt + ". " + message
            } else {
                prompt = basePrompt
            }
        } else {
            let basePrompt = "ISOLATED on PLAIN WHITE BACKGROUND, a single \(descriptor) flower, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stem with leaves, dreamy and ethereal, pastel colors with subtle gradients, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K"
            if let message = personalMessage {
                prompt = basePrompt + ". " + message
            } else {
                prompt = basePrompt
            }
        }
        
        let request = ImageGenerationRequest(prompt: prompt)
        
        guard let url = URL(string: baseURL) else {
            throw FALError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FALError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 {
            if let errorString = String(data: data, encoding: .utf8) {
                throw FALError.networkError(errorString)
            }
            throw FALError.networkError("Status code: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        let generationResponse = try decoder.decode(ImageGenerationResponse.self, from: data)
        
        guard let imageData = generationResponse.images.first,
              let imageURL = URL(string: imageData.url) else {
            throw FALError.noImageGenerated
        }
        
        // Download the image
        let (imageDataResponse, _) = try await URLSession.shared.data(from: imageURL)
        
        guard let image = UIImage(data: imageDataResponse) else {
            throw FALError.noImageGenerated
        }
        
        return (image, prompt)
    }
} 