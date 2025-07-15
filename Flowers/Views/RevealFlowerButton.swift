import SwiftUI

struct RevealFlowerButton: View {
    @ObservedObject var flowerStore: FlowerStore
    @State private var progress: CGFloat = 0
    @State private var isPressed = false
    @State private var showConfetti = false
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var timer: Timer?
    @State private var hapticTimer: Timer?
    @State private var hapticIntensity: CGFloat = 0
    
    let totalDuration: Double = 3.0
    let updateInterval: Double = 0.05
    
    var body: some View {
        ZStack {
            // Main button
            GeometryReader { geometry in
                ZStack {
                    // Background with progress fill
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.flowerPrimary.opacity(0.1))
                        .overlay(
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.flowerPrimary.opacity(0.8),
                                                Color.flowerSecondary.opacity(0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress)
                                    .animation(.linear(duration: updateInterval), value: progress)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.flowerPrimary.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Button content
                    HStack(spacing: 8) {
                        Image(systemName: "gift")
                            .font(.system(size: 18, weight: .semibold))
                        Text(isPressed ? "Hold to Reveal..." : "Reveal Flower")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(progress > 0.5 ? .white : .flowerPrimary)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                }
            }
            .frame(height: 56)
            
            // Confetti overlay
            if showConfetti {
                ForEach(confettiPieces) { piece in
                    ConfettiView(piece: piece)
                }
            }
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                if pressing {
                    startRevealing()
                } else {
                    stopRevealing()
                }
            },
            perform: {}
        )
    }
    
    private func startRevealing() {
        isPressed = true
        progress = 0
        hapticIntensity = 0
        
        // Light haptic to start
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Start progress timer
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            progress += CGFloat(updateInterval / totalDuration)
            
            if progress >= 1.0 {
                completeReveal()
            }
        }
        
        // Start haptic feedback timer
        var hapticCounter = 0
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            hapticCounter += 1
            
            // Calculate haptic frequency based on progress
            let hapticFrequency = Int(10 - (progress * 8)) // Faster as progress increases
            
            if hapticCounter % hapticFrequency == 0 {
                // Increase haptic intensity as progress increases
                if progress > 0.85 {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                } else if progress > 0.6 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else if progress > 0.3 {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else if progress > 0.1 {
                    // Very light taps at the beginning
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            
            // Add extra haptics when reaching milestones
            if progress >= 0.25 && progress < 0.26 ||
               progress >= 0.5 && progress < 0.51 ||
               progress >= 0.75 && progress < 0.76 {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
    
    private func stopRevealing() {
        isPressed = false
        timer?.invalidate()
        timer = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
        
        // Animate progress back to 0
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            progress = 0
        }
    }
    
    private func completeReveal() {
        timer?.invalidate()
        timer = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
        
        // Big haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Create confetti
        createConfetti()
        
        // Show confetti
        withAnimation {
            showConfetti = true
        }
        
        // Reveal the flower after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                flowerStore.revealPendingFlower()
            }
            
            // Reset button state
            isPressed = false
            progress = 0
        }
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            showConfetti = false
            confettiPieces.removeAll()
        }
    }
    
    private func createConfetti() {
        confettiPieces = (0..<200).map { index in
            // Create multiple layers of explosion for depth
            let layer = index % 3
            let angleVariation = Double.random(in: -15...15) * .pi / 180.0
            let baseAngle = Double(index) * (360.0 / 67.0) * .pi / 180.0 + angleVariation
            
            // Different velocities for different layers
            let velocityMultiplier: CGFloat = layer == 0 ? 1.0 : (layer == 1 ? 0.7 : 0.5)
            let baseVelocity = CGFloat.random(in: 200...400) * velocityMultiplier
            
            // Mix of colors with some variation
            let colorChoice = index % 5
            let color: Color = {
                switch colorChoice {
                case 0, 1: return Color.flowerPrimary
                case 2: return Color.flowerSecondary
                case 3: return Color.white
                default: return Color.flowerPrimary.opacity(0.7)
                }
            }()
            
            return ConfettiPiece(
                id: UUID(),
                color: color,
                x: 0, // Start from center
                y: 0, // Start from center  
                size: CGFloat.random(in: 3...12),
                rotation: Double.random(in: 0...360),
                velocity: baseVelocity,
                angle: baseAngle
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    let color: Color
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let rotation: Double
    let velocity: CGFloat
    let angle: Double
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var position = CGPoint.zero
    @State private var velocity = CGPoint.zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    @State private var rotation: Double = 0
    @State private var timer: Timer?
    
    private let gravity: CGFloat = 980 // pixels/second²
    private let airResistance: CGFloat = 0.02
    private let terminalVelocity: CGFloat = 500
    
    var body: some View {
        Group {
            if Bool.random() {
                // Mix of shapes for variety
                RoundedRectangle(cornerRadius: piece.size / 4)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size * 0.6)
            } else {
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            }
        }
        .offset(x: position.x, y: position.y)
        .opacity(opacity)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            startPhysicsAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startPhysicsAnimation() {
        // Initial velocity based on angle
        velocity = CGPoint(
            x: cos(piece.angle) * piece.velocity,
            y: sin(piece.angle) * piece.velocity * 0.8 - 200 // Initial upward boost
        )
        
        // Physics update timer
        timer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { _ in
            updatePhysics()
        }
        
        // Fade out over time
        withAnimation(.linear(duration: 3.0)) {
            opacity = 0
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 3.0)) {
            rotation = Double.random(in: 360...1080) * (Bool.random() ? 1 : -1)
        }
    }
    
    private func updatePhysics() {
        // Apply gravity
        velocity.y += gravity * (1/60.0)
        
        // Apply air resistance
        velocity.x *= (1 - airResistance)
        velocity.y = min(velocity.y, terminalVelocity) // Terminal velocity
        
        // Update position
        position.x += velocity.x * (1/60.0)
        position.y += velocity.y * (1/60.0)
        
        // Stop when off screen
        if position.y > UIScreen.main.bounds.height {
            timer?.invalidate()
        }
    }
} 