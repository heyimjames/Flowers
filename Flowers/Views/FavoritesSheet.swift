import SwiftUI
import Photos

struct FavoritesSheet: View {
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlower: AIFlower?
    @State private var showingDetail = false
    @State private var showFavoritesOnly = false
    @State private var sortOption: SortOption = .newestFirst
    @State private var showingProgressSheet = false
    
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
                        Text("My Collection")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(.flowerTextPrimary)
                        
                        Spacer()
                        
                        Button("Done") {
                            dismiss()
                        }
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.flowerPrimary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Filter pills and sort menu
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterButton(
                                    title: "All Flowers",
                                    count: flowerStore.totalDiscoveredCount,
                                    isSelected: !showFavoritesOnly,
                                    action: { showFavoritesOnly = false }
                                )
                                
                                FilterButton(
                                    title: "Generated",
                                    count: flowerStore.generatedFlowersCount,
                                    isSelected: false,
                                    action: { 
                                        showFavoritesOnly = false 
                                        // Could add generated filter state here
                                    }
                                )
                                
                                FilterButton(
                                    title: "Received",
                                    count: flowerStore.receivedFlowersCount,
                                    isSelected: false,
                                    action: { 
                                        showFavoritesOnly = false
                                        // Could add received filter state here
                                    }
                                )
                                
                                FilterButton(
                                    title: "Favorites",
                                    count: flowerStore.favorites.count,
                                    isSelected: showFavoritesOnly,
                                    action: { showFavoritesOnly = true }
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
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
                                    .font(.system(size: 14, design: .rounded))
                                Text("Sort")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
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
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 16)
                    
