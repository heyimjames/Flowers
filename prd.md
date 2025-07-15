# Flowers App PRD

## Overview
Flowers is a beautiful iOS app that generates unique, AI-created flower images daily. Users can discover mystical flowers, learn about their meanings and properties, and build a personal collection. The app acts as a "flower spotter's guide" where users gradually discover and catalog magical flowers from around the world.

## Core Features

### 1. Daily Flower Generation
- App generates a unique flower each day automatically
- Uses AI to create beautiful, botanical-style illustrations
- Each flower has a poetic name and description
- Flowers are assigned to different continents for discovery tracking

### 2. Flower Discovery & Collection
- Users build a collection of discovered flowers over time
- Track total flowers discovered with a prominent counter
- View statistics by continent (how many from each region)
- Each flower is marked with its discovery date

### 3. Detailed Flower Information
- Tap any flower in the collection to reveal detailed information:
  - **Meaning**: What the flower symbolizes and represents
  - **Properties**: Magical or mystical properties
  - **Origins**: Legendary history and where it comes from
  - **Description**: Rich, poetic description incorporating current zodiac period and season
- Information is generated using AI with context about current date, season, and zodiac sign

### 4. Favorites System
- Mark flowers as favorites with a heart button
- Quick access to favorite flowers in a grid view
- Badge shows count of favorited flowers
- Remove flowers from favorites anytime

### 5. Sharing & Saving
- Save flower images directly to camera roll
- Share flowers via standard iOS share sheet
- Permission handling for photo library access

### 6. Manual Generation
- "Generate" button to create new flowers on demand
- Simple "Surprise Me" interface - no complex options
- Beautiful loading states during generation

### 7. Widget Support
- Home screen widget showing the daily flower
- Shared data container for widget access

## Technical Details

### API Integration
- Supports both OpenAI (DALL-E 3) and Fal.ai for image generation
- Uses OpenAI GPT-4 for generating flower details and information
- Graceful fallback to placeholder images when API unavailable

### Data Persistence
- UserDefaults for storing favorites and discovered flowers
- Shared container for widget data access
- Automatic daily flower refresh

### UI/UX
- Custom color theme with soft, botanical-inspired colors
- Smooth animations and transitions
- 32px corner radius on sheets (per user preference)
- Full-screen sheet presentations
- Haptic feedback for interactions

## Design Philosophy
- Clean, minimalist interface focusing on the flowers
- Botanical illustration style for all generated images
- Soft watercolor textures and dreamy aesthetics
- Emphasis on discovery and collection mechanics

## Future Considerations
- Achievements for discovering certain numbers of flowers
- Rare flower types with special generation conditions
- Seasonal events with themed flowers
- Social features to share collections with friends 