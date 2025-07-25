#!/usr/bin/env swift

import Foundation

// INSTRUCTIONS:
// 1. Replace the placeholder keys below with your actual API keys
// 2. Run this script: swift generate_keys.swift
// 3. Copy the generated obfuscated keys to AppConfig.swift
// 4. Delete this file for security

func obfuscateKey(_ key: String) -> String {
    let xorKey: UInt8 = 0x42
    let data = Data(key.utf8)
    let obfuscated = data.map { $0 ^ xorKey }
    return Data(obfuscated).base64EncodedString()
}

// ⚠️ REPLACE THESE WITH YOUR ACTUAL API KEYS ⚠️
let openAIKey = "sk-your-actual-openai-key-here"
let falKey = "your-actual-fal-key-here"

print("=== Obfuscated API Keys ===")
print("\nFor AppConfig.swift line ~14:")
print("let obfuscatedKey = \"\(obfuscateKey(openAIKey))\"")
print("\nFor AppConfig.swift line ~21:")
print("let obfuscatedKey = \"\(obfuscateKey(falKey))\"")
print("\n✅ Copy these values to AppConfig.swift")
print("⚠️  Don't forget to delete this file after use!")