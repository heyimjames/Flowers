import SwiftUI

struct RevealFlowerButton: View {
    @ObservedObject var flowerStore: FlowerStore
    @State private var progress: CGFloat = 0
    @State private var isPressed = false
    @State private var showConfetti = false
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
        }
        .flowerConfetti(isActive: $showConfetti)
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
        }
    }
} 