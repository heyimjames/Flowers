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
    
    var body: some View {
        ZStack {
            Color.flowerBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with settings and discovery count
                HStack {
                    // Discovery badge
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundColor(.flowerPrimary)
                        Text("\(flowerStore.totalDiscoveredCount)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.flowerTextPrimary)
                        Text("discovered")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.flowerPrimary.opacity(0.1))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // Main flower display
                flowerDisplay
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                // Error message if any
                if let errorMessage = flowerStore.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.flowerError)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                }
                
                // Action buttons
                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
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
            } else {
                // Loading state
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.flowerCardBackground)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.flowerPrimary)
                            Text("Creating your daily flower...")
                                .font(.system(size: 16))
                                .foregroundColor(.flowerTextSecondary)
                        }
                    )
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: flowerStore.currentFlower?.id)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Generate button
            Button(action: { showingGenerator = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Generate")
                }
            }
            .buttonStyle(FlowerButtonStyle())
            .disabled(flowerStore.isGenerating)
            
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
                    .background(Color.flowerButtonBackground)
                    .cornerRadius(12)
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
                    .background(Color.flowerButtonBackground)
                    .cornerRadius(12)
            }
            .disabled(flowerStore.currentFlower == nil)
            
            // Collection button (was favorites)
            Button(action: { showingFavorites = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.system(size: 22))
                        .foregroundColor(.flowerTextSecondary)
                        .frame(width: 56, height: 56)
                        .background(Color.flowerButtonBackground)
                        .cornerRadius(12)
                    
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

#Preview {
    ContentView()
}
