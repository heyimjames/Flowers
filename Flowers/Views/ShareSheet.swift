import SwiftUI

struct ShareSheet: View {
    let flower: AIFlower
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Share \(flower.name)")
                    .font(.title)
                    .padding()
                
                if let imageData = flower.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(20)
                        .padding()
                }
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
} 