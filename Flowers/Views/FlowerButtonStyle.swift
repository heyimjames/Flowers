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
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [
                            color.opacity(0.12), // 12% at top
                            color.opacity(0.03), // 3% in middle
                            color.opacity(0.08)  // 8% at bottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Border gradient overlay
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12), // 12% at top
                                    Color.white.opacity(0.01)  // 1% at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(28)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Secondary button style with different colors
struct FlowerSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.flowerTextSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [
                            Color.flowerButtonBackground.opacity(0.12), // 12% at top
                            Color.flowerButtonBackground.opacity(0.03), // 3% in middle
                            Color.flowerButtonBackground.opacity(0.08)  // 8% at bottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Border gradient overlay
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12), // 12% at top
                                    Color.white.opacity(0.01)  // 1% at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(28)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
            .frame(width: 56, height: 56)
            .background(
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [
                            backgroundColor.opacity(0.12), // 12% at top
                            backgroundColor.opacity(0.03), // 3% in middle
                            backgroundColor.opacity(0.08)  // 8% at bottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Border gradient overlay
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12), // 12% at top
                                    Color.white.opacity(0.01)  // 1% at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
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