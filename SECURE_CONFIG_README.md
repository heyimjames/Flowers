# 🔐 Secure API Key Configuration

This document explains how to securely configure production API keys for the Flowers app while keeping them out of the public repository.

## 🎯 Problem Solved

- **Users don't need to provide API keys** - They use your production keys automatically
- **API keys are never committed to git** - They stay secure and private
- **Open source contributors can't access your keys** - They use fallback placeholder flowers
- **Production builds use your keys** - Users get proper AI-generated flowers

## 🚀 Quick Setup

### Option 1: Automatic Setup (Recommended)

```bash
# From the project root directory
./setup-secure-config.sh
```

### Option 2: Manual Setup

1. **Copy the template:**
   ```bash
   cp Flowers/Configuration/SecureConfig.swift.template Flowers/Configuration/SecureConfig.swift
   ```

2. **Edit SecureConfig.swift:**
   ```swift
   // Replace these placeholders with your actual API keys
   let productionOpenAIKey: String = "sk-your-actual-openai-key-here"
   let productionFALKey: String = "your-actual-fal-key-here"
   ```

3. **Save the file** - It will be automatically ignored by git

## 🔑 Getting API Keys

### OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Create a new API key
3. Copy the key (starts with `sk-`)

### FAL AI API Key
1. Go to [FAL AI Dashboard](https://fal.ai/dashboard/keys)
2. Create a new API key
3. Copy the key

## 🔒 Security Features

### Key Priority System
The app uses keys in this order of priority:
1. **Production keys** (SecureConfig.swift) - Highest priority
2. **User-provided keys** (Settings → API Keys) - Medium priority  
3. **Built-in obfuscated keys** (AppConfig.swift) - Lowest priority

### Git Security
- `SecureConfig.swift` is in `.gitignore` - **Never committed**
- `SecureConfig.swift.template` is committed - **Safe placeholder**
- Contributors see template, not your real keys

### Runtime Security
- Keys are only loaded at runtime
- No hardcoded keys in the binary
- Debug logs don't expose full keys

## 📁 File Structure

```
Flowers/Configuration/
├── SecureConfig.swift          # 🔒 Your real keys (never committed)
├── SecureConfig.swift.template # 📝 Template (committed to git)
├── AppConfig.swift            # 🔧 Main configuration logic
└── APIConfiguration.swift     # 👤 User key management
```

## 🧪 Testing

### Verify Setup
```swift
// In your app, check key status
SecureConfig.shared.printKeyStatus()
```

### Expected Output
```
🔑 SecureConfig Key Status:
   OpenAI Key: ✅ Configured
   FAL Key: ✅ Configured
   Production Keys Valid: ✅ Yes
```

## 🚨 Important Notes

### DO NOT:
- ❌ Commit `SecureConfig.swift` to git
- ❌ Share your API keys publicly
- ❌ Include API keys in screenshots or documentation

### DO:
- ✅ Keep `SecureConfig.swift` private and secure
- ✅ Use the template for new setups
- ✅ Monitor API usage and costs

## 🔄 For Contributors

If you're contributing to this project:

1. **You don't need real API keys** - The app will use placeholder flowers
2. **Never commit SecureConfig.swift** - It's automatically ignored
3. **Use the template** - Copy `.template` to `.swift` if needed
4. **Test with mock data** - The app handles missing keys gracefully

## 🏗️ Build Process

### Development Builds
- Uses SecureConfig.swift if available
- Falls back to placeholder flowers if not configured
- Contributors can develop without API keys

### Production Builds
- Must have valid SecureConfig.swift
- Uses production API keys automatically
- Users get proper AI-generated flowers

## 📞 Support

If you need help with setup:
1. Check the console logs for key validation status
2. Verify your API keys are valid and active
3. Ensure SecureConfig.swift is in the correct location
4. Run the setup script again if needed

---

**🎉 Once configured, users will automatically get beautiful AI-generated flowers using your API keys!**