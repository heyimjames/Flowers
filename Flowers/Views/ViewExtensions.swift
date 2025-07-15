import SwiftUI

extension View {
    func flowerSheet() -> some View {
        self
            .presentationCornerRadius(32)
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.flowerSheetBackground)
    }
}

// Custom button style for the app
struct FlowerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.flowerPrimary.opacity(configuration.isPressed ? 0.8 : 1.0))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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