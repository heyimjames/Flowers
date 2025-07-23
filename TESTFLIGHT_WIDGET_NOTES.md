# TestFlight Notes for Flowers App with Widget Extension

## Widget-Specific Considerations

### Before Upload
1. **Ensure Widget Bundle ID is Correct**
   - Main app: `com.yourname.flowers`
   - Widget: `com.yourname.flowers.widget`
   - Widget must be a child of main app bundle ID

2. **Widget Provisioning**
   - Widget needs its own App ID in Apple Developer portal
   - Automatic signing should handle this if configured correctly

### Testing the Widget
1. **What to Include in "What to Test"**
   - "Please test the Flowers widget on your home screen"
   - "Add the widget in different sizes (small, medium, large)"
   - "Verify daily flower updates in the widget"
   - "Test widget tap actions to open the main app"

2. **Known Widget Testing Limitations**
   - Widgets may take time to appear after app installation
   - Testers should be instructed to:
     - Long press on home screen
     - Tap (+) to add widgets
     - Search for "Flowers" widget
     - Try all available widget sizes

### Common Widget Issues
- **Widget not appearing**: Usually requires device restart after first install
- **Widget not updating**: Check if app has background refresh enabled
- **Widget showing placeholder**: Ensure proper entitlements are set

### TestFlight Widget Feedback
Ask testers specifically about:
- Widget loading time
- Visual appearance on different devices
- Update frequency
- Interaction responsiveness

## Build Configuration
Ensure both targets are included:
1. Main app: `Flowers`
2. Widget extension: `FlowersWidget`

Both should be archived together when creating your build. 