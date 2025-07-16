import SwiftUI

struct FlowerButtonStyle: ButtonStyle {
    let color: Color
    let textColor: Color
    let isSecondary: Bool
    
    init(color: Color = .flowerPrimary, textColor: Color = .white, isSecondary: Bool = false) {
        self.color = color
        self.textColor = textColor
        self.isSecondary = isSecondary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white) // White text for good contrast on dark buttons
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Material blur background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.thickMaterial)
                    
                    // Green brand tint overlay
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.flowerPrimary.opacity(0.4))
                    
                    // Inner glow effect
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15), // Subtle highlight at top
                                    Color.white.opacity(0.05), // Very subtle at middle
                                    Color.black.opacity(0.2)   // Darker shadow at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    
                    // Outer border
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            Color.flowerPrimary.opacity(0.3),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(28)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Secondary button style with different colors
struct FlowerSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white) // White text for good contrast on dark buttons
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Material blur background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.thickMaterial)
                    
                    // Green brand tint overlay (slightly lighter than primary)
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.flowerPrimary.opacity(0.3))
                    
                    // Inner glow effect
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1), // Subtle highlight at top
                                    Color.white.opacity(0.03), // Very subtle at middle
                                    Color.black.opacity(0.15)   // Darker shadow at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    
                    // Outer border
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            Color.flowerPrimary.opacity(0.25),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(28)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Icon button style for circular icon buttons
struct FlowerIconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isActive: Bool
    
    init(backgroundColor: Color = .flowerButtonBackground, isActive: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isActive = isActive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white) // White icon for good contrast on dark buttons
            .frame(width: 56, height: 56)
            .background(
                ZStack {
                    // Material blur background
                    Circle()
                        .fill(.thickMaterial)
                    
                    // Green brand tint overlay
                    Circle()
                        .fill(Color.flowerPrimary.opacity(0.4))
                    
                    // Inner glow effect
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1), // Subtle highlight at top
                                    Color.white.opacity(0.03), // Very subtle at middle
                                    Color.black.opacity(0.15)   // Darker shadow at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    
                    // Outer border
                    Circle()
                        .strokeBorder(
                            Color.flowerPrimary.opacity(0.25),
                            lineWidth: 1
                        )
                }
            )
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Extension to make it easy to apply
extension View {
    func flowerButtonStyle(color: Color = .flowerPrimary, textColor: Color = .white) -> some View {
        self.buttonStyle(FlowerButtonStyle(color: color, textColor: textColor))
    }
    
    func flowerSecondaryButtonStyle() -> some View {
        self.buttonStyle(FlowerSecondaryButtonStyle())
    }
    
    func flowerIconButtonStyle(backgroundColor: Color = .flowerButtonBackground, isActive: Bool = false) -> some View {
        self.buttonStyle(FlowerIconButtonStyle(backgroundColor: backgroundColor, isActive: isActive))
    }
}