import SwiftUI
import Photos

struct FavoritesSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlower: AIFlower?
    @State private var showingDetail = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Collection")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.flowerTextPrimary)
                        
                        Text("\(flowerStore.totalDiscoveredCount) flowers discovered")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.flowerPrimary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Continent stats
                if !flowerStore.continentStats.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Continent.allCases, id: \.self) { continent in
                                if let count = flowerStore.continentStats[continent], count > 0 {
                                    VStack(spacing: 4) {
                                        Text("\(count)")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.flowerPrimary)
                                        Text(continent.rawValue)
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.flowerPrimary.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 16)
                }
                
                if flowerStore.favorites.isEmpty {
                    // Empty state
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "heart.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.flowerTextTertiary)
                        
                        Text("No favorites yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.flowerTextSecondary)
                        
                        Text("Tap the heart to save flowers")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextTertiary)
                    }
                    
                    Spacer()
                } else {
                    // Favorites grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(flowerStore.favorites) { flower in
                                FlowerGridItem(flower: flower) {
                                    selectedFlower = flower
                                    showingDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Color.flowerSheetBackground)
        }
        .sheet(isPresented: $showingDetail) {
            if let flower = selectedFlower {
                FlowerDetailSheet(flower: flower, flowerStore: flowerStore)
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
            }
        }
    }
}

struct FlowerGridItem: View {
    let flower: AIFlower
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let imageData = flower.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.flowerCardBackground)
                        .aspectRatio(1, contentMode: .fit)
                }
                
                Text(flower.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.flowerTextPrimary)
                    .lineLimit(1)
            }
        }
    }
}

struct FlowerDetailSheet: View {
    let flower: AIFlower
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var isLoadingDetails = false
    @State private var detailsError: String?
    @State private var saveImageAlert = false
    @State private var saveImageSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Flower image
                    if let imageData = flower.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    }
                    
                    // Flower name and basic info
                    VStack(spacing: 8) {
                        Text(flower.name)
                            .font(.system(size: 32, weight: .medium, design: .serif))
                            .foregroundColor(.flowerTextPrimary)
                        
                        HStack(spacing: 16) {
                            if let continent = flower.continent {
                                Label(continent.rawValue, systemImage: "globe")
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                            
                            Label {
                                Text(flower.generatedDate, style: .date)
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    
                    // Detailed information sections
                    if flower.meaning != nil || flower.properties != nil || flower.origins != nil {
                        VStack(alignment: .leading, spacing: 20) {
                            if let meaning = flower.meaning {
                                DetailSection(
                                    title: "Meaning",
                                    content: meaning,
                                    icon: "heart.text.square"
                                )
                            }
                            
                            if let properties = flower.properties {
                                DetailSection(
                                    title: "Properties",
                                    content: properties,
                                    icon: "sparkles"
                                )
                            }
                            
                            if let origins = flower.origins {
                                DetailSection(
                                    title: "Origins",
                                    content: origins,
                                    icon: "map"
                                )
                            }
                            
                            if let description = flower.detailedDescription {
                                DetailSection(
                                    title: "Description",
                                    content: description,
                                    icon: "text.alignleft"
                                )
                            }
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, 24)
                    } else if isLoadingDetails {
                        // Loading state
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.flowerPrimary)
                            Text("Discovering flower details...")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextSecondary)
                        }
                        .padding(.vertical, 40)
                    } else if let error = detailsError {
                        // Error state
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.flowerError)
                            Text("Failed to load details")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.flowerError)
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: loadFlowerDetails) {
                                Text("Retry")
                            }
                            .buttonStyle(FlowerButtonStyle())
                        }
                        .padding(.vertical, 40)
                        .padding(.horizontal, 24)
                    } else {
                        // No details yet - show button to load
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundColor(.flowerPrimary.opacity(0.5))
                            Text("Discover more about this flower")
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary)
                            
                            Button(action: loadFlowerDetails) {
                                Text("Reveal Details")
                            }
                            .buttonStyle(FlowerButtonStyle())
                        }
                        .padding(.vertical, 40)
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.flowerError)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.flowerPrimary)
                }
            }
            .overlay(alignment: .bottom) {
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: saveToPhotos) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save Image")
                        }
                    }
                    .buttonStyle(FlowerButtonStyle())
                    
                    Button(action: shareFlower) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                            .foregroundColor(.flowerTextSecondary)
                            .frame(width: 56, height: 56)
                            .background(Color.flowerButtonBackground)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [
                            Color.flowerSheetBackground.opacity(0),
                            Color.flowerSheetBackground,
                            Color.flowerSheetBackground
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .ignoresSafeArea()
                )
            }
        }
        .alert("Delete Flower?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                flowerStore.deleteFavorite(flower)
                dismiss()
            }
        } message: {
            Text("This flower will be removed from your favorites.")
        }
        .alert(saveImageSuccess ? "Image Saved!" : "Permission Required", isPresented: $saveImageAlert) {
            Button("OK") { }
        } message: {
            if saveImageSuccess {
                Text("The flower image has been saved to your photo library.")
            } else {
                Text("Please allow photo library access in Settings to save images.")
            }
        }
        .onAppear {
            // Load details if not already loaded
            if flower.meaning == nil {
                loadFlowerDetails()
            }
        }
    }
    
    private func loadFlowerDetails() {
        isLoadingDetails = true
        detailsError = nil
        
        Task {
            do {
                let details = try await OpenAIService.shared.generateFlowerDetails(for: flower)
                flowerStore.updateFlowerDetails(flower, with: details)
                isLoadingDetails = false
            } catch {
                detailsError = error.localizedDescription
                isLoadingDetails = false
            }
        }
    }
    
    private func saveToPhotos() {
        guard let imageData = flower.imageData,
              let image = UIImage(data: imageData) else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        saveImageSuccess = success
                        saveImageAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    saveImageSuccess = false
                    saveImageAlert = true
                }
            }
        }
    }
    
    private func shareFlower() {
        guard let imageData = flower.imageData,
              let image = UIImage(data: imageData) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image, flower.name],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            // Get the presented view controller (the sheet)
            if let presentedVC = rootVC.presentedViewController {
                presentedVC.present(activityVC, animated: true)
            }
        }
    }
}

struct DetailSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.flowerPrimary)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.flowerTextSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
} 