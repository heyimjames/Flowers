# AI Flower Garden 🌸

A beautiful iOS app that generates unique AI flowers daily with widget support.

## Features

- **Daily Flower Generation**: Get a unique, beautiful AI-generated flower every day
- **Custom Flower Creation**: Generate flowers with specific descriptors
- **Favorites Collection**: Save your favorite flowers
- **Home Screen Widget**: Display your daily flower on the home screen (small & medium sizes)
- **Share Functionality**: Share beautiful flower images with friends
- **Beautiful UI**: Modern design with 32px corner radius sheets throughout

## Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 5.9+
- API Key (OpenAI or FAL)

## Getting Started

1. Open `Flowers.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build and run the app on a simulator or device
4. Tap the gear icon to open Settings
5. Select your preferred AI provider (OpenAI or FAL)
6. Enter your API key
7. Start generating beautiful AI flowers!
8. To add the widget: Long press on home screen → Add Widget → Search for "Flowers"

## API Setup

### OpenAI (DALL-E 3)
1. Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. The app uses DALL-E 3 for high-quality image generation
3. Images are generated at 1024x1024 resolution

### FAL AI (Flux Schnell)
1. Get your API key from [FAL Dashboard](https://fal.ai/dashboard/keys)
2. The app uses Flux Schnell for fast image generation
3. Images are generated in square HD format

## App Structure

```
Flowers/
├── Models/
│   ├── AIFlower.swift      # Flower data model
│   └── FlowerStore.swift   # State management
├── Views/
│   ├── ContentView.swift   # Main screen
│   ├── GeneratorSheet.swift # Flower generation UI
│   ├── FavoritesSheet.swift # Favorites gallery
│   ├── SettingsSheet.swift  # API configuration
│   └── ViewExtensions.swift # Custom styling
├── Services/
│   ├── APIConfiguration.swift # API key management
│   ├── OpenAIService.swift    # DALL-E integration
│   └── FALService.swift       # FAL AI integration
└── FlowersWidget/          # Widget extension
```

## Features Overview

### Main Screen
- Displays the current flower with its name
- Action buttons: Generate, Favorite, Share, View Gallery

### Generate Sheet (Large Detent, 32px radius)
- Select from preset descriptors or "Surprise me"
- Live preview while generating
- Beautiful loading animations

### Favorites Gallery (Full Screen, 32px radius)
- Grid layout of saved flowers
- Tap to view details
- Swipe to delete functionality

### Widget
- Small: Shows flower image with name overlay
- Medium: Shows flower with additional details
- Updates daily at midnight

## Notes

- The app uses real AI image generation via OpenAI DALL-E 3 or FAL AI
- Falls back to gradient placeholders if no API key is configured
- API keys are stored securely in UserDefaults and never shared
- App uses shared App Groups to sync data between main app and widget
- All flowers use a consistent botanical illustration prompt template

## Prompt Template

All flowers are generated using a consistent prompt template for beautiful, cohesive results:
```
"A single [DESCRIPTOR] flower, botanical illustration style, centered on pure white background, 
soft watercolor texture, delicate petals, elegant stem with leaves, dreamy and ethereal, 
pastel colors with subtle gradients, professional botanical art, highly detailed, 4K"
```

## Design Specifications

- All sheets use 32px corner radius [[memory:3238310]]
- Border radii follow hierarchy: 12px outer, 8px/4px inner [[memory:3209346]]
- Purple accent color throughout
- Consistent padding and spacing

## Future Enhancements

- Add more AI providers (Midjourney, Stable Diffusion)
- Add more flower descriptors
- Implement cloud sync for favorites
- Add notification for new daily flowers
- Custom prompt editing for advanced users 