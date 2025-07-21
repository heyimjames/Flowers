import SwiftUI

struct SpeciesDetailSheet: View {
    let species: SpeciesGroup
    @ObservedObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlowerIndex = 0
    @State private var showingFullScreenImage = false
    @State private var animateHerbariumButton = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    Spacer()
                    Text("Species Detail")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                
                // Simple content for debugging
                VStack(alignment: .leading, spacing: 16) {
                    Text("Common Name: \(species.commonName)")
                        .font(.headline)
                    
                    Text("Scientific Name: \(species.scientificName)")
                        .font(.subheadline)
                        .italic()
                    
                    if let family = species.family {
                        Text("Family: \(family)")
                    }
                    
                    Text("Discovery Count: \(species.discoveryCount)")
                    
                    Text("First Discovered: \(species.firstDiscovered.formatted(date: .abbreviated, time: .omitted))")
                    
                    // Show representative flower image
                    if let imageData = species.representativeFlower.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

// Safe array subscript extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}