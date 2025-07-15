import SwiftUI
import Photos

struct FavoritesSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlower: AIFlower?
    @State private var showingDetail = false
    @State private var showFavoritesOnly = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var displayedFlowers: [AIFlower] {
        if showFavoritesOnly {
            return flowerStore.favorites
        } else {
            return flowerStore.discoveredFlowers
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.flowerSheetBackground.ignoresSafeArea()
                
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
                    
                    // Filter toggle
                    HStack(spacing: 12) {
                        FilterButton(
                            title: "All Flowers",
                            count: flowerStore.totalDiscoveredCount,
                            isSelected: !showFavoritesOnly,
                            action: { showFavoritesOnly = false }
                        )
                        
                        FilterButton(
                            title: "Favorites",
                            count: flowerStore.favorites.count,
                            isSelected: showFavoritesOnly,
                            action: { showFavoritesOnly = true }
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    
                    // Continent stats
                    if !showFavoritesOnly && !flowerStore.continentStats.isEmpty {
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
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.flowerPrimary.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if displayedFlowers.isEmpty {
                        // Empty state
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: showFavoritesOnly ? "heart.circle" : "sparkles.rectangle.stack")
                                .font(.system(size: 64))
                                .foregroundColor(.flowerTextTertiary)
                            
                            Text(showFavoritesOnly ? "No favorites yet" : "No flowers discovered yet")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                            
                            Text(showFavoritesOnly ? "Tap the heart to save flowers" : "Generate flowers to start your collection")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextTertiary)
                        }
                        
                        Spacer()
                    } else {
                        // Flowers grid
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(displayedFlowers) { flower in
                                    FlowerGridItem(flower: flower, isFavorite: flower.isFavorite) {
                                        selectedFlower = flower
                                        showingDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                        .refreshable {
                            // Reload the discovered flowers and favorites
                            await refreshCollection()
                        }
                    }
                }
            }
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
    
    private func refreshCollection() async {
        // Add a small delay to show the refresh indicator
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Reload favorites and discovered flowers from storage
        await MainActor.run {
            flowerStore.refreshCollection()
        }
    }
}

struct FilterButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.2) : Color.flowerTextTertiary.opacity(0.1))
                    )
            }
            .foregroundColor(isSelected ? .flowerPrimary : .flowerTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.flowerPrimary.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isSelected ? Color.flowerPrimary.opacity(0.3) : Color.flowerTextTertiary.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

struct FlowerGridItem: View {
    let flower: AIFlower
    let isFavorite: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
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
                    
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerSecondary)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                            )
                            .padding(8)
                    }
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
                                    icon: "book"
                                )
                            }
                            
                            if let properties = flower.properties {
                                DetailSection(
                                    title: "Characteristics",
                                    content: properties,
                                    icon: "leaf"
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
                    
                    Spacer(minLength: 160)
                }
            }
            .background(Color.flowerSheetBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.flowerError)
                    }
                    .padding(.leading, 8)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.flowerPrimary)
                    .font(.system(size: 17, weight: .medium))
                    .padding(.trailing, 8)
                }
            }
            .overlay(alignment: .bottom) {
                // Gradient fade with action buttons
                VStack(spacing: 0) {
                    // Multi-layer gradient for smooth fade
                    LinearGradient(
                        colors: [
                            Color.flowerSheetBackground.opacity(0),
                            Color.flowerSheetBackground.opacity(0.3),
                            Color.flowerSheetBackground.opacity(0.6),
                            Color.flowerSheetBackground.opacity(0.85),
                            Color.flowerSheetBackground.opacity(0.95),
                            Color.flowerSheetBackground
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: saveToPhotos) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 18))
                                Text("Save Image")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.flowerPrimary)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.flowerPrimary.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Button(action: shareFlower) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.flowerPrimary)
                                .frame(width: 52, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.flowerPrimary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .background(Color.flowerSheetBackground)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .alert("Delete Flower?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                flowerStore.deleteFlower(flower)
                dismiss()
            }
        } message: {
            Text("This flower will be permanently removed from your collection.")
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