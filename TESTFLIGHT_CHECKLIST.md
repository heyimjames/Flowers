# TestFlight Upload Checklist for Flowers App

## Pre-Upload Checklist
- [ ] Apple Developer Account active ($99/year)
- [ ] Latest version of Xcode installed
- [ ] Bundle identifier created in Apple Developer portal
- [ ] App icons added (all required sizes)
- [ ] Launch screen configured
- [ ] Info.plist permissions descriptions added

## In Xcode
- [ ] Select "Any iOS Device" (not simulator)
- [ ] Update version number (e.g., 1.0)
- [ ] Update build number (increment for each upload)
- [ ] Enable "Automatically manage signing"
- [ ] Select your team in Signing & Capabilities
- [ ] Product → Archive
- [ ] In Organizer: Distribute App → App Store Connect → Upload

## In App Store Connect
- [ ] Wait for processing email (20-30 mins)
- [ ] Go to TestFlight tab
- [ ] Add Test Information:
  - [ ] What to Test description
  - [ ] App Description
  - [ ] Feedback email
  - [ ] Contact information
  - [ ] Mark if sign-in required

## For Internal Testing
- [ ] Add internal testers (up to 100)
- [ ] Send invitations
- [ ] No Apple review needed

## For External Testing
- [ ] First build requires Apple review (24-48 hours)
- [ ] Choose testing method:
  - [ ] Individual invites (email required)
  - [ ] Public link (no emails needed)
- [ ] Set tester criteria (optional)
- [ ] Add up to 10,000 testers

## Post-Upload
- [ ] Monitor feedback in TestFlight
- [ ] Check crash reports
- [ ] Update build based on feedback
- [ ] Remember: builds expire after 90 days

## Important Notes
- Build numbers must increase with each upload
- Keep version number same during beta testing
- First external build needs Apple review
- Subsequent builds often skip review
- Testers need TestFlight app installed

## Quick Links
- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com)
- [TestFlight for Testers](https://testflight.apple.com) 