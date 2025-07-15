import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var apiConfig = APIConfiguration.shared
    @ObservedObject var flowerStore = FlowerStore()
    @StateObject private var iCloudSync = iCloudSyncManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAPIKeyInfo = false
    @State private var showingDebugScheduler = false
    @State private var debugNotificationSeconds = 10
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.flowerTextPrimary)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.flowerPrimary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // API Configuration Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("API Configuration", systemImage: "key.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            // FAL API Key
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FAL API Key")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                SecureField("Enter FAL API key", text: $apiConfig.falKey)
                                    .textFieldStyle(FlowerTextFieldStyle())
                                    .onChange(of: apiConfig.falKey) { _ in
                                        apiConfig.saveConfiguration()
                                    }
                            }
                            
                            // OpenAI API Key
                            VStack(alignment: .leading, spacing: 8) {
                                Text("OpenAI API Key")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                SecureField("Enter OpenAI API key", text: $apiConfig.openAIKey)
                                    .textFieldStyle(FlowerTextFieldStyle())
                                    .onChange(of: apiConfig.openAIKey) { _ in
                                        apiConfig.saveConfiguration()
                                    }
                            }
                            
                            Button(action: { showingAPIKeyInfo = true }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("How to get API keys")
                                }
                                .font(.system(size: 14))
                                .foregroundColor(.flowerPrimary)
                            }
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(16)
                        
                        // iCloud Sync Section
                        iCloudSyncSection
                        
                        // Notifications Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Notifications", systemImage: "bell.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Button(action: requestNotificationPermission) {
                                HStack {
                                    Text("Enable Daily Flower Notifications")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.flowerTextTertiary)
                                }
                            }
                            .foregroundColor(.flowerTextPrimary)
                            
                            Text("Get notified when your daily flower blooms")
                                .font(.system(size: 12))
                                .foregroundColor(.flowerTextSecondary)
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(16)
                        
                        // Debug Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Debug Options", systemImage: "wrench.and.screwdriver.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            // Anytime Generations Toggle
                            Toggle(isOn: $flowerStore.debugAnytimeGenerations) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Anytime Generations")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                    Text("Show 'Find Flower' button always")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                            }
                            .tint(.flowerPrimary)
                            
                            Divider()
                            
                            // Debug Notification Scheduler
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Test Notification")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                HStack {
                                    Text("Schedule in \(debugNotificationSeconds) seconds")
                                        .font(.system(size: 14))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    Spacer()
                                    
                                    Stepper("", value: $debugNotificationSeconds, in: 5...60, step: 5)
                                        .labelsHidden()
                                }
                                
                                Button(action: scheduleDebugNotification) {
                                    Text("Schedule Test Notification")
                                }
                                .buttonStyle(FlowerPrimaryButtonStyle())
                            }
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(16)
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("About", systemImage: "info.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            HStack {
                                Text("Version")
                                    .foregroundColor(.flowerTextSecondary)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.flowerTextPrimary)
                            }
                            .font(.system(size: 14))
                            
                            HStack {
                                Text("Flowers Discovered")
                                    .foregroundColor(.flowerTextSecondary)
                                Spacer()
                                Text("\(flowerStore.totalDiscoveredCount)")
                                    .foregroundColor(.flowerTextPrimary)
                            }
                            .font(.system(size: 14))
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.flowerSheetBackground)
        }
        .alert("API Keys Required", isPresented: $showingAPIKeyInfo) {
            Button("OK") { }
        } message: {
            Text("To use AI features, you'll need API keys from:\n\n• FAL.ai for flower images\n• OpenAI for flower names and descriptions\n\nVisit their websites to sign up and get your API keys.")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    private func scheduleDebugNotification() {
        flowerStore.scheduleDebugNotification(in: debugNotificationSeconds)
        dismiss()
    }
    
    // MARK: - iCloud Sync Section
    private var iCloudSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("iCloud Sync")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.flowerTextPrimary)
            
            HStack {
                Image(systemName: "icloud")
                    .font(.system(size: 18))
                    .foregroundColor(iCloudSync.iCloudAvailable ? .flowerPrimary : .flowerTextTertiary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(iCloudSync.iCloudAvailable ? "iCloud Connected" : "iCloud Not Available")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.flowerTextPrimary)
                    
                    if let lastSync = iCloudSync.lastSyncDate {
                        Text("Last synced \(lastSync, style: .relative) ago")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerTextSecondary)
                    } else {
                        Text("Not synced yet")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerTextSecondary)
                    }
                }
                
                Spacer()
                
                if iCloudSync.syncStatus == .syncing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if case .error(let error) = iCloudSync.syncStatus {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.flowerError)
                }
            }
            
            if iCloudSync.iCloudAvailable {
                Button(action: {
                    Task {
                        await iCloudSync.syncToICloud()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Sync Now")
                    }
                }
                .buttonStyle(FlowerButtonStyle())
                .disabled(iCloudSync.syncStatus == .syncing)
                
                Text("Your flowers are automatically backed up to iCloud")
                    .font(.system(size: 12))
                    .foregroundColor(.flowerTextTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Sign in to iCloud in Settings to back up your flowers")
                    .font(.system(size: 12))
                    .foregroundColor(.flowerTextTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(Color.flowerCardBackground)
        .cornerRadius(16)
    }
}

struct FlowerTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.flowerInputBackground)
            .cornerRadius(8)
            .font(.system(size: 16))
    }
} 