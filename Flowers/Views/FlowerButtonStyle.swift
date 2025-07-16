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
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(configuration.isPressed ? Color.black.opacity(0.1) : Color.clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Secondary button style with different colors
struct FlowerSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color(.systemGray))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(configuration.isPressed ? Color.black.opacity(0.05) : Color.clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Icon button style for circular icon buttons
struct FlowerIconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isActive: Bool
    let isPrimary: Bool
    
    init(backgroundColor: Color = .flowerButtonBackground, isActive: Bool = false, isPrimary: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isActive = isActive
        self.isPrimary = isPrimary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isPrimary ? .white : Color(.systemGray))
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(isPrimary ? Color.flowerPrimary : Color(.systemGray6))
                    .overlay(
                        Circle()
                            .strokeBorder(isPrimary ? Color.clear : Color(.systemGray4), lineWidth: 1)
                    )
                    .overlay(
                        Circle()
                            .fill(configuration.isPressed ? Color.black.opacity(isPrimary ? 0.1 : 0.05) : Color.clear)
                    )
            )
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
    
    func flowerIconButtonStyle(backgroundColor: Color = .flowerButtonBackground, isActive: Bool = false, isPrimary: Bool = false) -> some View {
        self.buttonStyle(FlowerIconButtonStyle(backgroundColor: backgroundColor, isActive: isActive, isPrimary: isPrimary))
    }
}