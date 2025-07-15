import SwiftUI

struct GeneratorSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDescriptor: String?
    @State private var isCreating = false
    
    let descriptors = [
        "crystal rose with translucent petals",
        "moonlight orchid with silver edges",
        "stardust lily with glowing center",
        "aurora dahlia with rainbow gradients",
        "velvet iris with deep purple hues",
        "mystic blossom with ethereal glow",
        "celestial bloom with star patterns",
        "ethereal petal with soft pastels"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                Text("Find New Flower")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.flowerTextPrimary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                
                Spacer()
                
                // Preview area
                ZStack {
                    if let flower = flowerStore.currentFlower,
                       let imageData = flower.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .opacity(0.3)
                            .blur(radius: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.flowerCardBackground)
                    }
                    
                    if isCreating {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.flowerPrimary)
                                .scaleEffect(1.5)
                            Text("Finding your flower...")
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(.flowerPrimary.opacity(0.5))
                    }
                }
                .frame(height: 300)
                .padding(.horizontal, 24)
                
                // Surprise Me text
                Text("🌸 Discover")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.flowerTextSecondary)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                Text("Pick a unique flower from nature's hidden garden")
                    .font(.system(size: 14))
                    .foregroundColor(.flowerTextTertiary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Create button
                Button(action: createFlower) {
                    Text("Pick Flower")
                }
                .buttonStyle(FlowerPrimaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .disabled(isCreating)
            }
            .background(Color.flowerSheetBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.flowerPrimary)
                }
            }
        }
    }
    
    private func createFlower() {
        isCreating = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        Task {
            // Always use surprise me (nil descriptor)
            await flowerStore.generateNewFlower(descriptor: nil)
            isCreating = false
            dismiss()
        }
    }
} 