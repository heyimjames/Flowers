import Foundation

enum APIProvider: String, CaseIterable {
    case openAI = "OpenAI DALL-E"
    case fal = "FAL AI"
    
    var requiresAPIKey: Bool {
        return true
    }
}

class APIConfiguration: ObservableObject {
    static let shared = APIConfiguration()
    
    @Published var selectedProvider: APIProvider = .openAI
    @Published var openAIKey: String = ""
    @Published var falKey: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let openAIKeyKey = "openAIAPIKey"
    private let falKeyKey = "falAPIKey"
    private let selectedProviderKey = "selectedAPIProvider"
    
    init() {
        loadConfiguration()
    }
    
    func loadConfiguration() {
        openAIKey = userDefaults.string(forKey: openAIKeyKey) ?? ""
        falKey = userDefaults.string(forKey: falKeyKey) ?? ""
        
        if let providerString = userDefaults.string(forKey: selectedProviderKey),
           let provider = APIProvider(rawValue: providerString) {
            selectedProvider = provider
        }
    }
    
    func saveConfiguration() {
        userDefaults.set(openAIKey, forKey: openAIKeyKey)
        userDefaults.set(falKey, forKey: falKeyKey)
        userDefaults.set(selectedProvider.rawValue, forKey: selectedProviderKey)
    }
    
    var hasValidAPIKey: Bool {
        switch selectedProvider {
        case .openAI:
            return !openAIKey.isEmpty
        case .fal:
            return !falKey.isEmpty
        }
    }
    
    var hasValidOpenAIKey: Bool {
        return !openAIKey.isEmpty
    }
    
    var hasValidFalKey: Bool {
        return !falKey.isEmpty
    }
    
    var currentAPIKey: String? {
        switch selectedProvider {
        case .openAI:
            return openAIKey.isEmpty ? nil : openAIKey
        case .fal:
            return falKey.isEmpty ? nil : falKey
        }
    }
} 