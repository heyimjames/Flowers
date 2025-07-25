import SwiftUI
import MapKit

// Helper function to format coordinates
private func formatCoordinate(_ coordinate: Double, isLatitude: Bool) -> String {
    let direction: String
    let absValue = abs(coordinate)
    
    if isLatitude {
        direction = coordinate >= 0 ? "N" : "S"
    } else {
        direction = coordinate >= 0 ? "E" : "W"
    }
    
    return String(format: "%.4f°%@", absValue, direction)
}

// Helper function to format flower description
private func formatFlowerDescription(_ description: String) -> String {
    let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return "" }
    
    // Capitalize first letter and make the rest lowercase, then capitalize sentences
    let lowercased = trimmed.lowercased()
    let capitalized = lowercased.prefix(1).capitalized + lowercased.dropFirst()
    
    // Basic sentence capitalization (after periods)
    let sentences = capitalized.components(separatedBy: ". ")
    let formatted = sentences.map { sentence in
        sentence.isEmpty ? "" : sentence.prefix(1).capitalized + sentence.dropFirst()
    }.joined(separator: ". ")
    
    return formatted
}

// Wrapper for map annotations
struct MapFlower: Identifiable {
    let id = UUID()
    let flower: AIFlower
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: flower.discoveryLatitude ?? 0,
            longitude: flower.discoveryLongitude ?? 0
        )
    }
}

struct FlowerMapView: View {
    let flower: AIFlower
    let showCoordinates: Bool
    @State private var showingFullMap = false
    @State private var region: MKCoordinateRegion
    @EnvironmentObject var flowerStore: FlowerStore
    
    init(flower: AIFlower, showCoordinates: Bool = true) {
        self.flower = flower
        self.showCoordinates = showCoordinates
        
        // Initialize region with flower's discovery location
        if let lat = flower.discoveryLatitude,
           let lon = flower.discoveryLongitude {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            // Default to a generic location if no coordinates
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    var body: some View {
        if flower.discoveryLatitude != nil && flower.discoveryLongitude != nil {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    showingFullMap = true
                }) {
                    ZStack {
                        Map(coordinateRegion: .constant(region),
                            interactionModes: [],
                            showsUserLocation: true,
                            annotationItems: [MapFlower(flower: flower)]) { item in
                            MapAnnotation(coordinate: item.coordinate) {
                                FlowerMapPin(flower: item.flower)
                            }
                        }
                        .frame(height: 180)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Location label overlay - bottom left
                        VStack {
                            Spacer()
                            HStack {
                                if let locationName = flower.discoveryLocationName {
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 10))
                                        Text(locationName)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.7))
                                    )
                                }
                                Spacer()
                            }
                            .padding(12)
                        }
                        
                        // Tap indicator - bottom right
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("Tap to Expand")
                                        .font(.system(size: 12, weight: .medium))
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.7))
                                )
                            }
                            .padding(12)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Coordinates pill (only shown when showCoordinates is true)
                if showCoordinates,
                   let lat = flower.discoveryLatitude,
                   let lon = flower.discoveryLongitude {
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerPrimary)
                        Text("\(formatCoordinate(lat, isLatitude: true)), \(formatCoordinate(lon, isLatitude: false))")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.flowerPrimary.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            .sheet(isPresented: $showingFullMap) {
                FullScreenMapView(selectedFlower: flower)
                    .environmentObject(flowerStore)
                    .presentationCornerRadius(32)
            }
        }
    }
}

struct FlowerMapPin: View {
    let flower: AIFlower
    @State private var animatePin = false
    
    var body: some View {
        ZStack {
            // Pulsing circle background
            Circle()
                .fill(Color.flowerPrimary.opacity(0.3))
                .frame(width: animatePin ? 60 : 36, height: animatePin ? 60 : 36)
                .opacity(animatePin ? 0 : 1)
            
            // White circle background
            Circle()
                .fill(Color.white)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            // Flower image inside circle
            if let imageData = flower.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                // Fallback flower icon if no image
                Image(systemName: "flower.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.flowerPrimary)
            }
        }
        .zIndex(0) // Ensure flower pins are below user location
        .onAppear {
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                animatePin = true
            }
        }
    }
}

struct FullScreenMapView: View {
    let selectedFlower: AIFlower
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: FlowerStore
    @State private var mapRegion: MKCoordinateRegion
    @State private var flowersWithLocation: [AIFlower] = []
    @State private var selectedIndex: Int = 0
    
