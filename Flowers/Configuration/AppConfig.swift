import Foundation
import CryptoKit

class AppConfig {
    static let shared = AppConfig()
    
    private init() {}
    
    // MARK: - Built-in API Keys (Obfuscated)
    
    /// Default OpenAI API key for App Store distribution
    /// Replace these with your actual keys before building for release
    private let defaultOpenAIKey: String = {
        // Method 1: Base64 + XOR obfuscation
        let obfuscatedKey = "Gx0aHkdtFxYLCBMaBAMGS0MRCjMUCRNLQxAaHBEJE0tDAAIaFxEDCQdLQxQaHAMASxUHERYCS0MfGBAcGxRLQzEBHBoeGxJLQxcYAhcUS0MXEAARHBNLQz0eGR8eS0MeAxAaFhNLQxcECRwCBUtDDB8VCjEUCQJLQzEBFwsQBEtDFAdRGR8aEEozYHVJCFpobnhuYn1eFAEYdQEcHBUGVBdSGBdLQxQSAAcOF1dLQxYRGw8QS0MfEQYdEBNLQwwQCAACGUtDBAoaEUozBA0QBwIYdQwcCRERSxsQFBYNAA4aF0tDAwUKBEdLQxoSAgERS0MdGQ8ABA5LQxYBBBEAAgdLUAUaEB4VAkogbnBtcW5xdHJxdnYhGhoeF0tDDxsaAxBLUEY=" // Obfuscated OpenAI key
        return AppConfig.deobfuscateKey(obfuscatedKey)
    }()
    
    /// Default FAL API key for App Store distribution
    private let defaultFALKey: String = {
        // Method 1: Base64 + XOR obfuscation
        let obfuscatedKey = "Ch0eBRBhFBMmFQBiKQEPKQEhFQYtKQJjKQJlKQEiFQpmLhQfKRkLKREXKhgdKBELOhQMKBEcFQEAKBQUOBAdKhcAKxgA" // Obfuscated FAL key
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
        return !defaultOpenAIKey.isEmpty && !defaultFALKey.isEmpty
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