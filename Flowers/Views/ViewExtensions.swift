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

// Primary button style with transparent/floating design
struct FlowerPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.flowerPrimary)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.flowerPrimary.opacity(configuration.isPressed ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.flowerPrimary.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Secondary button style for less prominent actions
struct FlowerSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.flowerSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.flowerSecondary.opacity(configuration.isPressed ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.flowerSecondary.opacity(0.3), lineWidth: 1)
                    )
            )
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