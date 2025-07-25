# Permissions Guide

## WeatherKit Permissions

**WeatherKit itself does NOT require explicit user permission.** Once configured with the proper capability and entitlements, it works automatically.

However, WeatherKit uses location data to provide accurate weather, so we need location permissions.

## Required Permissions

### 1. Location Permission (Required for Weather)
- **Key**: `NSLocationWhenInUseUsageDescription`
- **When Requested**: During onboarding or when generating contextual flowers
- **Purpose**: To get local weather data for flower generation
- **User sees**: "Your location helps create unique flowers based on your local weather and special regional varieties"

### 2. Notification Permission
- **Key**: `NSUserNotificationsUsageDescription`
- **When Requested**: After onboarding completes
- **Purpose**: To notify users when daily flowers are ready
- **User sees**: "Get notified when your daily flower blooms"

### 3. Photo Library Permission
- **Key**: `NSPhotoLibraryAddUsageDescription`
- **When Requested**: When user tries to save a flower to photos
- **Purpose**: To save flower images to the photo library
- **User sees**: "Save your favorite flowers to your photo library to share with friends"

## Permission Flow

1. **Onboarding**: Location permission is requested during onboarding (page 2)
2. **After Onboarding**: Notification permission is requested
3. **On Demand**: Photo library permission is requested when user first tries to save a flower

## If Permissions Are Denied

- **Location Denied**: 
  - Flowers still work but without real weather data
  - Generic seasonal flowers are generated instead
  - Custom location selection still works for manual weather

- **Notifications Denied**: 
  - Users won't get push notifications
  - They need to manually check the app for new flowers

- **Photo Library Denied**: 
  - Saving to photos won't work
  - Users can still share flowers through the share sheet

## Testing Permissions

1. **Reset permissions** on simulator/device:
   - Settings > General > Reset > Reset Location & Privacy

2. **Test each flow**:
   - Fresh install → Onboarding → Location request
   - Complete onboarding → Notification request  
   - Save flower → Photo library request

## Important Notes

- All permission strings must be in Info.plist before the app tries to request them
- Missing permission strings will cause the app to crash
- Permission strings should be user-friendly and explain the benefit 