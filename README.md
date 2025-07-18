# 🌸 Flowers - Daily AI Flower Discovery

A beautiful iOS app that delivers one unique AI-generated flower to you each day, creating a digital flower journal of your life's journey.

## 📱 App Philosophy

Flowers transforms AI generation into a meaningful daily ritual. Rather than endless generation, you discover one special flower per day at a random time between 8am and 10:30pm. Each flower is contextually aware - influenced by your location, weather, season, and even special calendar events - making every discovery uniquely yours.

## ✨ Core Features

### 🌺 Daily Flower Discovery
- **One flower per day** arrives at a surprise time (8am-10:30pm)
- **Push notifications** alert you: "Your Daily Flower Has Bloomed! 🌸"
- **Reveal mechanism** - Open the app and tap "Reveal Flower" to unwrap your gift
- Creates anticipation and a daily mindfulness moment

### 📚 Your Flower Collection
- **Automatic collection** - Every discovered flower is saved
- **Favorites system** - Heart your most cherished flowers
- **Discovery tracking** - See total flowers found with achievement milestones
- **Geographic diversity** - Track flowers by continent of discovery
- **Rich botanical information** - Each flower includes:
  - Cultural meaning and symbolism
  - Botanical characteristics
  - Geographic origins
  - Seasonal growth patterns

### 🎯 Contextual Intelligence
Flowers are generated based on:
- **📍 Location** - Reflects your city's character
- **🌤️ Weather** - Adapts to current conditions
- **🍂 Season** - Matches nature's cycles  
- **📅 Calendar** - Special flowers for holidays and events
- **🎉 Milestones** - Achievement bouquets at 10, 25, 50+ flowers

### 🤝 Social Features
- **Gift flowers** to friends via AirDrop
- **Ownership history** - See who originally grew and previously owned each flower
- **Physical transfer model** - Gifted flowers leave your collection
- **Import received flowers** - Accept .flower files from friends

### ☁️ iCloud Sync & Backup
- **Automatic backup** of your entire collection
- **Cross-device sync** - Access flowers on all your devices
- **Manual backup/restore** options
- **Privacy-focused** - Only you can access your flowers

### 🎨 Customization
- **Multiple app icons** - Choose your favorite flower icon
- **Auto-save to Photos** - Automatically save discoveries
- **Custom name** - Personalize your flower journal
- **Theme support** - Beautiful in light and dark modes

### 📊 Home Screen Widget
- **Small widget** - Shows today's flower with name
- **Medium widget** - Displays flower with additional details
- **Auto-updates** at midnight for new daily flower

## 🚀 Getting Started

1. **Download & Launch**
   - Open `Flowers.xcodeproj` in Xcode
   - Build and run on your iPhone (iOS 18.0+)

2. **First Launch**
   - Choose your starter flower during onboarding
   - Allow notifications to get bloom alerts
   - Optional: Allow location for contextual flowers

3. **Daily Ritual**
   - Receive notification when your flower blooms
   - Open app to reveal your discovery
   - Read about its meaning and origins
   - Save to favorites if it's special

4. **Add Widget**
   - Long press home screen
   - Tap + to add widget
   - Search for "Flowers"
   - Choose size and placement

## 🔧 Technical Setup

### API Configuration

The app comes pre-configured with production API keys, so **users don't need to provide any API keys**. The app will work immediately after installation.

### For Developers

If you're contributing to the project:
1. The app will use placeholder flowers without real API keys
2. Copy `SecureConfig.swift.template` to `SecureConfig.swift` for testing
3. Never commit `SecureConfig.swift` - it's automatically ignored by git

### Requirements
- iOS 18.0+
- Xcode 16.0+
- Swift 5.9+

## 📁 Project Structure

```
Flowers/
├── Models/
│   ├── AIFlower.swift         # Flower model with ownership tracking
│   └── FlowerStore.swift      # App state & flower management
├── Views/
│   ├── ContentView.swift      # Main screen with reveal button
│   ├── FlowerRevealView.swift # Unwrapping animation
│   ├── FavoritesSheet.swift   # Collection gallery
│   ├── SettingsSheet.swift    # App configuration
│   ├── OnboardingView.swift   # First launch experience
│   └── GiftFlowerSheet.swift  # Flower gifting UI
├── Services/
│   ├── OpenAIService.swift    # Flower names & descriptions
│   ├── FALService.swift       # AI image generation
│   ├── LocationManager.swift  # Contextual awareness
│   ├── FlowerNotificationSchedule.swift # Daily scheduling
│   ├── iCloudSyncManager.swift # Backup & sync
│   └── ContextualFlowerGenerator.swift # Smart generation
├── Configuration/
│   ├── AppConfig.swift        # App configuration
│   ├── SecureConfig.swift     # API keys (git ignored)
│   └── APIConfiguration.swift # Key management
└── FlowersWidget/            # Home screen widget
```

## 🎯 Design Philosophy

### Language & Tone
- "Discover" and "Find" flowers (not "Generate")
- "Your garden awaits..." for empty states
- "A new flower awaits..." when ready to reveal
- Natural, organic language throughout

### Visual Design
- 32px corner radius on all sheets [[memory:3238310]]
- Transparent floating buttons
- Progressive blur effects
- Smooth reveal animations
- Botanical illustration style

### User Experience
- **Scarcity creates value** - One flower per day makes each special
- **Anticipation builds engagement** - Random timing adds excitement
- **Personal connection** - Contextual details make flowers meaningful
- **Social bonds** - Gifting creates emotional connections

## 🌟 Special Features

### Achievement Bouquets
Celebrate milestones with special bouquet arrangements:
- 10 flowers - First bouquet
- 25 flowers - Growing garden
- 50 flowers - Dedicated botanist
- 100, 250, 500, 1000 - Master collector

### Developer Mode
Settings → Developer Options:
- **Test Notifications** - Schedule in X seconds
- **Force Daily Flower** - Skip waiting period
- **Debug Location** - Test different contexts

### Flower Transfer (.flower files)
- Custom document format preserving complete flower data
- Includes full ownership history
- One-time transfer (original owner loses flower)
- AirDrop integration for easy sharing

## 🛡️ Privacy & Security

- **No account required** - Fully local experience
- **API keys embedded** - Users never handle keys
- **iCloud Private Database** - Only you access your flowers
- **Anonymous device IDs** - For ownership tracking
- **Location optional** - Works without, but less contextual

## 📝 Notifications

The app sends gentle notifications:
- "Your Daily Flower Has Bloomed! 🌸" [[memory:3422745]]
- Simple, friendly text with flower name
- Call to action to open the app
- Respects Do Not Disturb

## 🌍 Contextual Generation

Flowers reflect your world:
- **Morning flowers** - Bright, energizing varieties
- **Evening flowers** - Calming, peaceful types
- **Rainy day flowers** - Hardy, weather-resistant species
- **Holiday flowers** - Festive, seasonal selections
- **Location-based** - Regional varieties from your area

## 🚧 Future Enhancements

- Seasonal rare flowers
- Community flower exchange
- AR flower viewing
- Integration with real florists
- Flower care mini-games
- Monthly themed collections

## 📄 License

This project is proprietary software. All rights reserved.

---

**🌸 May your daily flower bring a moment of beauty to your day!** 