# WeatherKit Setup Guide

If you're seeing the error "weatherdaemon.wdsjwtauthenticationserviceproxy.errors error0" when trying to fetch weather, it means WeatherKit isn't properly configured for your app.

## Requirements

WeatherKit requires:
1. An active Apple Developer account
2. WeatherKit capability enabled in your app
3. WeatherKit service enabled in your App ID
4. A valid provisioning profile

## Setup Steps

### 1. Enable WeatherKit in Xcode

1. Open your project in Xcode
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Search for and add "WeatherKit"

### 2. Enable WeatherKit Service on Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Click on "Identifiers" and find your app's App ID
4. Edit the App ID
5. Check "WeatherKit" under Capabilities
6. Save changes

### 3. Update Provisioning Profile

1. After enabling WeatherKit, you need to regenerate your provisioning profile
2. In Xcode, go to Preferences > Accounts
3. Select your team and click "Download Manual Profiles"
4. Or create a new provisioning profile on the developer portal

### 4. Add WeatherKit to Entitlements

The WeatherKit capability should automatically add the necessary entitlements, but verify that your `Flowers.entitlements` file includes:

```xml
<key>com.apple.developer.weatherkit</key>
<true/>
```

## Fallback Behavior

The app now includes fallback weather estimation when WeatherKit is unavailable:

- For custom flower generation, it will use estimated weather based on:
  - Current season
  - Location latitude (hemisphere)
  - Time of year
  
- The app will show "Using estimated weather (WeatherKit unavailable)" when using fallback data

## Testing

After completing setup:
1. Clean build folder (Shift+Cmd+K)
2. Delete the app from your device/simulator
3. Build and run again
4. Try the weather fetch again

## Note for TestFlight

WeatherKit should work in TestFlight builds as long as:
- The capability is properly configured
- You're using a valid provisioning profile
- The App ID has WeatherKit service enabled

## Alternative Solutions

If you can't use WeatherKit (e.g., no paid developer account), you could:
1. Use the built-in fallback weather estimation
2. Integrate a different weather API (would require code changes)
3. Allow manual weather input only 