import SwiftUI

struct GiftFlowerSheet: View {
    let flower: AIFlower
    @Binding var userName: String
    let onGiftConfirmed: (String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var recipientName = ""
    @State private var isNameEntered = false
    @State private var showingNamePrompt = false
    @State private var transferDidComplete = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flowerSheetBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Centered flower image and name
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            if let imageData = flower.imageData,
                               let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 280, height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(Color.flowerDivider, lineWidth: 1)
                                    )
                            }
                            
                            Text(flower.name)
                                .font(.system(size: 28, weight: .light, design: .serif))
                                .foregroundColor(.flowerTextPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                    }
                    
                    // Bottom content
                    VStack(spacing: 24) {
                        // Warning message
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.flowerWarning)
                            
                            Text("Gift This Flower?")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Text("Once you gift this flower, it will be permanently removed from your collection and transferred to the recipient.")
                                .font(.system(size: 15))
                                .foregroundColor(.flowerTextSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 24)
                            
                            if flower.hasOwnershipHistory {
                                Text("This flower has \(flower.currentOwnerCount) previous owner\(flower.currentOwnerCount == 1 ? "" : "s"). Its history will be preserved.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextTertiary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        
                        // Your name input (if not set)
                        if userName.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                TextField("Enter your name", text: $userName)
                                    .textFieldStyle(FlowerTextFieldStyle())
                                    .submitLabel(.done)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.words)
                                    .onSubmit {
                                        // Ensure the name is saved
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                
                                Text("This will be shown in the flower's ownership history")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerTextTertiary)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                // Check if user name is set
                                if userName.isEmpty {
                                    showingNamePrompt = true
                                } else {
                                    // Show native share sheet
                                    Task {
                                        await shareFlowerDocument()
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gift")
                                    Text("Gift via AirDrop")
                                }
                            }
                            .flowerButtonStyle()
                            .disabled(userName.isEmpty)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                            }
                            .flowerSecondaryButtonStyle()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Gift Flower")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.flowerTextPrimary)
                }
            }
        }
        .alert("Name Required", isPresented: $showingNamePrompt) {
            Button("OK") { }
        } message: {
            Text("Please enter your name to include in the flower's ownership history.")
        }
        .onDisappear {
            // Only trigger the callback if transfer actually completed
            if transferDidComplete {
                print("Sheet dismissed after successful transfer - removing flower from collection")
                onGiftConfirmed(userName)
            } else {
                print("Sheet dismissed without transfer - keeping flower in collection")
            }
        }
    }
    
    private func shareFlowerDocument() async {
        print("ShareFlowerDocument called - userName: \(userName)")
        do {
            // Get current location
            let locationName = await LocationManager.shared.getCurrentLocationName()
            print("Got location: \(locationName)")
            
            // Export flower
            let fileURL = try FlowerTransferService.shared.exportFlower(
                flower,
                senderName: userName,
                senderLocation: locationName
            )
            
            // Present share sheet
            await MainActor.run {
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                // Configure for AirDrop
                activityVC.excludedActivityTypes = [
                    .postToFacebook,
                    .postToTwitter,
                    .postToWeibo,
                    .message,
                    .mail,
                    .print,
                    .copyToPasteboard,
                    .assignToContact,
                    .saveToCameraRoll,
                    .addToReadingList,
                    .postToFlickr,
                    .postToVimeo,
                    .postToTencentWeibo,
                    .markupAsPDF,
                    .openInIBooks
                ]
                
                // Completion handler
                activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                    print("Activity completion: type=\(String(describing: activityType)), completed=\(completed), error=\(String(describing: error))")
                    
                    // Clean up temporary files first
                    FlowerTransferService.shared.cleanupTemporaryFiles()
                    
                    // Check if transfer actually completed
                    if completed && error == nil && activityType != nil {
                        // Gift was successfully sent via a specific activity (not cancelled)
                        print("Gift completed successfully via \(activityType!)")
                        
                        // Check if it was actually sent via AirDrop or another sharing method
                        let airdropType = UIActivity.ActivityType(rawValue: "com.apple.UIKit.activity.AirDrop")
                        if activityType == airdropType || activityType == .mail || activityType == .message {
                            transferDidComplete = true
                            print("Transfer confirmed via recognized activity type")
                        }
                        
                        // Dismiss after marking completion
                        dismiss()
                    } else if completed == false || activityType == nil {
                        // User cancelled or no activity was selected
                        print("Gift cancelled by user or no activity selected")
                        // Just dismiss without removing flower
                        dismiss()
                    } else if let error = error {
                        print("Gift failed with error: \(error)")
                        // Just dismiss without removing flower
                        dismiss()
                    }
                }
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    // Find the topmost presented view controller
                    var topViewController = rootViewController
                    while let presented = topViewController.presentedViewController {
                        topViewController = presented
                    }
                    topViewController.present(activityVC, animated: true)
                }
            }
        } catch {
            print("Failed to prepare flower for transfer: \(error)")
        }
    }
} 