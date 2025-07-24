import SwiftUI
import UIKit

// Smooth progress tracking using DisplayLink
class HoldProgressTracker: ObservableObject {
    @Published var progress: CGFloat = 0
    @Published var shakeOffset: CGFloat = 0
    
    private var displayLink: CADisplayLink?
    private var startTime: Date?
    private let duration: TimeInterval = 3.0
    private var isActive = false
    
    func start() {
        guard !isActive else { return }
        isActive = true
        startTime = Date()
        progress = 0
        
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        isActive = false
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            progress = 0
            shakeOffset = 0
        }
    }
    
    @objc private func updateProgress() {
        guard let startTime = startTime, isActive else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let newProgress = min(CGFloat(elapsed / duration), 1.0)
        
        // Update progress without animation for smoothness
        progress = newProgress
        
        // Update shake with smooth interpolation
        if newProgress < 1.0 {
            let intensity = newProgress * 3
            let time = elapsed * 10
            shakeOffset = sin(time) * intensity + cos(time * 1.5) * intensity * 0.5
        } else {
            shakeOffset = 0
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

struct FlowerRevealView: View {
    let flower: AIFlower
    @EnvironmentObject var flowerStore: FlowerStore
    @Environment(\.dismiss) private var dismiss
    @State private var isRevealed = false
    @State private var showConfetti = false
    @StateObject private var progressTracker = HoldProgressTracker()
    @State private var lastHapticLevel = 0
    
    // Enhanced haptic generators
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // Haptic timing for complex patterns
    @State private var hapticTimer: Timer?
    
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
                                    .offset(x: progressTracker.shakeOffset)
                                    .animation(isRevealed ? .interpolatingSpring(stiffness: 50, damping: 8) : nil, value: isRevealed)
                            }
                        }
                        
                        // Flower info (shown when revealed)
                        if isRevealed {
                            VStack(spacing: 12) {
                                Text(flower.name)
                                    .font(.system(size: 28, weight: .light, design: .serif))
                                    .foregroundColor(.flowerTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .minimumScaleFactor(0.8)
                                    .padding(.horizontal, 16)
                                
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
                        // Hold to reveal button with proper masking
                        HoldToRevealButton(
                            progress: progressTracker.progress,
                            onPressChanged: { isPressing in
                                handlePressing(isPressing)
                            }
                        )
                        .padding(.horizontal, 32)
                        .padding(.bottom, 50)
                    } else {
                        // Continue button
                        Button(action: {
                            // Use the proper reveal method to handle everything correctly
                            flowerStore.revealPendingFlower()
                            dismiss()
                        }) {
                            Text("Add to Collection")
                        }
                        .flowerButtonStyle()
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
            // Prepare all haptic generators
            lightImpact.prepare()
            mediumImpact.prepare()
            heavyImpact.prepare()
            selectionFeedback.prepare()
            notificationFeedback.prepare()
        }
        .onChange(of: progressTracker.progress) { newProgress in
            handleHapticFeedback(newProgress)
            if newProgress >= 1.0 {
                revealFlower()
            }
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
            progressTracker.start()
            lastHapticLevel = 0
            startHapticStory()
        } else {
            progressTracker.stop()
            stopHapticStory()
        }
    }
    
    private func startHapticStory() {
        // Initial "seed planting" - gentle tap
        lightImpact.impactOccurred()
        
        // Start the growing pattern
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            let progress = progressTracker.progress
            performHapticStorybeat(progress)
        }
    }
    
    private func stopHapticStory() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    private func performHapticStorybeat(_ progress: CGFloat) {
        // Create a growing flower story through haptics
        switch progress {
        case 0.0..<0.1:
            // Seeds settling - very gentle, occasional taps
            if Int.random(in: 0...2) == 0 {
                lightImpact.impactOccurred()
            }
            
        case 0.1..<0.3:
            // First sprout - gentle but more frequent
            if Int.random(in: 0...1) == 0 {
                lightImpact.impactOccurred()
            }
            
        case 0.3..<0.5:
            // Growing stem - rhythmic medium taps
            mediumImpact.impactOccurred()
            
        case 0.5..<0.7:
            // Leaves unfurling - alternating light and medium
            if Int.random(in: 0...1) == 0 {
                lightImpact.impactOccurred()
            } else {
                mediumImpact.impactOccurred()
            }
            
        case 0.7..<0.85:
            // Bud forming - building intensity
            mediumImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.lightImpact.impactOccurred()
            }
            
        case 0.85..<0.95:
            // Petals beginning to open - complex pattern
            heavyImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                self.mediumImpact.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                self.lightImpact.impactOccurred()
            }
            
        case 0.95..<1.0:
            // Final bloom - crescendo
            heavyImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.mediumImpact.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                self.lightImpact.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                self.selectionFeedback.selectionChanged()
            }
            
        default:
            break
        }
    }
    
    private func handleHapticFeedback(_ progress: CGFloat) {
        // Additional milestone haptics for major progress points
        let currentLevel = Int(progress * 20) // More granular levels
        
        if currentLevel > lastHapticLevel {
            lastHapticLevel = currentLevel
            
            switch currentLevel {
            case 2: // 10% - First sprout
                performSproutHaptic()
            case 6: // 30% - Growing strong
                performGrowthHaptic()
            case 10: // 50% - Halfway bloom
                performHalfwayHaptic()
            case 14: // 70% - Bud forming
                performBudHaptic()
            case 17: // 85% - Petals opening
                performPetalHaptic()
            case 19: // 95% - Almost there
                performAlmostReadyHaptic()
            default:
                break
            }
        }
    }
    
    // Individual haptic story moments
    private func performSproutHaptic() {
        lightImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightImpact.impactOccurred()
        }
    }
    
    private func performGrowthHaptic() {
        mediumImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.mediumImpact.impactOccurred()
        }
    }
    
    private func performHalfwayHaptic() {
        heavyImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.mediumImpact.impactOccurred()
        }
    }
    
    private func performBudHaptic() {
        mediumImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            self.mediumImpact.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.heavyImpact.impactOccurred()
        }
    }
    
    private func performPetalHaptic() {
        selectionFeedback.selectionChanged()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heavyImpact.impactOccurred()
        }
    }
    
    private func performAlmostReadyHaptic() {
        heavyImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.heavyImpact.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            self.mediumImpact.impactOccurred()
        }
    }
    
    private func revealFlower() {
        progressTracker.stop()
        stopHapticStory()
        
        // Epic reveal haptic sequence
        performFlowerRevealHaptic()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isRevealed = true
            showConfetti = true
        }
    }
    
    private func performFlowerRevealHaptic() {
        // The flower blooms! - Epic haptic crescendo
        heavyImpact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.heavyImpact.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mediumImpact.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.lightImpact.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.selectionFeedback.selectionChanged()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.notificationFeedback.notificationOccurred(.success)
        }
        
        // Gentle afterglow - flower settling into its beauty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.lightImpact.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.lightImpact.impactOccurred()
        }
    }
    
}

// Custom button component with proper masking
struct HoldToRevealButton: View {
    let progress: CGFloat
    let onPressChanged: (Bool) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.flowerPrimary.opacity(0.1))
                
                // Progress fill properly masked
                LinearGradient(
                    colors: [Color.flowerPrimary, Color.flowerSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    // Use a shape that fills from left to right
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: geometry.size.width * progress)
                        Spacer()
                    }
                )
                .mask(RoundedRectangle(cornerRadius: 20))
                
                // Button content
                HStack(spacing: 12) {
                    Image(systemName: progress > 0 ? "gift.fill" : "gift")
                        .font(.system(size: 20, weight: .medium))
                    Text("Hold to Reveal")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(progress > 0.5 ? .white : .flowerPrimary)
                .animation(.easeInOut(duration: 0.2), value: progress > 0.5)
            }
        }
        .frame(height: 64)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: onPressChanged,
            perform: {}
        )
    }
}

 