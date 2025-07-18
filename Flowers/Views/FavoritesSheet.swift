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
                    
                    // Discovery location stats
                    if !showFavoritesOnly && !flowerStore.discoveryLocationStats.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Found in")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(flowerStore.discoveryLocationStats.sorted(by: { $0.value > $1.value }).prefix(10), id: \.key) { location, count in
                                        VStack(spacing: 4) {
                                            Text("\(count)")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.flowerPrimary)
                                            Text(location)
                                                .font(.system(size: 11))
                                                .foregroundColor(.flowerTextSecondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
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
                                .padding(.horizontal, 24)
                            }
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
                .presentationBackground(Color.flowerSheetBackground)
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
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .minimumScaleFactor(0.75)
                                        .padding(.horizontal, 8)
                                    
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
                                        
                                        // Weather card - show if we have weather data OR date information
                                        if flowerItem.discoveryWeatherCondition != nil || 
                                           flowerItem.discoveryTemperature != nil ||
                                           flowerItem.discoveryDayOfWeek != nil ||
                                           flowerItem.discoveryFormattedDate != nil {
                                            WeatherDetailCard(flower: flowerItem)
                                        }
                                        
                                        // Ownership history
                                        if flowerItem.originalOwner != nil || !flowerItem.ownershipHistory.isEmpty {
                                            OwnershipHistoryCard(flower: flowerItem)
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
                                            .font(.system(size: 16))
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
                                    .font(.system(size: 16))
                                Text("Return Flower to Garden")
                                    .font(.system(size: 15))
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
                    .font(.system(size: 16))
                    .foregroundColor(.flowerPrimary)
                
                Text(title)
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.flowerTextSecondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WeatherDetailCard: View {
    let flower: AIFlower
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "cloud.sun")
                    .font(.system(size: 16))
                    .foregroundColor(.flowerPrimary)
                
                Text("Discovery Weather")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Weather condition and temperature (if available)
                if flower.discoveryWeatherCondition != nil || flower.discoveryTemperature != nil {
                    HStack(spacing: 16) {
                        if let condition = flower.discoveryWeatherCondition {
                            HStack(spacing: 6) {
                                Image(systemName: weatherIcon(for: condition))
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerSecondary)
                                Text(condition)
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                        
                        if let temperature = flower.discoveryTemperature {
                            HStack(spacing: 4) {
                                Image(systemName: "thermometer")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerSecondary)
                                Text("\(Int(temperature))\(flower.discoveryTemperatureUnit ?? "°C")")
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                    }
                }
                
                // Date information
                if let dayOfWeek = flower.discoveryDayOfWeek,
                   let formattedDate = flower.discoveryFormattedDate {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerSecondary)
                        Text("\(dayOfWeek), \(formattedDate)")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                } else {
                    // Fallback to generated date if discovery date info is not available
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerSecondary)
                        Text(flower.generatedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
            }
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "sunny", "clear":
            return "sun.max"
        case "cloudy", "mostly cloudy":
            return "cloud"
        case "partly cloudy":
            return "cloud.sun"
        case "rainy", "rain":
            return "cloud.rain"
        case "drizzle":
            return "cloud.drizzle"
        case "snowy", "snow":
            return "cloud.snow"
        case "thunderstorms":
            return "cloud.bolt"
        case "windy", "breezy":
            return "wind"
        case "hazy":
            return "cloud.fog"
        case "hot":
            return "thermometer.sun"
        case "frigid":
            return "thermometer.snowflake"
        default:
            return "cloud"
        }
    }
}

struct OwnershipHistoryCard: View {
    let flower: AIFlower
    @AppStorage("userName") private var userName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.2")
                    .font(.system(size: 16))
                    .foregroundColor(.flowerPrimary)
                
                Text("Ownership History")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Create complete ownership timeline
                let allOwners = createOwnershipTimeline()
                
                ForEach(Array(allOwners.enumerated()), id: \.element.owner.id) { index, entry in
                    HStack(alignment: .top, spacing: 12) {
                        // Timeline indicator
                        VStack {
                            Circle()
                                .fill(entry.isOriginal ? Color.flowerPrimary : entry.isCurrent ? Color.flowerSuccess : Color.flowerSecondary)
                                .frame(width: 8, height: 8)
                            
                            if index < allOwners.count - 1 {
                                Rectangle()
                                    .fill(Color.flowerTextTertiary.opacity(0.3))
                                    .frame(width: 1, height: 30)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Name and role
                            HStack {
                                Text(entry.owner.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                if entry.isOriginal {
                                    Text("🌱")
                                        .font(.system(size: 12))
                                } else if entry.isCurrent {
                                    Text("(You)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                            }
                            
                            // Date and location
                            HStack(spacing: 8) {
                                Text(DateFormatter.shortDate.string(from: entry.owner.transferDate))
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                if let location = entry.owner.location {
                                    Text("• \(location)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                            }
                            
                            // Time held
                            if let timeHeld = entry.timeHeld {
                                Text(timeHeld)
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(.flowerTextTertiary)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
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

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
} 