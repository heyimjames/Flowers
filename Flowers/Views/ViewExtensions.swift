import SwiftUI

extension View {
    func flowerSheet() -> some View {
        self
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.flowerSheetBackground)
    }
}


// MARK: - Legacy Color Definitions
// The main color definitions are automatically generated from Assets.xcassets
// These are kept for backwards compatibility with older code
extension Color {
    static let flowerPurple = Color(red: 147/255, green: 51/255, blue: 234/255)
    static let flowerPink = Color(red: 236/255, green: 72/255, blue: 153/255)
    static let flowerGray = Color(red: 248/255, green: 249/255, blue: 250/255)
    static let flowerDarkGray = Color(red: 44/255, green: 62/255, blue: 80/255)
} 