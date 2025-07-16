import SwiftUI
import Photos

struct FavoritesSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlower: AIFlower?
    @State private var showingDetail = false
    @State private var showFavoritesOnly = false
    @State private var sortOption: SortOption = .newestFirst
    
    enum SortOption: String, CaseIterable {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"
        case nameAZ = "Name (A-Z)"
        case nameZA = "Name (Z-A)"
        case favoritesFirst = "Favorites First"
        
        var icon: String {
            switch self {
            case .newestFirst: return "arrow.down.circle"
            case .oldestFirst: return "arrow.up.circle"
            case .nameAZ: return "textformat.abc"
            case .nameZA: return "textformat.abc.dottedunderline"
            case .favoritesFirst: return "heart.circle"
            }
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var displayedFlowers: [AIFlower] {
        let flowers = showFavoritesOnly ? flowerStore.favorites : flowerStore.discoveredFlowers
        
        switch sortOption {
        case .newestFirst:
            return flowers.sorted { 
                ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
            }
        case .oldestFirst:
            return flowers.sorted { 
                ($0.discoveryDate ?? $0.generatedDate) < ($1.discoveryDate ?? $1.generatedDate) 
            }
        case .nameAZ:
            return flowers.sorted { $0.name < $1.name }
        case .nameZA:
            return flowers.sorted { $0.name > $1.name }
        case .favoritesFirst:
            return flowers.sorted { flower1, flower2 in
                if flower1.isFavorite == flower2.isFavorite {
                    return (flower1.discoveryDate ?? flower1.generatedDate) > (flower2.discoveryDate ?? flower2.generatedDate)
                }
                return flower1.isFavorite && !flower2.isFavorite
            }
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
                        .font(.system(size: 28, weight: .light, design: .serif))
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
                    
                    // Filter toggle and sort menu
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
                        
                        // Sort menu
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { sortOption = option }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: sortOption.icon)
                                    .font(.system(size: 14))
                                Text("Sort")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.flowerPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.flowerPrimary.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
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
                        VStack(spacing: 20) {
                            Image(systemName: showFavoritesOnly ? "heart.slash" : "flower")
                                .font(.system(size: 60))
                                .foregroundColor(.flowerTextTertiary)
                            
                            Text(showFavoritesOnly ? "No favorites yet" : "Your collection is empty")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.flowerTextPrimary)
                            
                            if showFavoritesOnly {
                                Text("Tap the heart on flowers you love")
                                    .font(.system(size: 16))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Start your journey by discovering flowers")
                                    .font(.system(size: 16))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 100)
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
                FlowerDetailSheet(
                    flower: flower,
                    flowerStore: flowerStore,
                    allFlowers: displayedFlowers,
                    currentIndex: displayedFlowers.firstIndex(where: { $0.id == flower.id }) ?? 0
                )
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.visible)
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
    @State private var flower: AIFlower
    @ObservedObject var flowerStore: FlowerStore
    let allFlowers: [AIFlower]
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var isLoadingDetails = false
    @State private var detailsError: String?
    @State private var saveImageAlert = false
    @State private var saveImageSuccess = false
    
    init(flower: AIFlower, flowerStore: FlowerStore, allFlowers: [AIFlower], currentIndex: Int) {
        self._flower = State(initialValue: flower)
        self.flowerStore = flowerStore
        self.allFlowers = allFlowers
        self._currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                TabView(selection: $currentIndex) {
                    ForEach(Array(allFlowers.enumerated()), id: \.element.id) { index, flowerItem in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Flower image with soft blend
                                if let imageData = flowerItem.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    ZStack {
                                        // Soft white gradient for edge blending
                                        RadialGradient(
                                            colors: [Color.white.opacity(0), Color.white],
                                            center: .center,
                                            startRadius: UIScreen.main.bounds.width * 0.4,
                                            endRadius: UIScreen.main.bounds.width * 0.6
                                        )
                                        .frame(height: UIScreen.main.bounds.width)
                                        
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [Color.white.opacity(0.8), Color.white.opacity(0)],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.top, 20)
                                }
                                
                                // Navigation indicators
                                if allFlowers.count > 1 {
                                    HStack(spacing: 16) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(index > 0 ? .gray : .gray.opacity(0.3))
                                        
                                        Text("\(index + 1) of \(allFlowers.count)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(index < allFlowers.count - 1 ? .gray : .gray.opacity(0.3))
                                    }
                                    .padding(.top, 16)
                                }
                                
                                // Flower name and basic info
                                VStack(spacing: 8) {
                                    Text(flowerItem.name)
                                        .font(.system(size: 32, weight: .regular, design: .serif))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    if flowerItem.isBouquet, let holidayName = flowerItem.holidayName {
                                        HStack(spacing: 6) {
                                            Image(systemName: "gift.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.flowerSecondary)
                                            Text("Special \(holidayName) Collection")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.flowerTextSecondary)
                                        }
                                        .padding(.bottom, 4)
                                    }
                                    
                                    HStack(spacing: 16) {
                                        if let continent = flowerItem.continent {
                                            Label(flowerItem.isBouquet ? "Tradition from \(continent.rawValue)" : continent.rawValue, systemImage: "globe")
                                                .font(.system(size: 14))
                                                .foregroundColor(.flowerTextSecondary)
                                        }
                                        
                                        Label {
                                            Text(flowerItem.generatedDate, style: .date)
                                        } icon: {
                                            Image(systemName: "calendar")
                                        }
                                        .font(.system(size: 14))
                                        .foregroundColor(.flowerTextSecondary)
                                    }
                                }
                                .padding(.top, allFlowers.count > 1 ? 12 : 24)
                                .padding(.horizontal, 24)
                                
                                // Detailed information sections
                                if flowerItem.meaning != nil || flowerItem.properties != nil || flowerItem.origins != nil || flowerItem.bouquetFlowers != nil {
                                    VStack(alignment: .leading, spacing: 20) {
                                        if flowerItem.isBouquet, let bouquetFlowers = flowerItem.bouquetFlowers {
                                            DetailSection(
                                                title: "Bouquet Contains",
                                                content: bouquetFlowers.joined(separator: " • "),
                                                icon: "leaf.circle"
                                            )
                                        }
                                        
                                        if let meaning = flowerItem.meaning {
                                            DetailSection(
                                                title: flowerItem.isBouquet ? "Holiday Significance" : "Meaning",
                                                content: meaning,
                                                icon: "book"
                                            )
                                        }
                                        
                                        if let properties = flowerItem.properties {
                                            DetailSection(
                                                title: flowerItem.isBouquet ? "Arrangement Details" : "Characteristics",
                                                content: properties,
                                                icon: flowerItem.isBouquet ? "sparkles" : "leaf"
                                            )
                                        }
                                        
                                        if let origins = flowerItem.origins {
                                            DetailSection(
                                                title: flowerItem.isBouquet ? "Holiday Traditions" : "Origins",
                                                content: origins,
                                                icon: flowerItem.isBouquet ? "gift" : "map"
                                            )
                                        }
                                        
                                        if let description = flowerItem.detailedDescription {
                                            DetailSection(
                                                title: "Description",
                                                content: description,
                                                icon: "text.alignleft"
                                            )
                                        }
                                    }
                                    .padding(.top, 32)
                                    .padding(.horizontal, 24)
                                } else if index == currentIndex && isLoadingDetails {
                                    // Loading state - only show for current flower
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .tint(.flowerPrimary)
                                        Text("Discovering flower details...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                    .padding(.vertical, 40)
                                } else if index == currentIndex && detailsError != nil {
                                    // Error state - only show for current flower
                                    VStack(spacing: 16) {
                                        Image(systemName: "exclamationmark.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(.flowerError)
                                        Text("Failed to load details")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.flowerError)
                                        if let error = detailsError {
                                            Text(error)
                                                .font(.system(size: 14))
                                                .foregroundColor(.flowerTextSecondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        
                                        Button(action: loadFlowerDetails) {
                                            Text("Retry")
                                        }
                                        .buttonStyle(FlowerButtonStyle())
                                    }
                                    .padding(.vertical, 40)
                                    .padding(.horizontal, 24)
                                } else if flowerItem.meaning == nil && flowerItem.properties == nil {
                                    // No details yet - show button to load
                                    VStack(spacing: 16) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 40))
                                            .foregroundColor(.flowerPrimary.opacity(0.5))
                                        Text("Discover more about this flower")
                                            .font(.system(size: 16))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        Button(action: {
                                            flower = flowerItem
                                            loadFlowerDetails()
                                        }) {
                                            Text("Reveal Details")
                                        }
                                        .buttonStyle(FlowerButtonStyle())
                                    }
                                    .padding(.vertical, 40)
                                    .padding(.horizontal, 24)
                                }
                                
                                // Discovery location map (shown independently of other details)
                                if flowerItem.discoveryLatitude != nil && flowerItem.discoveryLongitude != nil {
                                    FlowerMapView(flower: flowerItem, showCoordinates: false)
                                        .padding(.top, 20)
                                        .padding(.horizontal, 24)
                                }
                                
                                // Extra bottom padding to prevent clipping
                                Color.clear.frame(height: 250)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentIndex) { newIndex in
                    // Update flower when swiping
                    if newIndex >= 0 && newIndex < allFlowers.count {
                        flower = allFlowers[newIndex]
                        // Reset states for new flower
                        isLoadingDetails = false
                        detailsError = nil
                    }
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                // Gradient fade with action buttons
                VStack(spacing: 0) {
                    // Multi-layer gradient for smooth fade
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.85),
                            Color.white.opacity(0.95),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .allowsHitTesting(false)
                    
                    // Action buttons
                    VStack(spacing: 12) {
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
                            .accessibilityLabel("Share flower image")
                        }
                        
                        // Discard button
                        Button(action: { showingDeleteAlert = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles.slash")
                                    .font(.system(size: 16))
                                Text("Return to Garden")
                                    .font(.system(size: 15))
                            }
                            .foregroundColor(.flowerTextSecondary)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .background(Color.white)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .alert("Return to Garden?", isPresented: $showingDeleteAlert) {
            Button("Keep Flower", role: .cancel) { }
            Button("Return to Garden", role: .destructive) {
                flowerStore.deleteFlower(flower)
                dismiss()
            }
        } message: {
            Text("This flower will be returned to the garden and removed from your collection.")
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
                let details = try await OpenAIService.shared.generateFlowerDetails(for: flower, context: nil)
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
        
        var shareText = "🌸 \(flower.name)"
        if let meaning = flower.meaning {
            shareText += "\n\n\(meaning)"
        }
        shareText += "\n\nDiscovered with Flowers app"
        
        let activityVC = UIActivityViewController(
            activityItems: [image, shareText],
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
                    .font(.system(size: 18, weight: .light, design: .serif))
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