# API Key Setup Guide

## Important: Built-in API Keys for App Store Distribution

Your app needs to ship with your API keys built-in so all users can generate flowers without providing their own keys.

## Quick Setup (3 Steps)

### 1. Generate Obfuscated Keys

Edit `generate_api_keys.swift` and replace the placeholder keys with your actual keys:

```swift
let openAIKey = "sk-proj-YOUR-ACTUAL-OPENAI-KEY"  // Your real OpenAI key
let falKey = "YOUR-ACTUAL-FAL-AI-KEY"            // Your real FAL AI key
```

### 2. Run the Script

```bash
swift generate_api_keys.swift
```

This will output obfuscated versions of your keys.

### 3. Update AppConfig.swift

Replace the obfuscated keys in `Flowers/Configuration/AppConfig.swift`:

```swift
private let defaultOpenAIKey: String = {
    let obfuscatedKey = "PASTE-YOUR-OBFUSCATED-OPENAI-KEY-HERE"
    return AppConfig.deobfuscateKey(obfuscatedKey)
}()

private let defaultFALKey: String = {
    let obfuscatedKey = "PASTE-YOUR-OBFUSCATED-FAL-KEY-HERE"
    return AppConfig.deobfuscateKey(obfuscatedKey)
}()
```

## How It Works

1. **Obfuscation**: Your API keys are XOR-encoded and base64 encoded to prevent them from being easily found in the binary
2. **Runtime Deobfuscation**: The app deobfuscates the keys at runtime when needed
3. **Priority System**: 
   - Production keys (SecureConfig) have highest priority
   - User-provided keys come next
   - Built-in obfuscated keys are the fallback

## Security Notes

- The obfuscation is basic - it prevents casual inspection but isn't cryptographically secure
- For better security, consider:
  - Using a proxy server that holds your API keys
  - Implementing certificate pinning
  - Using more sophisticated obfuscation

## Testing

After updating the keys:
1. Delete the app from your device
2. Clean build (Shift+Cmd+K)
3. Build and run
4. The app should generate flowers without asking for API keys

## Important for App Store

- Never commit raw API keys to git
- The obfuscated keys are safe to commit
- Make sure to test with a fresh install to verify keys work 