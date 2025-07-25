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
    @Environment(\.colorScheme) var colorScheme
    @State private var wasInBackground = false
    @AppStorage("userName") private var userName = ""
    @State private var inspirationalQuote = ""
    @State private var isLoadingQuote = false
    @State private var quoteOpacity: Double = 0.0
    @State private var heartScale: CGFloat = 1.0
    @State private var heartBounce: Bool = false
    @State private var showingAppInfo = false
    @State private var lastQuoteTime: Date = Date()
    
    // Timer for pill animation
    let pillAnimationTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    // Timer for quote rotation
    let quoteRotationTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    // Timer to check for countdown expiration
    let countdownCheckTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ScrollView {
                    VStack(spacing: 20) {
                        // Main flower display
                        flowerDisplay
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        // Error message if any
                        if let errorMessage = flowerStore.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, design: .rounded))
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
                        Button(action: {
                            showingAppInfo = true
                        }) {
                            Image(colorScheme == .dark ? "flowerssvggreen" : "FlowersSVG")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // HStack for pill and settings button
                        HStack {
                            // Animated discovery/countdown pill
                            ZStack {
                                // Discovery count view
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    Text("\(flowerStore.totalDiscoveredCount)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    Text("found")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                                .opacity(showDiscoveryCount ? 1 : 0)
                                .scaleEffect(showDiscoveryCount ? 1 : 0.8)
                                
                                // Countdown view
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                                        if let nextTime = flowerStore.nextFlowerTime {
                        CountdownText(targetDate: nextTime)
                            .environmentObject(flowerStore)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    } else {
                                        Text("Soon")
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                }
                                .opacity(showDiscoveryCount ? 0 : 1)
                                .scaleEffect(showDiscoveryCount ? 0.8 : 1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.flowerPrimary.opacity(0.1))
                            .cornerRadius(25)
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
                        // Enhanced gradient to fade content behind buttons
                        LinearGradient(
                            colors: [
                                Color.flowerBackground.opacity(0),
                                Color.flowerBackground.opacity(0.3),
                                Color.flowerBackground.opacity(0.6),
                                Color.flowerBackground.opacity(0.8),
                                Color.flowerBackground.opacity(0.95),
                                Color.flowerBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        
                        // Solid background behind buttons
                        VStack(spacing: 0) {
                            actionButtons
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                        }
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
                    allFlowers: flowerStore.discoveredFlowers,
                    currentIndex: flowerStore.discoveredFlowers.firstIndex(where: { $0.id == flower.id }) ?? 0
                )
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let flower = flowerStore.currentFlower {
                ShareSheet(flower: flower)
            }
        }
        .onReceive(pillAnimationTimer) { _ in
            withAnimation {
                showDiscoveryCount.toggle()
            }
        }
        .onReceive(countdownCheckTimer) { _ in
            // Only check for countdown expiration if there's actually a countdown active
            if flowerStore.nextFlowerTime != nil && !flowerStore.hasUnrevealedFlower {
                checkCountdownExpiration()
            }
        }
        .onReceive(quoteRotationTimer) { _ in
            // Rotate quotes every 30 seconds when no current flower is shown
            if flowerStore.currentFlower == nil && !flowerStore.hasUnrevealedFlower {
                loadInspirationalQuote()
            }
        }
        .onChange(of: flowerStore.currentFlower) { _, newFlower in
            // Load quote when transitioning to empty state (no current flower)
            if newFlower == nil && !flowerStore.hasUnrevealedFlower && inspirationalQuote.isEmpty {
                loadInspirationalQuote()
            }
        }
        .onChange(of: flowerStore.hasUnrevealedFlower) { _, hasUnrevealed in
            // Load quote when transitioning from reveal state to empty state
            if !hasUnrevealed && flowerStore.currentFlower == nil && inspirationalQuote.isEmpty {
                loadInspirationalQuote()
            }
        }
        .onAppear {
            // Validate and fix any state inconsistencies on app launch
            flowerStore.validateAndFixState()
            
            // Ensure next flower time is loaded
            flowerStore.loadNextFlowerTime()
            
            // Check if there's a pending flower that should be revealed immediately
            // This handles cases where countdown expired while app was closed
            if flowerStore.pendingFlower != nil && !flowerStore.hasUnrevealedFlower {
                if let nextTime = flowerStore.nextFlowerTime {
                    // If countdown has already expired, trigger reveal immediately
                    if Date() >= nextTime {
                        print("ContentView: Found expired countdown on app launch, triggering reveal")
                        flowerStore.showPendingFlowerIfAvailable()
                    }
                } else {
                    // If no nextFlowerTime but we have a pending flower, it should be revealed
                    // This can happen if app was killed/restarted after countdown expired
                    print("ContentView: Found pending flower without timer on app launch, triggering reveal")
                    flowerStore.showPendingFlowerIfAvailable()
                }
            }
            
            // Check if user needs onboarding (starter flower selection)
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") || flowerStore.shouldShowOnboarding {
                // Small delay to ensure Jenny flower is loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingOnboarding = true
                    flowerStore.shouldShowOnboarding = false
                }
            } else {
                // Check if countdown has expired on app launch
                checkCountdownExpiration()
                
                // Show app info on first visit to homescreen
                if !UserDefaults.standard.bool(forKey: "hasSeenAppInfo") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingAppInfo = true
                        UserDefaults.standard.set(true, forKey: "hasSeenAppInfo")
                    }
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
                    // Validate state when returning from background
                    flowerStore.validateAndFixState()
                    
                    // Check if we have a pending flower that should be revealed
                    if flowerStore.pendingFlower != nil && !flowerStore.hasUnrevealedFlower {
                        let badgeCount = UIApplication.shared.applicationIconBadgeNumber
                        let hasExpiredCountdown = flowerStore.nextFlowerTime.map { Date() >= $0 } ?? true
                        
                        // Trigger reveal if:
                        // 1. User tapped notification (badge > 0), OR
                        // 2. Countdown expired while app was in background
                        if badgeCount > 0 || hasExpiredCountdown {
                            print("ContentView: Returning from background, triggering flower reveal (badge: \(badgeCount), expired: \(hasExpiredCountdown))")
                            flowerStore.showPendingFlowerIfAvailable()
                        }
                    }
                }
            default:
                break
            }
        }
        .sheet(isPresented: $showingAppInfo) {
            AppInfoPopover()
                .presentationDetents([.medium])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
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
                .id("flower-image-\(flower.id)") // Stable ID to prevent re-renders
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
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.8)
                    
                    if flower.isBouquet, let holidayName = flower.holidayName {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.flowerSecondary)
                            Text("Special \(holidayName) Collection")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
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
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Meaning")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(meaning)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(5)
                                    .lineLimit(3)
                            }
                        }
                        
                        if let properties = flower.properties {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "leaf")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Characteristics")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(properties)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(5)
                                    .lineLimit(3)
                            }
                        }
                        
                        if flower.isBouquet, let bouquetFlowers = flower.bouquetFlowers {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "leaf.circle")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Includes")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(bouquetFlowers.joined(separator: " • "))
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        if let continent = flower.continent {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.flowerPrimary)
                                Text(flower.isBouquet ? "Tradition from \(continent.rawValue)" : "Native to \(continent.rawValue)")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                        
                        // Ownership History
                        if flower.hasOwnershipHistory {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.2")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    Text("Ownership History")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    // Original owner
                                    if let original = flower.originalOwner {
                                        HStack(spacing: 4) {
                                            Text("🌱")
                                                .font(.system(size: 12, design: .rounded))
                                            Text("Originally grown by \(original.name)")
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundColor(.flowerTextSecondary)
                                        }
                                        if let location = original.location {
                                            Text("\(original.transferDate.formatted(date: .abbreviated, time: .omitted)) • \(location)")
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(.flowerTextTertiary)
                                                .padding(.leading, 20)
                                        }
                                    }
                                    
                                    // Previous owners
                                    if !flower.ownershipHistory.isEmpty {
                                        Text("🤝 Previously owned by:")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        ForEach(flower.ownershipHistory, id: \.id) { owner in
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("• \(owner.name)")
                                                    .font(.system(size: 12, design: .rounded))
                                                    .foregroundColor(.flowerTextSecondary)
                                                    .padding(.leading, 12)
                                                
                                                if let location = owner.location {
                                                    Text("\(owner.transferDate.formatted(date: .abbreviated, time: .omitted)) • \(location)")
                                                        .font(.system(size: 11, design: .rounded))
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
                    .background(
                        ZStack {
                            // Blur background for better contrast
                            Color.flowerCardBackground
                                .opacity(0.8)
                                .blur(radius: 8)
                            
                            // Subtle overlay
                            Color.flowerBackground
                                .opacity(0.4)
                        }
                    )
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(Color.flowerPrimary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Flower action buttons (Share and Favorite)
                    HStack(spacing: 16) {
                        // Favorite button
                        Button(action: {
                            // Toggle favorite immediately
                            flowerStore.toggleFavorite()
                            
                            // Quick heart animation
                            withAnimation(.easeInOut(duration: 0.1)) {
                                heartScale = 1.2
                                heartBounce = true
                            }
                            
                            // Reset animation quickly
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    heartScale = 1.0
                                    heartBounce = false
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: flower.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(flower.isFavorite ? .red : .flowerTextSecondary)
                                    .scaleEffect(heartScale)
                                    .rotationEffect(.degrees(heartBounce ? 10 : 0))
                                Text(flower.isFavorite ? "Favorited" : "Favorite")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.flowerCardBackground)
                            .cornerRadius(20)
                        }
                        
                        // Share button
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                Text("Share")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.flowerCardBackground)
                            .cornerRadius(20)
                        }
                        
                        // Info button
                        Button(action: {
                            showingFlowerDetail = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.flowerPrimary)
                                Text("Details")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.flowerCardBackground)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if flowerStore.isGenerating {
                    // Show loading state while details are being generated
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.flowerPrimary)
                        Text("Studying this beautiful flower...")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        ZStack {
                            // Blur background for better contrast
                            Color.flowerCardBackground
                                .opacity(0.8)
                                .blur(radius: 8)
                            
                            // Subtle overlay
                            Color.flowerBackground
                                .opacity(0.4)
                        }
                    )
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(Color.flowerPrimary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if flower.imageData != nil {
                    // Show tap to learn more if details aren't available
                    Button(action: {
                        showingFavorites = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.flowerPrimary)
                            Text("Tap to learn more about this flower")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            Color.flowerCardBackground
                                .opacity(0.8)
                                .blur(radius: 8)
                            
                            Color.flowerBackground
                                .opacity(0.4)
                        }
                    )
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(Color.flowerPrimary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
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
                // Empty state - quote centered with fixed spacing
                VStack(spacing: 0) {
                    // Push content down from top
                    Color.clear.frame(height: 150)
                    
                    VStack(spacing: 12) {
                        if !inspirationalQuote.isEmpty {
                            // Parse quote and author
                            if let quoteRange = inspirationalQuote.range(of: "\""),
                               let endQuoteRange = inspirationalQuote.range(of: "\"", range: quoteRange.upperBound..<inspirationalQuote.endIndex),
                               let authorRange = inspirationalQuote.range(of: " — ") {
                                
                                let quote = String(inspirationalQuote[quoteRange.upperBound..<endQuoteRange.lowerBound])
                                let author = String(inspirationalQuote[authorRange.upperBound...])
                                
                                // Quote text
                                Text(quote)
                                    .font(.system(size: 18, design: .serif))
                                    .italic()
                                    .foregroundColor(.flowerTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .opacity(0.6 * quoteOpacity)
                                
                                // Author
                                Text("— \(author)")
                                    .font(.system(size: 14, design: .serif))
                                    .foregroundColor(.flowerTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .opacity(0.5 * quoteOpacity)
                            } else {
                                // Fallback - show full text
                                Text(inspirationalQuote)
                                    .font(.system(size: 18, design: .serif))
                                    .italic()
                                    .foregroundColor(.flowerTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .opacity(0.6 * quoteOpacity)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity)
                    
                    // Push content up from bottom buttons
                    Color.clear.frame(height: 200)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            // Only load quote if we're showing empty state (no current flower, no unrevealed flower)
            if flowerStore.currentFlower == nil && !flowerStore.hasUnrevealedFlower {
                loadInspirationalQuote()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Load a fresh quote when returning to the app (only if showing empty state)
            if flowerStore.currentFlower == nil && !flowerStore.hasUnrevealedFlower {
                loadInspirationalQuote()
            }
        }
        .onOpenURL { url in
            handleWidgetDeepLink(url: url)
        }
    }
    
    private func loadInspirationalQuote() {
        // Don't load if already loading or if we just loaded a quote recently
        guard !isLoadingQuote else { return }
        
        // Prevent too frequent quote updates (minimum 15 seconds between loads)
        let timeSinceLastQuote = Date().timeIntervalSince(lastQuoteTime)
        guard timeSinceLastQuote >= 15 else { return }
        
        isLoadingQuote = true
        quoteOpacity = 0.0
        lastQuoteTime = Date()
        
        Task {
            do {
                let quote = try await OpenAIService.shared.generateInspirationalQuote()
                await MainActor.run {
                    self.inspirationalQuote = quote
                    self.isLoadingQuote = false
                    // Fade in the quote
                    withAnimation(.easeIn(duration: 0.6)) {
                        self.quoteOpacity = 1.0
                    }
                }
            } catch {
                // Use fallback quote if API fails
                let fallbackQuote = "\"The earth laughs in flowers.\" — Ralph Waldo Emerson"
                await MainActor.run {
                    self.inspirationalQuote = fallbackQuote
                    self.isLoadingQuote = false
                    // Fade in the fallback quote
                    withAnimation(.easeIn(duration: 0.6)) {
                        self.quoteOpacity = 1.0
                    }
                }
                print("Failed to load inspirational quote: \(error)")
            }
        }
    }
    
    private func checkCountdownExpiration() {
        // Check if there's a pending flower and the countdown has expired
        if let nextTime = flowerStore.nextFlowerTime,
           Date() >= nextTime,
           flowerStore.pendingFlower != nil,
           !flowerStore.hasUnrevealedFlower {
            // Countdown has expired, automatically show the reveal screen
            print("ContentView: Countdown expired, triggering flower reveal")
            flowerStore.showPendingFlowerIfAvailable()
        }
    }
    
    private func handleWidgetDeepLink(url: URL) {
        guard url.scheme == "flowers" else { return }
        
        switch url.host {
        case "reveal":
            // Widget tapped to reveal pending flower
            if flowerStore.hasUnrevealedFlower {
                // Flower is ready to be revealed, no action needed
                // The UI will automatically show the reveal button
                print("Widget: Navigated to reveal pending flower")
            }
            
        case "flower":
            // Widget tapped on specific flower
            let pathComponents = url.pathComponents
            if pathComponents.count > 1 {
                let flowerIdString = pathComponents[1]
                if let flowerId = UUID(uuidString: flowerIdString),
                   let flower = flowerStore.discoveredFlowers.first(where: { $0.id == flowerId }) {
                    // Set the current flower and show details
                    flowerStore.currentFlower = flower
                    showingFlowerDetail = true
                    print("Widget: Navigated to flower: \(flower.name)")
                }
            }
            
        case "collection":
            // Widget tapped to open collection
            showingFavorites = true
            print("Widget: Opened collection")
            
        case "home":
            // Widget tapped to open main app (default behavior)
            print("Widget: Navigated to home")
            
        default:
            // Unknown deep link, just open the app
            print("Widget: Unknown deep link: \(url)")
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Next flower timing tag
            if !flowerStore.hasUnrevealedFlower {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white)
                    Text("Next flower arrives")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    if let nextTime = flowerStore.nextFlowerTime {
                        Text("in \(nextTime, style: .relative)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Text("soon")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Blur effect background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                        
                        // Brand green overlay
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.flowerPrimary)
                    }
                )
            }
            
            // Collection button (centered)
            HStack {
                Button(action: { showingFavorites = true }) {
                    HStack(spacing: 12) {
                        Image("planticon")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color(red: 186/255, green: 214/255, blue: 130/255))
                            .frame(width: 20, height: 20)
                        Text("See My Collection")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            // Blur effect background
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                            
                            // Brand green overlay
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.flowerPrimary)
                        }
                    )
                }
            }
        }
    }
    
}

// App info modal
struct AppInfoPopover: View {
    var body: some View {
        VStack(spacing: 16) {
            // App icon only
            Image("FlowersSVG")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
            
            // Personal message from James
            Text("Hey! I made Flowers as a fun way to collect something new each day.\n\nOpen flowers in different places to grow your collection. Each location unlocks unique flowers based on weather, time, and special occasions.\n\nGift flowers to friends and build collections together - there's some surprise ones in there too.\n\n— James")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.flowerTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.flowerBackground)
    }
}

// Countdown text view that updates every minute
struct CountdownText: View {
    let targetDate: Date
    @State private var timeRemaining = ""
    @EnvironmentObject var flowerStore: FlowerStore
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
            // Note: ContentView timer handles the actual reveal trigger to avoid race conditions
            return
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            timeRemaining = "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            timeRemaining = "\(minutes)m"
        } else {
            // Less than a minute remaining
            let seconds = Int(interval) % 60
            timeRemaining = "\(seconds)s"
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
                        .font(.system(size: 64, design: .rounded))
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

// Simple flower icon shape
struct SimpleFlowerIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Draw 5 petals
        for i in 0..<5 {
            let angle = CGFloat(i) * (2 * .pi / 5) - .pi / 2  // Start from top
            let petalCenter = CGPoint(
                x: center.x + cos(angle) * radius * 0.5,
                y: center.y + sin(angle) * radius * 0.5
            )
            
            // Create elliptical petal
            path.addEllipse(in: CGRect(
                x: petalCenter.x - radius * 0.35,
                y: petalCenter.y - radius * 0.5,
                width: radius * 0.7,
                height: radius * 1.0
            ))
        }
        
        // Add center circle
        path.addEllipse(in: CGRect(
            x: center.x - radius * 0.25,
            y: center.y - radius * 0.25,
            width: radius * 0.5,
            height: radius * 0.5
        ))
        
        return path
    }
}

#Preview {
    ContentView()
}
