# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flowers is an iOS app that delivers daily AI-generated flower discoveries to users. Each day, users receive a unique flower with botanical information, creating a digital flower collection experience. The app uses SwiftUI, targets iOS 18.5+, and includes a home screen widget extension.

## Development Commands

### Building
```bash
# Build for simulator
xcodebuild -project Flowers.xcodeproj -scheme Flowers -sdk iphonesimulator build

# Build for device
xcodebuild -project Flowers.xcodeproj -scheme Flowers -sdk iphoneos build

# Clean build
xcodebuild -project Flowers.xcodeproj -scheme Flowers clean
```

### Testing
```bash
# Run all tests
xcodebuild test -project Flowers.xcodeproj -scheme Flowers -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -project Flowers.xcodeproj -scheme Flowers -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FlowersTests/FlowersTests/testMethodName
```

### Archiving for Release
```bash
xcodebuild archive -project Flowers.xcodeproj -scheme Flowers -archivePath Flowers.xcarchive
```

## Architecture & Code Organization

### MVVM Architecture
- **Views**: SwiftUI views in `Flowers/Views/`
- **Model**: `AIFlower` data model with Codable support
- **ViewModel/Store**: `FlowerStore` as main ObservableObject managing app state
- **Services**: API integrations in `Flowers/Services/`

### Key Components

**FlowerStore** (`Models/FlowerStore.swift`): Central state management
- Handles flower generation, scheduling, and persistence
- Manages notifications and daily flower logic
- Coordinates between services and views
- Uses UserDefaults for persistence

**AIFlower** (`Models/AIFlower.swift`): Core data model
- Includes name, image data, meaning, characteristics, origins
- Location and weather context
- Codable for easy persistence

**Service Architecture**:
- `APIConfiguration`: Protocol for API provider abstraction
- `OpenAIService`: DALL-E 3 image generation
- `FALService`: FAL AI (Flux Schnell) image generation
- `ContextualFlowerGenerator`: Location-aware flower generation

### Widget Extension
- Separate target `FlowersWidget`
- Shares data via App Group: `group.OCTOBER.Flowers`
- Timeline provider for daily updates

## Important Implementation Details

### Daily Flower Scheduling
- Flowers are scheduled once per day at random time (8am-10:30pm)
- Uses `scheduleNextFlower()` in FlowerStore
- Pending flowers stored separately until revealed
- Notification scheduled with flower generation

### API Integration Pattern
```swift
// Services use singleton pattern
let service = OpenAIService.shared
// or
let service = FALService.shared

// API keys stored in UserDefaults
UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
```

### UI Conventions
- All sheets use 32px corner radius
- Consistent use of `.presentationDetents` and `.presentationDragIndicator`
- Color scheme defined in Assets.xcassets
- Gradient overlays for floating buttons

### Testing
- Uses Swift Testing framework (new `@Test` macro style)
- Minimal test coverage currently
- Test targets: FlowersTests (unit), FlowersUITests (UI)

## Key User Flows

1. **Daily Discovery**: Notification → Reveal state → Tap to reveal → View flower
2. **Manual Generation** (debug only): Settings → Toggle "Anytime Generations" → Find Flower button
3. **Collection**: Main screen → Collection button → Grid view with favorites filter

## Data Storage
- Flowers: UserDefaults key `discoveredFlowers`
- Favorites: UserDefaults key `favoriteFlowerIDs`
- Pending flower: UserDefaults key `pendingFlower`
- Shared with widget via App Group

## Important Notes
- First flower always includes "Jenny" in the name (onboarding)
- Images are base64 encoded in the model
- Location services used for contextual generation
- Background modes enabled for notifications