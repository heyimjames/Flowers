//
//  ContentView.swift
//  Flowers
//
//  Created by James Frewin on 14/07/2025.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var flowerStore: FlowerStore
    @State private var showingFavorites = false
    @State private var showingSettings = false
    @State private var showDiscoveryCount = true
    @State private var showingFlowerDetail = false
    @State private var showingOnboarding = false
    @State private var showingShareSheet = false
    @Environment(\.scenePhase) var scenePhase
    @State private var wasInBackground = false
    @AppStorage("userName") private var userName = ""
    
    // Timer for pill animation
    let pillAnimationTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.flowerBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Main flower display
                    flowerDisplay
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Error message if any
                    if let errorMessage = flowerStore.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.flowerError)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    // Extra padding for action buttons
                    Color.clear
                        .frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .top, spacing: 0) {
                // Navigation bar
                ZStack {
                    // Centered app title (absolutely centered)
                    Image("FlowersSVG")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .foregroundColor(.flowerTextPrimary)
                        .frame(maxWidth: .infinity)
                    
                    // HStack for pill and settings button
                    HStack {
                        // Animated discovery/countdown pill
                        ZStack {
                            // Discovery count view
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerPrimary)
                                Text("\(flowerStore.totalDiscoveredCount)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.flowerTextPrimary)
                                Text("found")
                                    .font(.system(size: 11))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                            .opacity(showDiscoveryCount ? 1 : 0)
                            .scaleEffect(showDiscoveryCount ? 1 : 0.8)
                            
                            // Countdown view
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerPrimary)
                                if let nextTime = flowerStore.nextFlowerTime {
                                    CountdownText(targetDate: nextTime)
                                        .font(.system(size: 11))
                                        .foregroundColor(.flowerTextSecondary)
                                } else {
                                    Text("Soon")
                                        .font(.system(size: 11))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                            }
                            .opacity(showDiscoveryCount ? 0 : 1)
                            .scaleEffect(showDiscoveryCount ? 0.8 : 1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.flowerPrimary.opacity(0.1))
                        .cornerRadius(16)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDiscoveryCount)
                        
                        Spacer()
                        
                        // Settings button
                        Button {
                            showingSettings = true
                        } label: {
                            SettingsIcon(size: 22, color: .flowerTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.flowerBackground)
            }
            
            // Action buttons pinned to bottom
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Enhanced gradient fade with blur effect simulation
                    ZStack {
                        // Multi-layer gradient for smoother transition
                        LinearGradient(
                            colors: [
                                Color.flowerBackground.opacity(0),
                                Color.flowerBackground.opacity(0.3),
                                Color.flowerBackground.opacity(0.6),
                                Color.flowerBackground.opacity(0.85),
                                Color.flowerBackground.opacity(0.95),
                                Color.flowerBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        
                        // Additional subtle gradient layer
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.flowerBackground.opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }
                    
                    actionButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .background(Color.flowerBackground)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesSheet(flowerStore: flowerStore)
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheet()
                .environmentObject(flowerStore)
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingFlowerDetail) {
            if let flower = flowerStore.currentFlower {
                FlowerDetailSheet(
                    flower: flower,
                    flowerStore: flowerStore,
                    allFlowers: [flower],
                    currentIndex: 0
                )
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.visible)
            }
        }
        .onReceive(pillAnimationTimer) { _ in
            withAnimation {
                showDiscoveryCount.toggle()
            }
        }
        .onAppear {
            // Check if user needs onboarding (starter flower selection)
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") || flowerStore.shouldShowOnboarding {
                // Small delay to ensure Jenny flower is loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingOnboarding = true
                    flowerStore.shouldShowOnboarding = false
                }
            }
        }
        .onChange(of: flowerStore.shouldShowOnboarding) { newValue in
            if newValue {
                showingOnboarding = true
                flowerStore.shouldShowOnboarding = false
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView(flowerStore: flowerStore)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                wasInBackground = true
            case .active:
                if wasInBackground {
                    wasInBackground = false
                    // Check if we have a pending flower and notification badge
                    let badgeCount = UIApplication.shared.applicationIconBadgeNumber
                    if badgeCount > 0 && flowerStore.pendingFlower != nil {
                        // User likely tapped on notification
                        flowerStore.showPendingFlowerIfAvailable()
                    }
                }
            default:
                break
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let flower = flowerStore.currentFlower {
                ShareSheet(flower: flower)
                    .ignoresSafeArea()
            }
        }

    }
    
    private var flowerDisplay: some View {
        VStack(spacing: 24) {
            if let flower = flowerStore.currentFlower {
                // Flower image
                Group {
                    if let imageData = flower.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.flowerCardBackground)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                ProgressView()
                                    .tint(.flowerPrimary)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    showingFlowerDetail = true
                }
                .contentShape(Rectangle()) // Makes entire area tappable
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.3, anchor: .center)
                            .combined(with: .opacity)
                            .combined(with: .move(edge: .bottom)),
                        removal: .scale.combined(with: .opacity)
                    )
                )
                
                // Flower/Bouquet name
                VStack(spacing: 8) {
                                    Text(flower.name)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                    
                    if flower.isBouquet, let holidayName = flower.holidayName {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerSecondary)
                            Text("Special \(holidayName) Collection")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                // Flower details or loading state
                if flower.meaning != nil || flower.properties != nil {
                    VStack(alignment: .leading, spacing: 16) {
                        if let meaning = flower.meaning {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "book")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Meaning")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(meaning)
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(3)
                                    .lineLimit(3)
                            }
                        }
                        
                        if let properties = flower.properties {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "leaf")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Characteristics")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(properties)
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(3)
                                    .lineLimit(3)
                            }
                        }
                        
                        if flower.isBouquet, let bouquetFlowers = flower.bouquetFlowers {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "leaf.circle")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Includes")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(bouquetFlowers.joined(separator: " • "))
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        if let continent = flower.continent {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerPrimary)
                                Text(flower.isBouquet ? "Tradition from \(continent.rawValue)" : "Native to \(continent.rawValue)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                        
                        // Ownership History
                        if flower.hasOwnershipHistory {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.2")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Ownership History")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    // Original owner
                                    if let original = flower.originalOwner {
                                        HStack(spacing: 4) {
                                            Text("🌱")
                                                .font(.system(size: 12))
                                            Text("Originally grown by \(original.name)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.flowerTextSecondary)
                                        }
                                        if let location = original.location {
                                            Text("\(original.transferDate.formatted(date: .abbreviated, time: .omitted)) • \(location)")
                                                .font(.system(size: 11))
                                                .foregroundColor(.flowerTextTertiary)
                                                .padding(.leading, 20)
                                        }
                                    }
                                    
                                    // Previous owners
                                    if !flower.ownershipHistory.isEmpty {
                                        Text("🤝 Previously owned by:")
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        ForEach(flower.ownershipHistory, id: \.id) { owner in
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("• \(owner.name)")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.flowerTextSecondary)
                                                    .padding(.leading, 12)
                                                
                                                if let location = owner.location {
                                                    Text("\(owner.transferDate.formatted(date: .abbreviated, time: .omitted)) • \(location)")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.flowerTextTertiary)
                                                        .padding(.leading, 24)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.flowerCardBackground)
                    .cornerRadius(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if flowerStore.isGenerating {
                    // Show loading state while details are being generated
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.flowerPrimary)
                        Text("Studying this beautiful flower...")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.flowerCardBackground)
                    .cornerRadius(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if flower.imageData != nil {
                    // Show tap to learn more if details aren't available
                    Button(action: {
                        showingFavorites = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerPrimary)
                            Text("Tap to learn more about this flower")
                                .font(.system(size: 13))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.flowerCardBackground)
                    .cornerRadius(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            } else if flowerStore.hasUnrevealedFlower {
                // Reveal state
                ZStack {
                    PulsingFlowerRevealView()
                    
                    // Centered Reveal Button
                    RevealFlowerButton(flowerStore: flowerStore)
                        .frame(maxWidth: 200)
                        .offset(y: 80) // Position it lower in the box
                        .onAppear {
                            // Request fresh location when showing reveal button
                            ContextualFlowerGenerator.shared.requestLocationUpdate()
                        }
                }
            } else {
                // Empty state
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.flowerCardBackground)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "leaf.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.flowerTextTertiary)
                            Text("Your garden awaits...")
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    )
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: flowerStore.currentFlower?.id)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: flowerStore.currentFlower?.meaning)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: flowerStore.hasUnrevealedFlower)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Next flower timing or empty space
            if !flowerStore.hasUnrevealedFlower {
                // Show next flower timing
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(.flowerTextSecondary)
                    if let nextTime = flowerStore.nextFlowerTime {
                        Text("Next flower arrives in ")
                            .font(.system(size: 13))
                            .foregroundColor(.flowerTextSecondary)
                        + Text(nextTime, style: .relative)
                            .font(.system(size: 13))
                            .foregroundColor(.flowerTextSecondary)
                    } else {
                        Text("Next flower arrives soon")
                            .font(.system(size: 13))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            } else {
                // Empty space when flower is ready to reveal
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            
            // Heart button
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    flowerStore.toggleFavorite()
                }
                // Haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                Image(systemName: flowerStore.currentFlower?.isFavorite == true ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundColor(flowerStore.currentFlower?.isFavorite == true ? .flowerSecondary : .flowerTextSecondary)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.flowerButtonBackground.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        flowerStore.currentFlower?.isFavorite == true ? 
                                        Color.flowerSecondary.opacity(0.3) : 
                                        Color.flowerTextTertiary.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            .disabled(flowerStore.currentFlower == nil)
            
            // Share button
            Button(action: {
                shareFlower()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 22))
                    .foregroundColor(.flowerTextSecondary)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.flowerButtonBackground.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.flowerTextTertiary.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .disabled(flowerStore.currentFlower == nil)
            .accessibilityLabel("Share flower image")
            
            // Collection button
            Button(action: { showingFavorites = true }) {
                Image(systemName: "rectangle.grid.2x2")
                    .font(.system(size: 22))
                    .foregroundColor(.flowerTextSecondary)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.flowerButtonBackground.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.flowerTextTertiary.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    private func shareFlower() {
        guard flowerStore.currentFlower != nil else { return }
        showingShareSheet = true
    }
}

// Countdown text view that updates every minute
struct CountdownText: View {
    let targetDate: Date
    @State private var timeRemaining = ""
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeRemaining)
            .onAppear {
                updateTimeRemaining()
            }
            .onReceive(timer) { _ in
                updateTimeRemaining()
            }
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        let interval = targetDate.timeIntervalSince(now)
        
        if interval <= 0 {
            timeRemaining = "Ready!"
            return
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            timeRemaining = "\(hours)h \(minutes)m"
        } else {
            timeRemaining = "\(minutes)m"
        }
    }
}

struct PulsingFlowerRevealView: View {
    @State private var isPulsing = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.flowerPrimary.opacity(0.1),
                        Color.flowerSecondary.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                VStack(spacing: 20) {
                    Image(systemName: "gift")
                        .font(.system(size: 64))
                        .foregroundColor(.flowerPrimary)
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                        .offset(y: -20)
                    
                    Spacer()
                }
                .padding(.top, 60)
            )
            .shadow(color: .flowerPrimary.opacity(0.2), radius: isPulsing ? 25 : 20, y: 10)
            .scaleEffect(isPulsing ? 1.02 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

#Preview {
    ContentView()
}
