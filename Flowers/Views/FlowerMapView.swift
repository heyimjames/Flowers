import SwiftUI
import MapKit

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
    @State private var showingFullMap = false
    @State private var region: MKCoordinateRegion
    
    init(flower: AIFlower) {
        self.flower = flower
        
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
                HStack(spacing: 6) {
                    Image(systemName: "map")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.flowerPrimary)
                    Text("Discovery Location")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.flowerTextPrimary)
                    Spacer()
                }
                
                Button(action: {
                    showingFullMap = true
                }) {
                    ZStack(alignment: .bottomLeading) {
                                        Map(coordinateRegion: .constant(region),
                    interactionModes: [],
                    annotationItems: [MapFlower(flower: flower)]) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        FlowerMapPin()
                    }
                }
                        .frame(height: 180)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.flowerPrimary.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Location label overlay
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
                            .padding(12)
                        }
                        
                        // Tap indicator
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 10))
                                    Text("Tap to expand")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.flowerPrimary.opacity(0.9))
                                )
                                .padding(8)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .sheet(isPresented: $showingFullMap) {
                FullScreenMapView(flower: flower)
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
            }
        }
    }
}

struct FlowerMapPin: View {
    @State private var animatePin = false
    
    var body: some View {
        ZStack {
            // Pulsing circle background
            Circle()
                .fill(Color.flowerPrimary.opacity(0.3))
                .frame(width: animatePin ? 40 : 20, height: animatePin ? 40 : 20)
                .opacity(animatePin ? 0 : 1)
            
            // Pin
            Image(systemName: "flower.fill")
                .font(.system(size: 24))
                .foregroundColor(.flowerPrimary)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                )
                .shadow(radius: 4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                animatePin = true
            }
        }
    }
}

struct FullScreenMapView: View {
    let flower: AIFlower
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    init(flower: AIFlower) {
        self.flower = flower
        
        if let lat = flower.discoveryLatitude,
           let lon = flower.discoveryLongitude {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        } else {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Full screen map
                Map(coordinateRegion: $region,
                    showsUserLocation: false,
                    annotationItems: [MapFlower(flower: flower)]) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        FlowerMapPin()
                    }
                }
                .ignoresSafeArea()
                
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
                
                // Flower info card
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Flower name and image
                        HStack(spacing: 16) {
                            if let imageData = flower.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(flower.name)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                if let locationName = flower.discoveryLocationName {
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 12))
                                        Text(locationName)
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(.flowerTextSecondary)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 12))
                                    Text(flower.discoveryDate ?? flower.generatedDate, style: .date)
                                        .font(.system(size: 14))
                                    Text("at")
                                        .font(.system(size: 14))
                                    Text(flower.discoveryDate ?? flower.generatedDate, style: .time)
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.flowerTextSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        
                        // Coordinates
                        if let lat = flower.discoveryLatitude,
                           let lon = flower.discoveryLongitude {
                            HStack {
                                Image(systemName: "location.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.flowerTextTertiary)
                                Text(String(format: "%.4f°, %.4f°", lat, lon))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.flowerTextTertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.flowerCardBackground)
                            .cornerRadius(20)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Discovery Location")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
} 