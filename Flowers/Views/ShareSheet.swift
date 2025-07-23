import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ShareSheet: UIViewControllerRepresentable {
    let flower: AIFlower
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var activityItems: [Any] = []
        
        // Add image if available
        if let imageData = flower.imageData,
           let image = UIImage(data: imageData) {
            activityItems.append(image)
        }
        
        // Create share text
        var shareText = "🌸 \(flower.name)"
        if let locationName = flower.discoveryLocationName {
            shareText += "\n📍 \(locationName)"
        }
        if let meaning = flower.meaning {
            shareText += "\n\n\(meaning)"
        }
        shareText += "\n\nDiscovered with Flowers app"
        activityItems.append(shareText)
        
        
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Exclude some activity types if desired
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        // Add completion handler to handle save to photos separately if needed
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                if activityType == .saveToCameraRoll {
                    // User saved to camera roll through the share sheet
                    // We could track this if needed
                    print("Flower saved to camera roll via share sheet")
                }
            }
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// Convenience modifier for presenting share sheet
extension View {
    func shareSheet(isPresented: Binding<Bool>, flower: AIFlower?) -> some View {
        self.sheet(isPresented: isPresented) {
            if let flower = flower {
                ShareSheet(flower: flower)
                    .ignoresSafeArea()
            }
        }
    }
} 