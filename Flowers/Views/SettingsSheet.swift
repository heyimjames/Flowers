import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var apiConfig = APIConfiguration.shared
    @EnvironmentObject var flowerStore: FlowerStore
    @StateObject private var iCloudSync = iCloudSyncManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAPIKeyInfo = false
    @State private var showingDebugScheduler = false
    @State private var debugNotificationSeconds = 10
    @State private var showingResetConfirmation = false
    @State private var showingICloudRestoreConfirmation = false
    @State private var isRestoringFromICloud = false
    @State private var restoreResult: RestoreResult?
    
    enum RestoreResult: Identifiable {
        case success(flowersCount: Int)
        case failure(error: String)
        
        var id: String {
            switch self {
            case .success: return "success"
            case .failure: return "failure"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 28, weight: .light, design: .serif))
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
                            .font(.system(size: 18, weight: .light, design: .serif))
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
                        .cornerRadius(25)
                        
                        // iCloud Sync Section
                        iCloudSyncSection
                        
                        // Photos Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Photos", systemImage: "photo.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Toggle(isOn: $flowerStore.autoSaveToPhotos) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Auto-Save to Photos")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                    Text("Automatically save new flowers to a 'Flowers' album in your photo library")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .tint(.flowerPrimary)
                            
                            Text("Saved flowers include location, date, and flower details as metadata")
                                .font(.system(size: 11))
                                .foregroundColor(.flowerTextTertiary)
                                .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(25)
                        
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
                        .cornerRadius(25)
                        
                        // Debug Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Debug Options", systemImage: "wrench.and.screwdriver.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
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
                                .flowerButtonStyle()
                            }
                            
                            Divider()
                            
                            // Test Flower Reveal
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $flowerStore.showTestFlowerOnNextLaunch) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Test Flower on Next Launch")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.flowerTextPrimary)
                                        Text("Show the flower reveal screen when you next open the app")
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                }
                                .tint(.flowerPrimary)
                            }
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(25)
                        
                        // Profile Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Profile", systemImage: "person.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.flowerError)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Reset Profile")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.flowerError)
                                        Text("Start fresh with onboarding and lose all flowers")
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(25)
                        
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
                        .cornerRadius(25)
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
        .alert("Reset Profile", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                flowerStore.resetProfile()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to reset your profile? This will delete all your discovered flowers and return you to the onboarding flow.")
        }
        .alert("Restore from iCloud?", isPresented: $showingICloudRestoreConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Restore") {
                Task {
                    await performICloudRestore()
                }
            }
        } message: {
            Text("This will merge your iCloud backup with your current collection. Any flowers in your iCloud backup that aren't in your current collection will be added.")
        }
        .alert(item: $restoreResult) { result in
            switch result {
            case .success(let count):
                return Alert(
                    title: Text("Restore Complete"),
                    message: Text("Successfully restored \(count) flowers from iCloud."),
                    dismissButton: .default(Text("OK"))
                )
            case .failure(let error):
                return Alert(
                    title: Text("Restore Failed"),
                    message: Text("Could not restore from iCloud: \(error)"),
                    dismissButton: .default(Text("OK"))
                )
            }
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
    
    private func performICloudRestore() async {
        // Set loading state
        await MainActor.run {
            isRestoringFromICloud = true
            restoreResult = nil
        }
        
        do {
            // Get the count of flowers before restore
            let flowersBeforeRestore = await MainActor.run { flowerStore.discoveredFlowers.count }
            
            // Perform the restore
            await iCloudSync.mergeWithICloudData(flowerStore: flowerStore)
            
            // Get the count after restore
            let flowersAfterRestore = await MainActor.run { flowerStore.discoveredFlowers.count }
            
            // Calculate how many were restored
            let restoredCount = flowersAfterRestore - flowersBeforeRestore
            
            await MainActor.run {
                isRestoringFromICloud = false
                restoreResult = .success(flowersCount: max(0, restoredCount))
            }
        } catch {
            await MainActor.run {
                isRestoringFromICloud = false
                restoreResult = .failure(error: error.localizedDescription)
            }
        }
    }
    
    // MARK: - iCloud Sync Section
    private var iCloudSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("iCloud Sync")
                .font(.system(size: 16, weight: .light, design: .serif))
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
                    
                    // Sync statistics
                    if iCloudSync.syncedFlowersCount > 0 {
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "flower")
                                    .font(.system(size: 11))
                                    .foregroundColor(.flowerPrimary)
                                Text("\(iCloudSync.syncedFlowersCount) flowers")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                            
                            Text("•")
                                .font(.system(size: 12))
                                .foregroundColor(.flowerTextTertiary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "internaldrive")
                                    .font(.system(size: 11))
                                    .foregroundColor(.flowerPrimary)
                                Text(iCloudSync.formattedDataSize)
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                        }
                        .padding(.top, 2)
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
                            .rotationEffect(iCloudSync.syncStatus == .syncing ? .degrees(360) : .degrees(0))
                            .animation(
                                iCloudSync.syncStatus == .syncing ?
                                Animation.linear(duration: 1.0).repeatForever(autoreverses: false) :
                                .default,
                                value: iCloudSync.syncStatus
                            )
                        Text("Sync Now")
                    }
                }
                .flowerButtonStyle()
                .disabled(iCloudSync.syncStatus == .syncing || isRestoringFromICloud)
                
                // Restore from iCloud button
                Button(action: {
                    showingICloudRestoreConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Restore from iCloud")
                    }
                }
                .flowerSecondaryButtonStyle()
                .disabled(iCloudSync.syncStatus == .syncing || isRestoringFromICloud)
                
                if isRestoringFromICloud {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Restoring...")
                            .font(.system(size: 14))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.top, 8)
                }
                
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