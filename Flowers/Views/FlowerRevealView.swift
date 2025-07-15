import SwiftUI
import UIKit

struct FlowerRevealView: View {
    let flower: AIFlower
    @EnvironmentObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var isRevealed = false
    @State private var showConfetti = false
    @State private var holdProgress: CGFloat = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var isHolding = false
    @State private var holdTimer: Timer?
    @State private var hapticTimer: Timer?
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Title
                    VStack(spacing: 8) {
                        Text("A New Flower Awaits")
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundColor(.flowerTextPrimary)
                        
                        Text("Hold to reveal your discovery")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.top, 40)
                    .opacity(isRevealed ? 0 : 1)
                    
                    // Flower image with blur/reveal effect
                    ZStack {
                        if let imageData = flower.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 300, maxHeight: 300)
                                .cornerRadius(24)
                                .blur(radius: isRevealed ? 0 : 25)
                                .scaleEffect(isRevealed ? 1.1 : 1)
                                .offset(x: shakeOffset)
                                .animation(isRevealed ? .spring(response: 0.6, dampingFraction: 0.8) : .linear(duration: 0.1), value: isRevealed)
                                .animation(.linear(duration: 0.1), value: shakeOffset)
                        }
                        
                        // Confetti overlay
                        if showConfetti {
                            ForEach(confettiPieces) { piece in
                                ConfettiView(piece: piece)
                            }
                        }
                    }
                    .frame(height: 300)
                    
                    if isRevealed {
                        // Revealed state - show flower info
                        VStack(spacing: 12) {
                            Text(flower.name)
                                .font(.system(size: 28, weight: .semibold, design: .serif))
                                .foregroundColor(.flowerTextPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(flower.descriptor)
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    Spacer()
                    
                    // Action button
                    if !isRevealed {
                        // Hold to reveal button
                        ZStack {
                            // Progress background
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.flowerPrimary.opacity(0.1))
                                .frame(height: 64)
                            
                            // Progress fill
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.flowerPrimary, Color.flowerSecondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * holdProgress, height: 64)
                                    .animation(.linear(duration: 0.1), value: holdProgress)
                            }
                            .frame(height: 64)
                            .cornerRadius(20)
                            
                            // Button content
                            HStack(spacing: 12) {
                                Image(systemName: isHolding ? "gift.fill" : "gift")
                                    .font(.system(size: 20, weight: .medium))
                                Text("Hold to Reveal")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(holdProgress > 0.5 ? .white : .flowerPrimary)
                            .animation(.easeInOut, value: holdProgress)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 32)
                        .onLongPressGesture(
                            minimumDuration: .infinity,
                            maximumDistance: .infinity,
                            pressing: { isPressing in
                                handlePressing(isPressing)
                            },
                            perform: {}
                        )
                    } else {
                        // Continue button
                        Button(action: {
                            // Use the proper reveal method to handle everything correctly
                            flowerStore.revealPendingFlower()
                            dismiss()
                        }) {
                            HStack {
                                Text("Continue to Garden")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.flowerPrimary)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func handlePressing(_ isPressing: Bool) {
        if isPressing && !isRevealed {
            startHolding()
        } else {
            stopHolding()
        }
    }
    
    private func startHolding() {
        isHolding = true
        holdProgress = 0
        
        // Start progress timer
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            holdProgress += 0.05 / 3.0 // 3 seconds total
            
            if holdProgress >= 1.0 {
                revealFlower()
            }
        }
        
        // Start shake animation
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isHolding {
                timer.invalidate()
                shakeOffset = 0
            } else {
                let intensity = holdProgress * 5
                shakeOffset = CGFloat.random(in: -intensity...intensity)
            }
        }
        
        // Start haptic feedback
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let intensity = min(holdProgress, 1.0)
            
            if intensity < 0.3 {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            } else if intensity < 0.7 {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            } else {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
            }
        }
    }
    
    private func stopHolding() {
        isHolding = false
        holdTimer?.invalidate()
        holdTimer = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
        
        withAnimation(.spring()) {
            holdProgress = 0
            shakeOffset = 0
        }
    }
    
    private func revealFlower() {
        stopHolding()
        
        // Success haptic
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Create confetti
        createConfetti()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isRevealed = true
            showConfetti = true
        }
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showConfetti = false
            confettiPieces.removeAll()
        }
    }
    
    private func createConfetti() {
        confettiPieces = (0..<200).map { _ in
            ConfettiPiece(
                color: Bool.random() ? .flowerPrimary : .white,
                x: CGFloat.random(in: -150...150),
                y: 0,
                size: CGFloat.random(in: 4...8),
                rotation: Double.random(in: 0...360),
                velocity: CGFloat.random(in: 200...400)
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let rotation: Double
    let velocity: CGFloat
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: piece.size / 3)
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 1.5)
            .rotationEffect(.degrees(rotation))
            .offset(x: piece.x, y: piece.y + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 3)) {
                    offsetY = piece.velocity
                    opacity = 0
                    rotation = piece.rotation + Double.random(in: 180...720)
                }
            }
    }
} 