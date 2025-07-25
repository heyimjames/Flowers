import Foundation

class APIConfiguration: ObservableObject {
    static let shared = APIConfiguration()
    
    @Published var openAIKey: String = ""
    @Published var falKey: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let openAIKeyKey = "openAIAPIKey"
    private let falKeyKey = "falAPIKey"
    
    init() {
        loadConfiguration()
    }
    
    func loadConfiguration() {
        openAIKey = userDefaults.string(forKey: openAIKeyKey) ?? ""
        falKey = userDefaults.string(forKey: falKeyKey) ?? ""
    }
    
    func saveConfiguration() {
        userDefaults.set(openAIKey, forKey: openAIKeyKey)
        userDefaults.set(falKey, forKey: falKeyKey)
    }
    
    var hasValidOpenAIKey: Bool {
        // Always return true since we have built-in keys
        return true
    }
    
    var hasValidFalKey: Bool {
        // Always return true since we have built-in keys
        return true
    }
} 