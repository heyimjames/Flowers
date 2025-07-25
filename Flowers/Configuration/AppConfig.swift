import Foundation
import CryptoKit

class AppConfig {
    static let shared = AppConfig()
    
    private init() {}
    
    // MARK: - Built-in API Keys (Obfuscated)
    
    /// Default OpenAI API key for App Store distribution
    private let defaultOpenAIKey: String = {
        // Production key - obfuscated for security
        let obfuscatedKey = "MSlvMjAtKG8RKRg2BQgucxMXEiYVHS0EIxNwMSMgNHcGFgEyIzsOeh1xAAwacC8zKhMqcHJ1BBsOATcDAyZ0Fy8tEwUPBSlzKikIFS0KMhV1CBZxAC4gKQQIBQYACXcxCy0EFigpIBU2GgAIC3I2AXQSdDoxETUjIHcGBxcNIzATNwYuOHYnMjsGBDIJLxB1KAUBFQpvKTEKLw8oBS44dnoKEwM="
        return AppConfig.deobfuscateKey(obfuscatedKey)
    }()
    
    /// Default FAL API key for App Store distribution
    private let defaultFALKey: String = {
        // Production key - obfuscated for security
        let obfuscatedKey = "JHF0cnF7c3BvJ3R6em92JiN0b3p2ICRvcHZxJ3Z1I3UhcXdyeHBydyd2c3F1cXUjcSAjIyMmeid1IydwcXYkdnUndHUh"
        return AppConfig.deobfuscateKey(obfuscatedKey)
    }()
    
    // MARK: - Key Access Methods
    
    /// Returns the effective OpenAI API key (production keys have highest priority)
    var effectiveOpenAIKey: String {
        // Priority: 1. Production keys (SecureConfig) 2. User keys 3. Default obfuscated keys
        if SecureConfig.shared.hasValidProductionKeys {
            return SecureConfig.shared.productionOpenAIKey
        }
        
        let userKey = APIConfiguration.shared.openAIKey
        return userKey.isEmpty ? defaultOpenAIKey : userKey
    }
    
    /// Returns the effective FAL API key (production keys have highest priority)
    var effectiveFALKey: String {
        // Priority: 1. Production keys (SecureConfig) 2. User keys 3. Default obfuscated keys
        if SecureConfig.shared.hasValidProductionKeys {
            return SecureConfig.shared.productionFALKey
        }
        
        let userKey = APIConfiguration.shared.falKey
        return userKey.isEmpty ? defaultFALKey : userKey
    }
    
    /// Check if any keys are available (production, user, or built-in)
    var hasValidKeys: Bool {
        // Always return true - we have built-in keys
        return true
    }
    
    /// Legacy method for backward compatibility
    var hasBuiltInKeys: Bool {
        return true
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