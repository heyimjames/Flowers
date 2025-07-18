# Alternate App Icon Setup Instructions

## ✅ What I've Done

1. **Created alternate icon files** in the correct location:
   - `Flowers/AppIcon2@2x.png` (120x120px for iPhone)
   - `Flowers/AppIcon2@3x.png` (180x180px for iPhone)
   - `Flowers/AppIcon2-76@2x.png` (152x152px for iPad)
   - `Flowers/AppIcon2-83.5@2x.png` (167x167px for iPad Pro)

2. **Updated Info.plist** with the correct configuration for alternate icons

## 🔧 What You Need to Do in Xcode

1. **Add the icon files to your Xcode project:**
   - Open your project in Xcode
   - Right-click on the "Flowers" folder in the project navigator
   - Select "Add Files to 'Flowers'..."
   - Navigate to the Flowers folder and select these files:
     - AppIcon2@2x.png
     - AppIcon2@3x.png
     - AppIcon2-76@2x.png
     - AppIcon2-83.5@2x.png
   - Make sure "Copy items if needed" is UNCHECKED (files are already in place)
   - Make sure "Add to targets: Flowers" is CHECKED
   - Click "Add"

2. **Important: Set Build Phase**
   - Select your project in the navigator
   - Select the "Flowers" target
   - Go to "Build Phases" tab
   - Expand "Copy Bundle Resources"
   - Verify all 4 AppIcon2 files are listed there
   - If not, click the "+" button and add them

3. **Clean and rebuild:**
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

## 🧪 Testing

After building:
1. Run the app on a device or simulator
2. Go to Settings in the app
3. Try switching to the alternate app icon
4. The icon should change immediately

## 📝 Notes

- Alternate app icons must be PNG files at the root level of the app bundle
- They cannot be in Asset Catalogs (.xcassets)
- The naming convention must match what's in Info.plist
- iOS will show a system alert when changing icons - this is normal

## 🐛 Troubleshooting

If the icon change fails:
1. Check the device console for errors
2. Verify the files are in "Copy Bundle Resources"
3. Ensure the Info.plist CFBundleAlternateIcons configuration is correct
4. Try deleting the app and reinstalling 