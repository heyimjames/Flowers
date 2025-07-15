# Flowers App PRD

## Overview
Flowers is a beautiful iOS app that generates unique, AI-created flower images daily. Users can discover rare and beautiful flowers, learn about their botanical characteristics and cultural significance, and build a personal collection. The app acts as a "flower spotter's guide" where users gradually discover and catalog flowers from around the world.

## Core Features

### 1. Daily Flower Generation
- App generates a unique flower each day automatically
- Uses AI to create beautiful, botanical-style illustrations
- Each flower has an elegant, botanically-plausible name
- Flowers are assigned to different continents based on their natural habitats

### 2. Flower Discovery & Collection
- Users build a collection of discovered flowers over time
- Track total flowers discovered with a prominent counter
- View statistics by continent (how many from each region)
- Each flower is marked with its discovery date

### 3. Detailed Flower Information
- Tap any flower in the collection to reveal detailed information:
  - **Meaning**: Cultural and symbolic significance in various traditions
  - **Properties**: Notable botanical characteristics, growth patterns, and ecological benefits
  - **Origins**: Geographic origins, natural habitat, and climate preferences
  - **Description**: Rich description of appearance, blooming season, fragrance, and growth habits
- Information is generated using AI with context about current season

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
- **FAL.ai**: Used exclusively for all flower image generation
- **OpenAI**: Used for generating flower names and detailed botanical information
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
- Soft watercolor textures and natural aesthetics
- Emphasis on discovery and collection mechanics
- Scientifically-plausible yet beautiful flower descriptions

## Future Considerations
- Achievements for discovering certain numbers of flowers
- Rare flower types based on geographic regions
- Seasonal flowers that only appear during certain times of year
- Export collection as a digital field guide 