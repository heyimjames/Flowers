import SwiftUI

struct SettingsSheet: View {
    @StateObject private var apiConfig = APIConfiguration.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .foregroundColor(.flowerTextPrimary)
                        .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                    
                    Button("Done") {
                        apiConfig.saveConfiguration()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.flowerPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // API Provider Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Image Generation Provider")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                ForEach(APIProvider.allCases, id: \.self) { provider in
                                    Button {
                                        apiConfig.selectedProvider = provider
                                    } label: {
                                        HStack {
                                            Text(provider.rawValue)
                                                .font(.system(size: 16))
                                                .foregroundColor(.flowerTextPrimary)
                                            
                                            Spacer()
                                            
                                            if apiConfig.selectedProvider == provider {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.flowerPrimary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .background(Color.flowerCardBackground)
                                    }
                                    
                                    if provider != APIProvider.allCases.last {
                                        Divider()
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                            .background(Color.flowerCardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.flowerDivider, lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // API Key Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("API Key")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.flowerTextSecondary)
                                .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // OpenAI Key
                                if apiConfig.selectedProvider == .openAI {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("OpenAI API Key")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        SecureField("sk-...", text: $apiConfig.openAIKey)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 16))
                                            .padding(12)
                                            .background(Color.flowerInputBackground)
                                            .cornerRadius(8)
                                            .foregroundColor(.flowerTextPrimary)
                                        
                                        Link("Get your API key from OpenAI", destination: URL(string: "https://platform.openai.com/api-keys")!)
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerPrimary)
                                    }
                                }
                                
                                // FAL Key
                                if apiConfig.selectedProvider == .fal {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("FAL API Key")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        SecureField("Enter your FAL API key", text: $apiConfig.falKey)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 16))
                                            .padding(12)
                                            .background(Color.flowerInputBackground)
                                            .cornerRadius(8)
                                            .foregroundColor(.flowerTextPrimary)
                                        
                                        Link("Get your API key from FAL", destination: URL(string: "https://fal.ai/dashboard/keys")!)
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerPrimary)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.flowerCardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.flowerDivider, lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Info Box
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Your API keys are stored locally", systemImage: "lock.shield")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Text("API keys are never shared and are only used to generate flower images.")
                                .font(.system(size: 12))
                                .foregroundColor(.flowerTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.flowerPrimary.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button {
                            apiConfig.saveConfiguration()
                            showingSaveConfirmation = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        } label: {
                            Text("Save Settings")
                        }
                        .buttonStyle(FlowerButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .disabled(!apiConfig.hasValidAPIKey)
                        .opacity(apiConfig.hasValidAPIKey ? 1.0 : 0.5)
                    }
                    .padding(.vertical, 20)
                }
                .background(Color.flowerBackground)
            }
            .navigationBarHidden(true)
        }
        .overlay(
            // Save confirmation toast
            VStack {
                if showingSaveConfirmation {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Settings Saved")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.flowerSuccess)
                    .cornerRadius(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: showingSaveConfirmation)
                }
                Spacer()
            }
            .padding(.top, 50)
        )
    }
} 