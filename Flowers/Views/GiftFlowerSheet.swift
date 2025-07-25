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
                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Flower image and name
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
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 20)
                            // Warning message
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.flowerWarning)
                                
                                Text("Gift This Flower?")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                Text("When you share this flower, it will leave your collection and go to your friend. It becomes theirs to keep!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 24)
                                
                                if flower.hasOwnershipHistory {
                                    Text("This flower has been shared \(flower.currentOwnerCount) time\(flower.currentOwnerCount == 1 ? "" : "s") before. Your friend will see its complete story.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.flowerTextTertiary)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.horizontal, 24)
                                }
                            }
                        
                            // Instructions for recipient with simplified share sheet preview
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.flowerPrimary)
                                    Text("How Your Friend Gets the Flower")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("1.")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.flowerPrimary)
                                        Text("They'll get a flower file when you share it")
                                            .font(.system(size: 13))
                                            .foregroundColor(.flowerTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer()
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("2.")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.flowerPrimary)
                                        Text("They tap the Share button on the file they receive")
                                            .font(.system(size: 13))
                                            .foregroundColor(.flowerTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer()
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("3.")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.flowerPrimary)
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Then they choose the Flowers app to add it to their collection")
                                                .font(.system(size: 13))
                                                .foregroundColor(.flowerTextSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            // Simplified iOS Share Sheet Preview
                                            SimplifiedShareSheetPreview(flowerName: flower.name)
                                        }
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.vertical, 16)
                            .background(Color.flowerPrimary.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                        
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
                                    
                                    Text("Your friend will see that this flower came from you")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextTertiary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // Extra padding at bottom to ensure content doesn't get hidden behind fixed buttons
                            Color.clear.frame(height: 120)
                        }
                        .padding(.bottom, 24)
                    }
                    
                    // Fixed buttons at bottom
                    VStack(spacing: 0) {
                        // Gradient overlay to blend with content
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.flowerSheetBackground.opacity(0), location: 0),
                                .init(color: Color.flowerSheetBackground.opacity(0.8), location: 0.3),
                                .init(color: Color.flowerSheetBackground, location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)
                        .allowsHitTesting(false)
                        
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
                                    Text("Share This Flower")
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
                        .background(Color.flowerSheetBackground)
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
            Text("Please enter your name so your friend knows who shared this flower with them.")
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

// MARK: - Simplified Share Sheet Preview
struct SimplifiedShareSheetPreview: View {
    let flowerName: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Mock iOS share sheet appearance
            VStack(spacing: 16) {
                // File preview header
                HStack(spacing: 12) {
                    // File icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.flowerPrimary.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image("FlowersSVG")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    
                    // File info
                    VStack(alignment: .leading, spacing: 3) {
                        Text(flowerName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.flowerTextPrimary)
                        Text("Flower Document • 302 KB")
                            .font(.system(size: 13))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // App selection grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        // AirDrop
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 60, height: 60)
                            Text("AirDrop")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        // Flowers app (highlighted) - moved to 2nd position
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.flowerPrimary.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Image("AppIcon2Preview")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Text("Flowers")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.flowerPrimary)
                        }
                        
                        // Slack
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 60, height: 60)
                            Text("Slack")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        // WhatsApp
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 60, height: 60)
                            Text("WhatsApp")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        // Discord
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 60, height: 60)
                            Text("Discord")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100)
                
                // Additional options
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        Text("Copy")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerTextPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    
                    Divider()
                    
                    HStack {
                        Text("Save to Files")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerTextPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
            )
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .bold))
                Text("Tell your friend to Tap the Flowers app icon")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.flowerPrimary)
            .padding(.top, 4)
        }
    }
} 