                    if displayedFlowers.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: showFavoritesOnly ? "heart.slash" : "flower")
                                .font(.system(size: 60, design: .rounded))
                                .foregroundColor(.flowerTextTertiary)
                            
                            Text(showFavoritesOnly ? "No favorites yet" : "Your collection is empty")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.flowerTextPrimary)
                            
                            if showFavoritesOnly {
                                Text("Tap the heart on flowers you love")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Start your journey by discovering flowers")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 100)
                    } else {
                        // Flowers grid
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                // Collection Stats Card
                                CollectionStatsCard(flowerStore: flowerStore) {
                                    showingProgressSheet = true
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                
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
                .presentationBackground(Color.flowerSheetBackground)
            }
        }
        .sheet(isPresented: $showingProgressSheet) {
            DiscoveryProgressSheet(flowerStore: flowerStore)
                .presentationDetents([.fraction(0.6), .large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
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
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
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
                            .font(.system(size: 16, design: .rounded))
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
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.9)
                    .frame(height: 35)
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
    @State private var showingGiftSheet = false
    @AppStorage("userName") private var userName = ""
    
    init(flower: AIFlower, flowerStore: FlowerStore, allFlowers: [AIFlower], currentIndex: Int) {
        self._flower = State(initialValue: flower)
        self.flowerStore = flowerStore
        self.allFlowers = allFlowers
        self._currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.flowerBackground, Color.flowerBackgroundSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                TabView(selection: $currentIndex) {
                    ForEach(Array(allFlowers.enumerated()), id: \.element.id) { index, flowerItem in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Flower image with soft blend
                                if let imageData = flowerItem.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    ZStack {
                                        // Soft gradient for edge blending
                                        RadialGradient(
                                            colors: [Color.clear, Color.flowerBackground.opacity(0.8)],
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
                                                            colors: [Color.flowerBackground.opacity(0.6), Color.clear],
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
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(index > 0 ? .gray : .gray.opacity(0.3))
                                        
                                        Text("\(index + 1) of \(allFlowers.count)")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.gray)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(index < allFlowers.count - 1 ? .gray : .gray.opacity(0.3))
                                    }
                                    .padding(.top, 16)
                                }
                                
                                // Flower name and basic info
                                VStack(spacing: 8) {
                                    Text(flowerItem.name)
                                        .font(.system(size: 32, weight: .regular, design: .serif))
                                        .foregroundColor(.flowerTextPrimary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .minimumScaleFactor(0.75)
                                        .padding(.horizontal, 8)
                                    
                                    if flowerItem.isBouquet, let holidayName = flowerItem.holidayName {
                                        HStack(spacing: 6) {
                                            Image(systemName: "gift.fill")
                                                .font(.system(size: 16, design: .rounded))
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
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(.flowerTextSecondary)
                                        }
                                        
                                        Label {
                                            Text(flowerItem.generatedDate, style: .date)
                                        } icon: {
                                            Image(systemName: "calendar")
                                        }
                                        .font(.system(size: 14, design: .rounded))
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
                                        
                                        // Ownership history
                                        if flowerItem.originalOwner != nil || !flowerItem.ownershipHistory.isEmpty {
                                            OwnershipHistorySection(flower: flowerItem)
                                        }
                                        
                                        // Weather card - always show (will show date at minimum)
                                        WeatherSection(flower: flowerItem)
                                        
                                        // Discovery location map - always show
                                        if flowerItem.discoveryLatitude != nil && flowerItem.discoveryLongitude != nil {
                                            LocationSection(flower: flowerItem)
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
                                            .font(.system(size: 14, design: .rounded))
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
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(.flowerTextSecondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        
                                        Button(action: loadFlowerDetails) {
                                            Text("Retry")
                                        }
                                        .flowerButtonStyle()
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
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        Button(action: {
                                            flower = flowerItem
                                            loadFlowerDetails()
                                        }) {
                                            Text("Reveal Details")
                                        }
                                        .flowerButtonStyle()
                                    }
                                    .padding(.vertical, 40)
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
            .background(
                LinearGradient(
                    colors: [Color.flowerBackground, Color.flowerBackgroundSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                // Action buttons with progressive blur
                ZStack {
                    // Progressive blur background
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.flowerBackground.opacity(0), location: 0),
                            .init(color: Color.flowerBackground.opacity(0.8), location: 0.4),
                            .init(color: Color.flowerBackground.opacity(0.95), location: 0.7),
                            .init(color: Color.flowerBackground, location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    .allowsHitTesting(false)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            Button(action: saveToPhotos) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 18))
                                    Text("Save Image")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            .flowerButtonStyle()
                            
                            Button(action: shareFlower) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.flowerPrimary)
                            }
                            .flowerIconButtonStyle(backgroundColor: .flowerPrimary)
                            .accessibilityLabel("Share flower image")
                            
                            // Gift button (only for giftable flowers)
                            if flower.isGiftable {
                                Button(action: { showingGiftSheet = true }) {
                                    Image(systemName: "gift")
                                        .font(.system(size: 20))
                                        .foregroundColor(.flowerPrimary)
                                }
                                .flowerIconButtonStyle(backgroundColor: .flowerPrimary)
                                .accessibilityLabel("Gift flower")
                            }
                        }
                        
                        // Discard button
                        Button(action: { showingDeleteAlert = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles.slash")
                                    .font(.system(size: 16, design: .rounded))
                                Text("Return Flower to Garden")
                                    .font(.system(size: 15, design: .rounded))
                            }
                        }
                        .flowerSecondaryButtonStyle()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                }
                .ignoresSafeArea(edges: .bottom)
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
        .fullScreenCover(isPresented: $showingGiftSheet) {
            GiftFlowerSheet(
                flower: flower,
                userName: $userName,
                onGiftConfirmed: { recipientName in
                    Task {
                        await giftFlower(to: recipientName)
                    }
                }
            )
        }
        .onAppear {
            // Don't auto-load details to prevent slow sheet appearance
            // User can tap "Reveal Details" button if they want to see more
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
    
    private func giftFlower(to recipientName: String) async {
        // Remove the flower from collection
        flowerStore.removeFlower(flower)
        
        // Show success feedback
        await MainActor.run {
            // Show success message
            let successMessage = "Your \(flower.name) has been gifted successfully!"
            print(successMessage)
            
            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // Dismiss the detail view
            dismiss()
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
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                
                Text(title)
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            Text(content)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.flowerTextSecondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CollectionStatsCard: View {
    @ObservedObject var flowerStore: FlowerStore
    let onTapProgress: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Total Flowers
            VStack(spacing: 8) {
                Text("\(flowerStore.totalDiscoveredCount)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                
                Text("flowers discovered")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            
            // Vertical divider
            Rectangle()
                .fill(Color.flowerTextTertiary.opacity(0.3))
                .frame(width: 1, height: 50)
            
            // Progress percentage (tappable)
            Button(action: onTapProgress) {
                VStack(spacing: 8) {
                    let totalSpecies = BotanicalDatabase.shared.allSpecies.count
                    let percentage = Int((Double(flowerStore.uniqueSpeciesDiscoveredCount) / Double(totalSpecies)) * 100)
                    
                    Text("\(percentage)%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.flowerPrimary)
                    
                    Text("of all species")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.flowerTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.flowerCardBackground)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.flowerPrimary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct WeatherSection: View {
    let flower: AIFlower
    
    // Get formatted date string
    private var dateString: String {
        if let dayOfWeek = flower.discoveryDayOfWeek,
           let formattedDate = flower.discoveryFormattedDate {
            return "\(dayOfWeek), \(formattedDate)"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM"
            return formatter.string(from: flower.generatedDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Standard section heading
            HStack(spacing: 8) {
                Image(systemName: "cloud.sun")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                
                Text("Weather")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            // Weather card exactly matching onboarding style
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateString)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(flower.discoveryLocationName ?? "Beautiful location")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Always show something - weather data if available, or fallback
                        HStack(spacing: 8) {
                            if let condition = flower.discoveryWeatherCondition {
                                Image(systemName: weatherIcon(for: condition))
                                    .font(.system(size: 24))
                                    .foregroundColor(weatherIconColor(for: condition))
                                
                                if let temperature = flower.discoveryTemperature {
                                    Text("\(Int(temperature))°\(flower.discoveryTemperatureUnit?.replacingOccurrences(of: "°", with: "") ?? "C")")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            } else {
                                // Fallback when no weather data
                                Image(systemName: "calendar")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("Discovered")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(flower.discoveryWeatherCondition ?? "No weather data")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                HStack {
                    Image(systemName: "flower.fill")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(getWeatherMessage(for: flower.discoveryWeatherCondition, temperature: flower.discoveryTemperature))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(
                LinearGradient(
                    colors: getContextualWeatherGradient(condition: flower.discoveryWeatherCondition, temperature: flower.discoveryTemperature, timeOfDay: getTimeOfDay(for: flower.generatedDate)),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.12), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "sunny", "clear":
            return "sun.max.fill"
        case "cloudy", "mostly cloudy":
            return "cloud.fill"
        case "partly cloudy":
            return "cloud.sun.fill"
        case "rainy", "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "snowy", "snow":
            return "cloud.snow.fill"
        case "thunderstorms":
            return "cloud.bolt.fill"
        case "windy", "breezy":
            return "wind"
        case "hazy":
            return "cloud.fog.fill"
        case "hot":
            return "thermometer.sun.fill"
        case "frigid":
            return "thermometer.snowflake"
        default:
            return "cloud.fill"
        }
    }
    
    private func weatherIconColor(for condition: String) -> Color {
        switch condition.lowercased() {
        case "sunny", "clear":
            return .yellow
        case "cloudy", "mostly cloudy", "partly cloudy":
            return .white.opacity(0.9)
        case "rainy", "rain", "drizzle":
            return .white.opacity(0.9)
        case "snowy", "snow":
            return .white
        case "thunderstorms":
            return .yellow
        case "windy", "breezy":
            return .white.opacity(0.9)
        case "hazy":
            return .white.opacity(0.7)
        case "hot":
            return .orange
        case "frigid":
            return .cyan
        default:
            return .white.opacity(0.9)
        }
    }
    
    private func getTimeOfDay(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        if hour >= 5 && hour < 9 { return "dawn" }
        else if hour >= 9 && hour < 17 { return "day" }
        else if hour >= 17 && hour < 21 { return "sunset" }
        else { return "night" }
    }
    
    private func getWeatherMessage(for condition: String?, temperature: Double?) -> String {
        if let condition = condition {
            switch condition.lowercased() {
            case "sunny", "clear":
                if let temp = temperature, temp >= 31 {
                    return "Hot summer day"
                } else {
                    return "Sunny and clear"
                }
            case "rainy", "rain":
                return "Refreshing rain"
            case "cloudy":
                return "Gentle cloudy skies"
            case "snowy", "snow":
                return "Winter wonderland"
            default:
                return "Beautiful weather"
            }
        }
        return "Lovely day"
    }
    
    private func getContextualWeatherGradient(condition: String?, temperature: Double?, timeOfDay: String) -> [Color] {
        // Time of day overrides for dramatic gradients
        switch timeOfDay {
        case "dawn":
            return [
                Color(red: 255/255, green: 183/255, blue: 107/255), // Warm orange
                Color(red: 255/255, green: 204/255, blue: 128/255), // Light peach
                Color(red: 135/255, green: 206/255, blue: 250/255)  // Light sky blue
            ]
        case "sunset":
            return [
                Color(red: 255/255, green: 94/255, blue: 77/255),   // Coral red
                Color(red: 255/255, green: 154/255, blue: 0/255),   // Orange
                Color(red: 255/255, green: 206/255, blue: 84/255)   // Golden yellow
            ]
        case "night":
            return [
                Color(red: 25/255, green: 25/255, blue: 112/255),   // Midnight blue
                Color(red: 72/255, green: 61/255, blue: 139/255),   // Dark slate blue
                Color(red: 106/255, green: 90/255, blue: 205/255)   // Slate blue
            ]
        default:
            break
        }
        
        // Weather condition based gradients
        if let condition = condition {
            switch condition.lowercased() {
            case "sunny", "clear":
                if let temp = temperature {
                    if temp >= 31 { // Hot summer day
                        return [
                            Color(red: 255/255, green: 69/255, blue: 0/255),    // Red orange
                            Color(red: 255/255, green: 140/255, blue: 0/255),   // Dark orange
                            Color(red: 255/255, green: 165/255, blue: 0/255)    // Orange
                        ]
                    } else if temp > 25 { // Warm sunny
                        return [
                            Color(red: 255/255, green: 215/255, blue: 0/255),   // Gold
                            Color(red: 255/255, green: 165/255, blue: 0/255),   // Orange
                            Color(red: 135/255, green: 206/255, blue: 250/255)  // Sky blue
                        ]
                    }
                }
                // Regular sunny blue sky
                return [
                    Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                    Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
                ]
            case "rainy", "rain", "drizzle":
                return [
                    Color(red: 105/255, green: 105/255, blue: 105/255), // Dim gray
                    Color(red: 119/255, green: 136/255, blue: 153/255), // Light slate gray
                    Color(red: 176/255, green: 196/255, blue: 222/255)  // Light steel blue
                ]
            case "cloudy", "mostly cloudy":
                return [
                    Color(red: 169/255, green: 169/255, blue: 169/255), // Dark gray
                    Color(red: 192/255, green: 192/255, blue: 192/255), // Silver
                    Color(red: 211/255, green: 211/255, blue: 211/255)  // Light gray
                ]
            case "snowy", "snow", "icy":
                return [
                    Color(red: 240/255, green: 248/255, blue: 255/255), // Alice blue
                    Color(red: 176/255, green: 224/255, blue: 230/255), // Powder blue
                    Color(red: 230/255, green: 230/255, blue: 250/255)  // Lavender
                ]
            case "thunderstorms":
                return [
                    Color(red: 75/255, green: 0/255, blue: 130/255),    // Indigo
                    Color(red: 72/255, green: 61/255, blue: 139/255),   // Dark slate blue
                    Color(red: 128/255, green: 128/255, blue: 128/255)  // Gray
                ]
            default:
                break
            }
        }
        
        // Default gradient
        return [
            Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
            Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
        ]
    }
    
    private func weatherGradientColors(for condition: String?) -> [Color] {
        guard let condition = condition else {
            // Default gradient for no weather data
            return [
                Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
            ]
        }
        
        switch condition.lowercased() {
        case "sunny", "clear":
            return [
                Color(red: 255/255, green: 223/255, blue: 0/255),   // Gold
                Color(red: 255/255, green: 165/255, blue: 0/255)    // Orange
            ]
        case "cloudy", "mostly cloudy":
            return [
                Color(red: 169/255, green: 169/255, blue: 169/255), // Dark gray
                Color(red: 128/255, green: 128/255, blue: 128/255)  // Gray
            ]
        case "partly cloudy":
            return [
                Color(red: 135/255, green: 206/255, blue: 235/255), // Sky blue
                Color(red: 119/255, green: 136/255, blue: 153/255)  // Light slate gray
            ]
        case "rainy", "rain":
            return [
                Color(red: 64/255, green: 64/255, blue: 128/255),   // Dark slate blue
                Color(red: 70/255, green: 130/255, blue: 180/255)   // Steel blue
            ]
        case "drizzle":
            return [
                Color(red: 119/255, green: 136/255, blue: 153/255), // Light slate gray
                Color(red: 176/255, green: 196/255, blue: 222/255)  // Light steel blue
            ]
        case "snowy", "snow":
            return [
                Color(red: 240/255, green: 248/255, blue: 255/255), // Alice blue
                Color(red: 176/255, green: 224/255, blue: 230/255)  // Powder blue
            ]
        case "thunderstorms":
            return [
                Color(red: 75/255, green: 0/255, blue: 130/255),    // Indigo
                Color(red: 72/255, green: 61/255, blue: 139/255)    // Dark slate blue
            ]
        case "windy", "breezy":
            return [
                Color(red: 135/255, green: 206/255, blue: 235/255), // Sky blue
                Color(red: 0/255, green: 191/255, blue: 255/255)    // Deep sky blue
            ]
        case "hazy":
            return [
                Color(red: 188/255, green: 143/255, blue: 143/255), // Rosy brown
                Color(red: 210/255, green: 180/255, blue: 140/255)  // Tan
            ]
        case "hot":
            return [
                Color(red: 255/255, green: 69/255, blue: 0/255),    // Red orange
                Color(red: 255/255, green: 140/255, blue: 0/255)    // Dark orange
            ]
        case "frigid":
            return [
                Color(red: 0/255, green: 191/255, blue: 255/255),   // Deep sky blue
                Color(red: 135/255, green: 206/255, blue: 250/255)  // Light sky blue
            ]
        default:
            return [
                Color(red: 135/255, green: 206/255, blue: 250/255), // Light sky blue
                Color(red: 30/255, green: 144/255, blue: 255/255)   // Dodger blue
            ]
        }
    }
}

struct OwnershipHistorySection: View {
    let flower: AIFlower
    @AppStorage("userName") private var userName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Standard section heading
            HStack(spacing: 8) {
                Image(systemName: "person.2")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                
                Text("Ownership History")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            // Ownership timeline
            VStack(alignment: .leading, spacing: 16) {
                let allOwners = createOwnershipTimeline()
                
                ForEach(Array(allOwners.enumerated()), id: \.element.owner.id) { index, entry in
                    HStack(alignment: .top, spacing: 16) {
                        // Enhanced timeline indicator
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(timelineBackgroundColor(for: entry))
                                    .frame(width: 12, height: 12)
                                
                                Circle()
                                    .fill(timelineColor(for: entry))
                                    .frame(width: 8, height: 8)
                            }
                            
                            // Show connecting line to next owner (extends all the way to current owner)
                            if index < allOwners.count - 1 {
                                Rectangle()
                                    .fill(Color.flowerTextTertiary.opacity(0.2))
                                    .frame(width: 2, height: 72)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            // Owner name with status badge
                            HStack(spacing: 8) {
                                Text(entry.owner.name)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                if entry.isOriginal {
                                    HStack(spacing: 4) {
                                        Image(systemName: "seedling")
                                            .font(.system(size: 10))
                                            .foregroundColor(.flowerPrimary)
                                        Text("Original Owner")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.flowerPrimary)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.flowerPrimary.opacity(0.1))
                                    .cornerRadius(8)
                                } else if entry.isCurrent {
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.green)
                                        Text("Current Owner")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.green)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Date and location
                            VStack(alignment: .leading, spacing: 2) {
                                Text(DateFormatter.longDate.string(from: entry.owner.transferDate))
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                if let location = entry.owner.location {
                                    HStack(spacing: 4) {
                                        Image(systemName: "location")
                                            .font(.system(size: 10))
                                            .foregroundColor(.flowerTextTertiary)
                                        Text(location)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.flowerTextTertiary)
                                    }
                                }
                            }
                            
                            // Time held with better formatting
                            if let timeHeld = entry.timeHeld {
                                Text(timeHeld)
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.flowerTextTertiary)
                                    .padding(.top, 2)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func timelineColor(for entry: (owner: FlowerOwner, isOriginal: Bool, isCurrent: Bool, timeHeld: String?)) -> Color {
        if entry.isOriginal {
            return .green
        } else if entry.isCurrent {
            return .flowerPrimary
        } else {
            return .flowerSecondary
        }
    }
    
    private func timelineBackgroundColor(for entry: (owner: FlowerOwner, isOriginal: Bool, isCurrent: Bool, timeHeld: String?)) -> Color {
        if entry.isOriginal {
            return .green.opacity(0.2)
        } else if entry.isCurrent {
            return .flowerPrimary.opacity(0.2)
        } else {
            return .flowerSecondary.opacity(0.2)
        }
    }
    
    // Create a complete ownership timeline including original owner and current owner
    private func createOwnershipTimeline() -> [(owner: FlowerOwner, isOriginal: Bool, isCurrent: Bool, timeHeld: String?)] {
        var timeline: [(owner: FlowerOwner, isOriginal: Bool, isCurrent: Bool, timeHeld: String?)] = []
        
        // Add original owner if exists
        if let original = flower.originalOwner {
            let timeHeld = calculateTimeHeld(from: original.transferDate, to: flower.ownershipHistory.first?.transferDate)
            timeline.append((owner: original, isOriginal: true, isCurrent: false, timeHeld: timeHeld))
        }
        
        // Add all previous owners
        for (index, owner) in flower.ownershipHistory.enumerated() {
            let nextDate = index < flower.ownershipHistory.count - 1 ? flower.ownershipHistory[index + 1].transferDate : Date()
            let timeHeld = calculateTimeHeld(from: owner.transferDate, to: nextDate)
            timeline.append((owner: owner, isOriginal: false, isCurrent: false, timeHeld: timeHeld))
        }
        
        // Add current owner if not already in the list
        if !flower.ownershipHistory.isEmpty || flower.originalOwner != nil {
            let currentOwner = FlowerOwner(
                name: userName.isEmpty ? "You" : userName,
                transferDate: flower.ownershipHistory.last?.transferDate ?? flower.originalOwner?.transferDate ?? flower.generatedDate,
                location: nil
            )
            let timeHeld = calculateTimeHeld(from: currentOwner.transferDate, to: Date())
            timeline.append((owner: currentOwner, isOriginal: false, isCurrent: true, timeHeld: timeHeld))
        }
        
        return timeline
    }
    
    // Calculate time held in a human-readable format
    private func calculateTimeHeld(from startDate: Date, to endDate: Date?) -> String {
        guard let endDate = endDate else { return "Currently owned" }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: startDate, to: endDate)
        
        var parts: [String] = []
        
        if let years = components.year, years > 0 {
            parts.append("\(years) year\(years == 1 ? "" : "s")")
        }
        if let months = components.month, months > 0 {
            parts.append("\(months) month\(months == 1 ? "" : "s")")
        }
        if let days = components.day, days > 0 {
            parts.append("\(days) day\(days == 1 ? "" : "s")")
        }
        
        if parts.isEmpty {
            return "Less than a day"
        }
        
        return "Held for " + parts.prefix(2).joined(separator: ", ")
    }
}

struct LocationSection: View {
    let flower: AIFlower
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Standard section heading
            HStack(spacing: 8) {
                Image(systemName: "location")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.flowerPrimary)
                
                Text("Discovery Location")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            // Map view
            FlowerMapView(flower: flower, showCoordinates: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
} 