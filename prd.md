# Flowers App PRD

## Overview
Flowers is a beautiful iOS app that delivers daily flower discoveries to users. Each day at a random time between 8am and 10:30pm, a new flower "blooms" and users receive a notification. The app acts as a digital flower field guide where users gradually build their collection by discovering one special flower per day.

## Core Features

### 1. Daily Flower Discovery
- One flower is discovered automatically each day at a random time (8am-10:30pm)
- Push notification alerts users when their flower has bloomed
- Reveal mechanism - users must open the app and tap "Reveal Flower" to see their discovery
- Creates anticipation and a daily ritual around flower discovery

### 2. Flower Collection & Tracking
- All discovered flowers are automatically added to "My Collection"
- Separate filter for viewing only favorited flowers
- Track total flowers discovered with prominent counter
- Statistics by continent showing geographic diversity
- Discovery date tracked for each flower

### 3. Detailed Botanical Information
- Each flower includes scientifically-plausible details:
  - **Meaning**: Cultural and symbolic significance
  - **Characteristics**: Botanical properties and growth patterns
  - **Origins**: Geographic origins and natural habitat
  - **Description**: Appearance, blooming season, and growth habits
- Information contextually aware of current season

### 4. Favorites System
- Mark special flowers as favorites with heart button
- Quick filter between all flowers and favorites
- Visual heart overlay on favorited flowers in grid
- Favorites count badge on collection button

### 5. Sharing & Photography
- Save flower images directly to camera roll
- Share flowers via iOS share sheet
- Beautiful botanical illustration style images
- Proper permission handling

### 6. Debug Features (Settings)
- **Anytime Generations**: Toggle to show "Find Flower" button for testing
- **Test Notifications**: Schedule debug notification in X seconds
- Allows developers to test without waiting for daily schedule

## User Experience

### Daily Flow
1. User receives notification: "Your Daily Flower Has Bloomed! 🌸"
2. Opens app to see gift-wrapped flower state
3. Taps "Reveal Flower" to discover today's flower
4. Flower animates in with details loading
5. Can favorite, share, or save the flower

### Language & Tone
- "Find" and "Pick" flowers instead of "Generate"
- "Your garden awaits..." for empty states
- "A new flower awaits..." for reveal state
- Organic, nature-focused language throughout

## Technical Details

### Scheduling System
- Daily flower scheduled at app launch if needed
- Random time between 8:00 AM and 10:30 PM local time
- Handles timezone changes and date boundaries
- Falls back to immediate generation if time has passed

### API Integration
- **FAL.ai**: All flower image generation
- **OpenAI**: Flower names and botanical information
- First flower always named with "Jenny" theme
- Graceful fallbacks for API failures

### Data Persistence
- UserDefaults for favorites and discovered flowers
- Separate pending flower storage for reveal mechanism
- Shared container for widget access
- Notification badge management

### UI/UX Design
- Transparent floating buttons with gradient backgrounds
- Progressive blur effects on scroll
- 32px corner radius on all sheets
- Smooth reveal animations
- Multi-layer gradient fades

## Design Philosophy
- Creates daily anticipation and ritual
- Feels like real flower discovery, not generation
- Educational yet beautiful
- Encourages daily engagement through scarcity
- Celebrates each flower as special and unique

## Future Considerations
- Seasonal flowers that only appear during certain times
- Rare flowers with special discovery conditions
- Monthly collection challenges
- Social features to share daily discoveries
- Widget showing today's flower once revealed 