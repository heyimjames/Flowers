# Flower Generation Explanation

This document explains how the Flowers app generates personalized flower discoveries for users, detailing what user data is collected, how it influences flower selection, and how it's incorporated into the generated content.

## Overview

The Flowers app uses contextual information about the user's location, time, weather, and calendar events to create personalized flower discoveries. The system combines real botanical data with contextual elements to generate both the visual flower and its descriptive content.

## Data Sources and Usage

### 1. Location Data
**What is collected:**
- Current GPS coordinates (latitude/longitude)
- Country, city, and region information via reverse geocoding
- Address details (street, locality, administrative area)

**How it's used:**
- **Continent Mapping**: Determines which botanical species are native to the user's region
- **Location Context**: Incorporates city/region names into flower meanings and descriptions
- **Species Selection**: Prioritizes flowers that would naturally grow in the user's geographic area
- **Discovery Metadata**: Records where the flower was "discovered"

**Example mapping:**
```
Portugal → Europe → European species prioritized
Japan → Asia → Asian native species prioritized  
Brazil → South America → South American species prioritized
```

### 2. Weather Data
**What is collected:**
- Current weather conditions (sunny, rainy, cloudy, etc.)
- Temperature (Celsius/Fahrenheit)
- Weather service data from Apple's WeatherKit

**How it's used:**
- **Contextual Meaning**: Weather influences the flower's symbolic meaning
- **Visual Generation**: Weather conditions can influence flower selection and appearance
- **Discovery Metadata**: Records the weather when the flower was discovered
- **Personal Message**: Weather context added to flower descriptions

**Weather influence examples:**
```
Clear skies → "Flourishing under clear skies"
Rainy weather → "Nourished by gentle rain"
Snow → "Thriving in winter's embrace"
Hot weather (>25°C) → "Warmed by the sun"
Cold weather (<5°C) → "Resilient in the cold"
```

### 3. Temporal Data
**What is collected:**
- Current date and time
- Season (spring, summer, autumn, winter)
- Day of the week
- Time of day (morning, evening, night)

**How it's used:**
- **Seasonal Selection**: Flowers that bloom in the current season are prioritized
- **Hemisphere Awareness**: Seasons adjust based on Northern/Southern hemisphere location
- **Time Context**: Morning/evening/night influences flower selection
- **Discovery Metadata**: Records when the flower was discovered

**Seasonal mapping:**
```
Northern Hemisphere:
- March-May: Spring species
- June-August: Summer species  
- September-November: Autumn species
- December-February: Winter species

Southern Hemisphere: Seasons are reversed
```

### 4. Calendar and Cultural Data
**What is collected:**
- Current date checked against holiday calendar
- Zodiac sign based on date
- Cultural/regional holidays

**How it's used:**
- **Holiday Bouquets**: Special bouquet arrangements for major holidays
- **Zodiac Influence**: Incorporates astrological elements into flower meanings
- **Cultural Context**: Region-specific holidays influence flower selection
- **Special Occasions**: Creates themed arrangements for celebrations

**Holiday examples:**
```
Valentine's Day → Red rose bouquets
Mother's Day → Mixed spring bouquets
Christmas → Winter holiday arrangements
```

### 5. User History
**What is tracked:**
- Previously discovered species (prevents duplicates)
- Favorite flowers
- Discovery count and dates
- Collection progress

**How it's used:**
- **Duplicate Prevention**: Avoids showing the same species twice
- **Progression Logic**: Introduces rare species as collection grows
- **Personalization**: Considers user preferences and favorites

## Flower Generation Process

### Step 1: Contextual Analysis
The system analyzes current conditions:

```swift
// Example contextual analysis
Location: Lisbon, Portugal (Europe)
Season: Spring (March-May in Northern Hemisphere)  
Weather: Sunny, 22°C
Time: 10:30 AM (Morning)
Date: March 15th, 2024 (Friday)
Holiday: None
Zodiac: Pisces
Previous species: 12 different species discovered
```

### Step 2: Species Selection
Based on context, the system selects from botanical database:

**Priority factors:**
1. **Geographic relevance** (25% of contextual generations)
2. **Seasonal appropriateness**
3. **Species rarity** (increases with collection size)
4. **Uniqueness** (no duplicates)

**Selection logic:**
```
IF contextual_generation_trigger (25% chance):
    SELECT species WHERE continent = user_continent
    AND blooming_season = current_season  
    AND scientific_name NOT IN user_discovered_species
    ORDER BY contextual_relevance
ELSE:
    SELECT random species WHERE scientific_name NOT IN user_discovered_species
```

### Step 3: Prompt Generation  
The selected species data is used to generate the image prompt:

**Species data used:**
- `imagePrompt`: Botanical description for AI image generation
- `scientificName`: Scientific accuracy
- `commonNames`: Familiar naming
- `description`: Visual characteristics
- `rarityLevel`: Influences presentation style

### Step 4: Contextual Enhancement
The flower's meaning and description are enhanced with contextual elements:

