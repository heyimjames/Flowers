//
//  ContentView.swift
//  Flowers
//
//  Created by James Frewin on 14/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var flowerStore = FlowerStore()
    @State private var showingGenerator = false
    @State private var showingFavorites = false
    @State private var showingShare = false
    @State private var showingSettings = false
    @State private var showDiscoveryCount = true
    
    // Timer for pill animation
    let pillAnimationTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.flowerBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed navigation bar at top
                ZStack {
                    // Centered app title
                    Text("Flowers")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(.flowerTextPrimary)
                        .frame(maxWidth: .infinity)
                    
                    // Overlay with pill and settings
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
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 16)
                .background(Color.flowerBackground)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Main flower display
                        flowerDisplay
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
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
        .sheet(isPresented: $showingGenerator) {
            GeneratorSheet(flowerStore: flowerStore)
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
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
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        .onReceive(pillAnimationTimer) { _ in
            withAnimation {
                showDiscoveryCount.toggle()
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
                .transition(.scale.combined(with: .opacity))
                
                // Flower name
                Text(flower.name)
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
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
                                        .font(.system(size: 14, weight: .semibold))
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
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.flowerTextPrimary)
                                }
                                
                                Text(properties)
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextSecondary)
                                    .lineSpacing(3)
                                    .lineLimit(3)
                            }
                        }
                        
                        if let continent = flower.continent {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerPrimary)
                                Text("Native to \(continent.rawValue)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.flowerTextSecondary)
                            }
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
                        VStack(spacing: 16) {
                            Image(systemName: "gift")
                                .font(.system(size: 48))
                                .foregroundColor(.flowerPrimary)
                            Text("A new flower awaits...")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.flowerTextPrimary)
                            Text("Tap 'Reveal Flower' below")
                                .font(.system(size: 14))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    )
                    .shadow(color: .flowerPrimary.opacity(0.2), radius: 20, y: 10)
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
            // Find/Reveal button
            if flowerStore.hasUnrevealedFlower {
                Button(action: { 
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        flowerStore.revealPendingFlower()
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gift")
                        Text("Reveal Flower")
                    }
                }
                .buttonStyle(FlowerPrimaryButtonStyle())
            } else if flowerStore.debugAnytimeGenerations {
                Button(action: { showingGenerator = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Find Flower")
                    }
                }
                .buttonStyle(FlowerPrimaryButtonStyle())
                .disabled(flowerStore.isGenerating)
            } else {
                // Show next flower timing
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(.flowerTextSecondary)
                    Text("Next flower arrives randomly today")
                        .font(.system(size: 13))
                        .foregroundColor(.flowerTextSecondary)
                }
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
                showingShare = true
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
            
            // Collection button (was favorites)
            Button(action: { showingFavorites = true }) {
                ZStack(alignment: .topTrailing) {
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
                    
                    // Badge for favorites count
                    if flowerStore.favorites.count > 0 {
                        Text("\(flowerStore.favorites.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.flowerSecondary)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
    }
    
    private func shareFlower() {
        guard let flower = flowerStore.currentFlower,
              let imageData = flower.imageData,
              let image = UIImage(data: imageData) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image, flower.name],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
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

#Preview {
    ContentView()
}
