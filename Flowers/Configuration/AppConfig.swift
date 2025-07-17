import Foundation
import CryptoKit

class AppConfig {
    static let shared = AppConfig()
    
    private init() {}
    
    // MARK: - Built-in API Keys (Obfuscated)
    
    /// Default OpenAI API key for App Store distribution
    private let defaultOpenAIKey: String = {
        let obfuscatedKey = "MSlvMjAtKG8gKjc4DgAYABgDFHoONBMxdBoAIQcDEHY2dgYMMDc3cTIQKXYPLjQgIxotLTd0J3A2JhUrNCA3G3UsEgR1LC5xdBI4cHM1KA8DBRZxAC4gKQQIGwEoIRoAJSwHcCMDAyYKCTIqexcEBgN6FjEgEjgyHTd3ExsSChU6dhAuDQwtDwVwE3srK3UENHY1AXpxGBRzNgMtGw0JDRoGNQM="
        return AppConfig.deobfuscateKey(obfuscatedKey)
    }()
    
    /// Default FAL API key for App Store distribution
    private let defaultFALKey: String = {
        let obfuscatedKey = "JyB0ISNwIHRvcXpxcW92I3BxbyNwdyFvdnR7ICB1enohIyQjeHQncXt0cCYncHIndyYje3B2J3d1c3d6ISB2cyR2dXRx"
        return AppConfig.deobfuscateKey(obfuscatedKey)
    }()
    
    // MARK: - Key Access Methods
    
    /// Returns the effective OpenAI API key (user's key if set, otherwise default)
    var effectiveOpenAIKey: String {
        let userKey = APIConfiguration.shared.openAIKey
        return userKey.isEmpty ? defaultOpenAIKey : userKey
    }
    
    /// Returns the effective FAL API key (user's key if set, otherwise default)
    var effectiveFALKey: String {
        let userKey = APIConfiguration.shared.falKey
        return userKey.isEmpty ? defaultFALKey : userKey
    }
    
    /// Check if built-in keys are available
    var hasBuiltInKeys: Bool {
        let openAIValid = !defaultOpenAIKey.isEmpty && defaultOpenAIKey.hasPrefix("sk-")
        let falValid = !defaultFALKey.isEmpty && defaultFALKey.count > 20
        print("AppConfig: OpenAI key valid: \(openAIValid), FAL key valid: \(falValid)")
        print("AppConfig: OpenAI key starts with: \(defaultOpenAIKey.prefix(10))")
        print("AppConfig: FAL key starts with: \(defaultFALKey.prefix(10))")
        return openAIValid && falValid
    }
    
    // MARK: - Key Obfuscation/Deobfuscation
    
    /// Simple XOR deobfuscation (you can make this more complex)
    private static func deobfuscateKey(_ obfuscatedKey: String) -> String {
        // This is a simple example - you can use more sophisticated methods
        guard let data = Data(base64Encoded: obfuscatedKey) else {
            print("AppConfig: Failed to decode base64 for obfuscated key")
            return ""
        }
        
        let xorKey: UInt8 = 0x42 // Simple XOR key
        let deobfuscated = data.map { $0 ^ xorKey }
        
        let result = String(data: Data(deobfuscated), encoding: .utf8) ?? ""
        print("AppConfig: Deobfuscated key length: \(result.count)")
        return result
    }
    
    /// Helper method to obfuscate keys during development
    /// Use this to generate obfuscated versions of your keys
    static func obfuscateKey(_ key: String) -> String {
        let xorKey: UInt8 = 0x42
        let data = Data(key.utf8)
        let obfuscated = data.map { $0 ^ xorKey }
        return Data(obfuscated).base64EncodedString()
    }
    
    /// DEVELOPMENT HELPER: Call this to generate obfuscated versions of your real API keys
    /// Example usage in a development build:
    /// print("OpenAI obfuscated: \(AppConfig.generateObfuscatedKeys(openAI: "sk-your-real-key", fal: "your-fal-key"))")
    static func generateObfuscatedKeys(openAI: String, fal: String) -> (openAI: String, fal: String) {
        return (
            openAI: obfuscateKey(openAI),
            fal: obfuscateKey(fal)
        )
    }
}

// MARK: - Helper Extension for APIConfiguration

extension APIConfiguration {
    /// Returns the effective OpenAI key (user's or built-in)
    var effectiveOpenAIKey: String {
        return AppConfig.shared.effectiveOpenAIKey
    }
    
    /// Returns the effective FAL key (user's or built-in)
    var effectiveFALKey: String {
        return AppConfig.shared.effectiveFALKey
    }
    
    /// Check if user has custom keys set
    var hasCustomKeys: Bool {
        return !openAIKey.isEmpty && !falKey.isEmpty
    }
}