**Context injection examples:**
```
Base meaning: "Symbol of pure love and devotion"

With context:
Location: "Inspired by the beauty of Lisbon"
Weather: "Flourishing under clear skies" 
Season: "Blooming in the heart of spring"
Zodiac: "Embodying the spirit of Pisces"

Final meaning: "Symbol of pure love and devotion. Inspired by the beauty of Lisbon. Flourishing under clear skies. Blooming in the heart of spring. Embodying the spirit of Pisces."
```

### Step 5: Metadata Recording
Discovery metadata is recorded:

```swift
discoveryLatitude: 38.7223
discoveryLongitude: -9.1393  
discoveryLocationName: "Lisbon"
discoveryWeatherCondition: "Sunny"
discoveryTemperature: 22.0
discoveryTemperatureUnit: "C" 
discoveryDayOfWeek: "Friday"
discoveryFormattedDate: "15th March 2024"
contextualGeneration: true
generationContext: "Rosa damascena"
```

## Example Generation Scenarios

### Scenario 1: Contextual Spring Flower in Europe

**User Data:**
```
Location: Amsterdam, Netherlands
Date: April 10, 2024, 9:15 AM
Weather: Light rain, 12°C
Season: Spring (Northern Hemisphere)
Discovery count: 5 flowers
```

**Selected Species:**
```javascript
{
  scientificName: "Narcissus poeticus",
  commonNames: ["Poet's Narcissus", "Pheasant's Eye"],
  family: "Amaryllidaceae", 
  continents: ["Europe"],
  bloomingSeason: "Spring",
  rarityLevel: "Common",
  imagePrompt: "Narcissus poeticus poet's narcissus with white petals and small yellow cup with red rim, spring wildflower"
}
```

**Generated Context:**
```
Location context: "Inspired by the beauty of Amsterdam"
Weather context: "Nourished by gentle rain" 
Season context: "Blooming in the heart of spring"
Time context: "Morning discovery"
```

**Final Flower:**
- **Name**: "Poet's Narcissus" 
- **Image**: White narcissus with yellow center (from imagePrompt)
- **Meaning**: "Symbol of rebirth and new beginnings. Inspired by the beauty of Amsterdam. Nourished by gentle rain. Blooming in the heart of spring."
- **Properties**: Spring flowering bulb native to European meadows
- **Discovery location**: Amsterdam, Netherlands
- **Weather**: Light rain, 12°C on Friday, April 10th

### Scenario 2: Holiday Bouquet Generation

**User Data:**  
```
Location: New York, USA
Date: February 14, 2024, 7:30 PM  
Weather: Clear, 8°C
Holiday: Valentine's Day
Discovery count: 23 flowers
```

**Holiday Override:**
```javascript
holiday = {
  name: "Valentine's Day",
  isBouquetWorthy: true,
  bouquetTheme: "romantic red and pink roses with baby's breath"
}
```

**Generated Bouquet:**
- **Name**: "Valentine's Romance Bouquet"
- **Type**: Holiday bouquet (isBouquet: true)
- **Contains**: ["Red Garden Roses", "Pink Spray Roses", "Baby's Breath", "Eucalyptus"]
- **Image**: Romantic bouquet arrangement
- **Meaning**: "A passionate declaration of love, celebrating Valentine's Day"
- **Location**: New York evening discovery

### Scenario 3: Rare Species for Advanced Collector

**User Data:**
```
Location: Kyoto, Japan  
Date: June 22, 2024, 6:45 PM
Weather: Humid, 28°C
Season: Summer
Discovery count: 47 flowers (advanced collector)
```

**Species Selection Logic:**
```
Because user has 47+ discoveries:
- Rare species prioritized (rarityLevel: "Rare" or "Very Rare")  
- Asian native species preferred (continent: Asia)
- Summer blooming species preferred
```

**Selected Rare Species:**
```javascript
{
  scientificName: "Paeonia obovata",
  commonNames: ["Japanese Woodland Peony"],
  family: "Paeoniaceae",
  continents: ["Asia"], 
  bloomingSeason: "Early summer",
  rarityLevel: "Rare",
  imagePrompt: "Paeonia obovata Japanese woodland peony with large pink fragrant flowers, forest understory habitat"
}
```

**Final Rare Flower:**
- **Name**: "Japanese Woodland Peony"
- **Rarity**: Rare species (rare designation shown in UI)
- **Context**: "Inspired by the beauty of Kyoto. Warmed by the sun. Blooming in the heart of summer."
- **Evening discovery in humid summer weather**

## Technical Implementation

### Contextual Generation Rate
- **25% of flowers** use full contextual generation
- **75% are random** selections from botanical database
- Prevents over-dependence on user data while maintaining personalization

### Privacy Considerations
- Location data is used immediately and not stored permanently
- Only discovery location is saved (where flower was found)
- Weather data is captured at moment of generation
- No persistent tracking of user location

### Fallback Mechanisms
- If location is unavailable: Random species selection
- If weather is unavailable: Skip weather context
- If no contextual species match: Random species from database
- Always ensures flower generation succeeds

### Data Accuracy
- Uses real botanical species data (400+ species)
- Scientific names, common names, and native regions are botanically accurate
- Image prompts designed for realistic flower generation
- Conservation status and care instructions are factual

This system creates a unique, personalized flower discovery experience while respecting user privacy and maintaining botanical accuracy.