    init(selectedFlower: AIFlower) {
        self.selectedFlower = selectedFlower
        
        if let lat = selectedFlower.discoveryLatitude,
           let lon = selectedFlower.discoveryLongitude {
            self._mapRegion = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        } else {
            self._mapRegion = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Full screen map
                Map(coordinateRegion: $mapRegion,
                    showsUserLocation: true,
                    annotationItems: flowersWithLocation.map { MapFlower(flower: $0) }) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        FlowerMapPin(flower: item.flower)
                            .zIndex(0) // Ensure flower pins are below user location
                    }
                }
                .ignoresSafeArea()
                .tint(.flowerPrimary) // Make user location green
                
                // Top gradient for better text visibility
                VStack {
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    .ignoresSafeArea()
                    
                    Spacer()
                }
                
                // Flower cards carousel
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // TabView for carousel with extra padding to prevent shadow clipping
                        TabView(selection: $selectedIndex) {
                            ForEach(Array(flowersWithLocation.enumerated()), id: \.offset) { index, flower in
                                FlowerMapCard(flower: flower)
                                    .tag(index)
                                    .padding(.horizontal, 30) // More padding to prevent shadow clipping
                                    .padding(.vertical, 10)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 180) // Reduced height since coordinates moved out
                        .onChange(of: selectedIndex) { newIndex in
                            // Animate to the selected flower's location
                            if newIndex < flowersWithLocation.count {
                                let flower = flowersWithLocation[newIndex]
                                if let lat = flower.discoveryLatitude,
                                   let lon = flower.discoveryLongitude {
                                    withAnimation(.easeInOut(duration: 0.7)) {
                                        mapRegion = MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Coordinates pill below the card
                        if selectedIndex < flowersWithLocation.count {
                            let flower = flowersWithLocation[selectedIndex]
                            if let lat = flower.discoveryLatitude,
                               let lon = flower.discoveryLongitude {
                                HStack(spacing: 6) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("\(formatCoordinate(lat, isLatitude: true)), \(formatCoordinate(lon, isLatitude: false))")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    if let date = selectedFlower.discoveryDate {
                        VStack(spacing: 2) {
                            Text("Discovered")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            Text(date, style: .date)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Load all flowers with location data and find selected index
            let flowers = store.discoveredFlowers.filter { 
                $0.discoveryLatitude != nil && $0.discoveryLongitude != nil 
            }.sorted { 
                ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate) 
            }
            
            flowersWithLocation = flowers
            
            // Find the index of the selected flower
            if let index = flowers.firstIndex(where: { $0.id == selectedFlower.id }) {
                selectedIndex = index
            }
        }
    }
}

struct FlowerMapCard: View {
    let flower: AIFlower
    @State private var displayDescription: String = ""
    @State private var isLoadingDescription = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Flower image
                if let imageData = flower.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(flower.name)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(.flowerTextPrimary)
                        .lineLimit(1)
                    
                    if isLoadingDescription {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating...")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    } else {
                        Text(displayDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let locationName = flower.discoveryLocationName {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(locationName)
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                        .foregroundColor(.flowerTextTertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 8)
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .onAppear {
            loadDescription()
        }
    }
    
    private func loadDescription() {
        // Check if we already have a short description
        if let shortDesc = flower.shortDescription, !shortDesc.isEmpty {
            displayDescription = shortDesc
            return
        }
        
        // Use formatted original description as fallback
        displayDescription = formatFlowerDescription(flower.descriptor)
        
        // Generate a better description in the background
        Task {
            await generateShortDescription()
        }
    }
    
    private func generateShortDescription() async {
        // Don't generate if we already have a good short description
        if let shortDesc = flower.shortDescription, !shortDesc.isEmpty {
            return
        }
        
        isLoadingDescription = true
        
        do {
            let shortDesc = try await OpenAIService.shared.generateShortDescription(for: flower)
            
            // Update the flower object with the new short description
            // Note: This is a temporary solution - ideally we'd update the flower in the store
            await MainActor.run {
                displayDescription = shortDesc
                isLoadingDescription = false
            }
            
        } catch {
            print("Failed to generate short description: \(error)")
            await MainActor.run {
                isLoadingDescription = false
            }
        }
    }
} 