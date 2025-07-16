import SwiftUI

struct ReceivedFlowerSheet: View {
    let flower: AIFlower
    let sender: FlowerOwner
    let onAccept: () -> Void
    let onReject: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flowerSheetBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Gift icon animation
                        Image(systemName: "gift.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.flowerPrimary)
                            .scaleEffect(1.1)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: UUID()
                            )
                            .padding(.top, 16)
                        
                        // Title
                        VStack(spacing: 8) {
                            Text("You've Received a Flower!")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Text("From \(sender.name)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                            
                            if let location = sender.location {
                                Text("\(location) • \(sender.transferDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerTextTertiary)
                            }
                        }
                        
                        // Flower preview
                        VStack(spacing: 16) {
                            if let imageData = flower.imageData,
                               let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(Color.flowerDivider, lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                            }
                            
                            Text(flower.name)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            if let meaning = flower.meaning {
                                Text(meaning)
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                    .padding(.horizontal, 32)
                            }
                        }
                        
                        // Ownership history info
                        if flower.hasOwnershipHistory {
                            VStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerPrimary)
                                    Text("This flower has been owned by \(flower.currentOwnerCount) people")
                                        .font(.system(size: 13))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                                
                                if let original = flower.originalOwner {
                                    Text("Originally grown by \(original.name)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextTertiary)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                onAccept()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Accept Flower")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.flowerPrimary)
                                .cornerRadius(16)
                            }
                            
                            Button(action: {
                                onReject()
                                dismiss()
                            }) {
                                Text("Decline")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.flowerTextSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.flowerButtonBackground)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Flower Gift")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.flowerTextPrimary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
    }
} 