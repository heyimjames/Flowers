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
    @State private var shakeTimer: Timer?
    @State private var lastHapticLevel = 0
    
    // Haptic generators
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
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
                        }
                        
                        // Flower info (shown when revealed)
                        if isRevealed {
                            VStack(spacing: 12) {
                                Text(flower.name)
                                    .font(.system(size: 28, weight: .light, design: .serif))
                                    .foregroundColor(.flowerTextPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text(capitalizeWords(flower.descriptor))
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
                                .frame(width: geometry.size.width * holdProgress, height: 64)
                                .mask(RoundedRectangle(cornerRadius: 20))
                                .animation(.linear(duration: 0.1), value: holdProgress)
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
                                Text("Add to Collection")
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
        .flowerConfetti(isActive: $showConfetti)
        .onAppear {
            // Prepare haptic generators
            lightImpact.prepare()
            mediumImpact.prepare()
            heavyImpact.prepare()
            selectionFeedback.prepare()
        }
    }
    
    private func capitalizeWords(_ text: String) -> String {
        text.split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
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
        lastHapticLevel = 0
        
        // Initial haptic
        lightImpact.impactOccurred()
        
        // Track start time for accurate progress
        let startTime = Date()
        
        // Single timer for both progress and shake
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Calculate progress based on elapsed time
            let elapsed = Date().timeIntervalSince(startTime)
            holdProgress = min(CGFloat(elapsed / 3.0), 1.0)
            
            // Update shake
            if isHolding {
                let intensity = holdProgress * 5
                shakeOffset = CGFloat.random(in: -intensity...intensity)
            }
            
            // Haptic feedback based on progress
            handleHapticFeedback()
            
            // Check if complete
            if holdProgress >= 1.0 {
                revealFlower()
            }
        }
    }
    
    private func handleHapticFeedback() {
        let currentLevel = Int(holdProgress * 10)
        
        if currentLevel > lastHapticLevel {
            lastHapticLevel = currentLevel
            
            switch currentLevel {
            case 1...3:
                // Light taps for early progress
                lightImpact.impactOccurred()
            case 4...6:
                // Medium taps for middle progress
                mediumImpact.impactOccurred()
            case 7...8:
                // Heavy taps for near completion
                heavyImpact.impactOccurred()
            case 9:
                // Selection feedback right before reveal
                selectionFeedback.selectionChanged()
            case 10:
                // Final heavy impact
                heavyImpact.impactOccurred()
            default:
                break
            }
        }
    }
    
    private func stopHolding() {
        isHolding = false
        holdTimer?.invalidate()
        holdTimer = nil
        shakeTimer?.invalidate()
        shakeTimer = nil
        lastHapticLevel = 0
        
        withAnimation(.spring()) {
            holdProgress = 0
            shakeOffset = 0
        }
    }
    
    private func revealFlower() {
        stopHolding()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isRevealed = true
            showConfetti = true
        }
    }
    
}

 