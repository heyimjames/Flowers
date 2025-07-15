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
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack {
                    // Title at top (only shown when not revealed)
                    if !isRevealed {
                        VStack(spacing: 8) {
                            Text("A Flower for You")
                                .font(.system(size: 32, weight: .light, design: .serif))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Text("Hold to reveal your discovery")
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary)
                        }
                        .padding(.top, 80)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    // Centered content area
                    VStack(spacing: 24) {
                        // Flower image
                        ZStack {
                            if let imageData = flower.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 300, maxHeight: 300)
                                    .cornerRadius(24)
                                    .blur(radius: isRevealed ? 0 : 30)
                                    .scaleEffect(isRevealed ? 1.05 : 1)
                                    .offset(x: shakeOffset)
                                    .animation(isRevealed ? .interpolatingSpring(stiffness: 50, damping: 8) : .linear(duration: 0.05), value: isRevealed)
                                    .animation(.linear(duration: 0.05), value: shakeOffset)
                            }
                            
                            // Confetti overlay
                            if showConfetti {
                                ForEach(confettiPieces) { piece in
                                    ConfettiView(piece: piece)
                                }
                            }
                        }
                        
                        // Flower info (shown when revealed)
                        if isRevealed {
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
                    }
                    
                    Spacer()
                    
                    // Action button at bottom
                    if !isRevealed {
                        // Hold to reveal button
                        ZStack {
                            // Progress background
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.flowerPrimary.opacity(0.1))
                                .frame(height: 64)
                            
                            // Progress fill with mask
                            GeometryReader { geometry in
                                LinearGradient(
                                    colors: [Color.flowerPrimary, Color.flowerSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: geometry.size.width, height: 64)
                                .mask(
                                    HStack(spacing: 0) {
                                        Rectangle()
                                            .frame(width: geometry.size.width * holdProgress)
                                        Spacer(minLength: 0)
                                    }
                                )
                                .mask(RoundedRectangle(cornerRadius: 20))
                            }
                            .frame(height: 64)
                            
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
                        .padding(.bottom, 50)
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
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
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
        
        // Start progress timer with smoother animation
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            withAnimation(.linear(duration: 0.016)) {
                holdProgress = min(holdProgress + 0.016 / 3.0, 1.0) // 3 seconds total
            }
            
            if holdProgress >= 1.0 {
                revealFlower()
            }
        }
        
        // Start shake animation
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !isHolding {
                timer.invalidate()
                withAnimation(.linear(duration: 0.05)) {
                    shakeOffset = 0
                }
            } else {
                let intensity = holdProgress * 5
                withAnimation(.linear(duration: 0.05)) {
                    shakeOffset = CGFloat.random(in: -intensity...intensity)
                }
            }
        }
        

    }
    
    private func stopHolding() {
        isHolding = false
        holdTimer?.invalidate()
        holdTimer = nil
        
        withAnimation(.spring()) {
            holdProgress = 0
            shakeOffset = 0
        }
    }
    
    private func revealFlower() {
        stopHolding()
        
        // Create confetti
        createConfetti()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isRevealed = true
            showConfetti = true
        }
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showConfetti = false
            confettiPieces.removeAll()
        }
    }
    
    private func createConfetti() {
        let colors: [Color] = [.flowerPrimary, .flowerSecondary, .yellow, .pink, .purple, .orange]
        confettiPieces = (0..<500).map { i in
            ConfettiPiece(
                color: colors.randomElement() ?? .flowerPrimary,
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -100...100),
                size: CGFloat.random(in: 8...16),
                rotation: Double.random(in: 0...360),
                velocity: CGFloat.random(in: 300...600)
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
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Different shapes for variety
            if Int.random(in: 0...2) == 0 {
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            } else if Int.random(in: 0...1) == 0 {
                Star(corners: 5, smoothness: 0.5)
                    .fill(piece.color)
                    .frame(width: piece.size * 1.2, height: piece.size * 1.2)
            } else {
                RoundedRectangle(cornerRadius: piece.size / 4)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size * 1.3)
            }
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .offset(x: piece.x + offsetX, y: piece.y + offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 4)) {
                offsetY = piece.velocity
                offsetX = CGFloat.random(in: -100...100)
                opacity = 0
                rotation = piece.rotation + Double.random(in: 360...1080)
                scale = 0.3
            }
        }
    }
}

// Star shape for confetti variety
struct Star: Shape {
    let corners: Int
    let smoothness: Double
    
    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / CGFloat(corners * 2)
        let innerRadius = rect.width / 4
        let outerRadius = rect.width / 2
        
        var path = Path()
        
        for corner in 0..<corners * 2 {
            let radius = corner.isMultiple(of: 2) ? outerRadius : innerRadius
            let x = center.x + cos(currentAngle) * radius
            let y = center.y + sin(currentAngle) * radius
            
            if corner == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            currentAngle += angleAdjustment
        }
        
        path.closeSubpath()
        return path
    }
} 