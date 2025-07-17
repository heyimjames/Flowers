import SwiftUI
import UniformTypeIdentifiers

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
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var notificationPermissionGranted = false
    @State private var showingFileImporter = false
    @State private var importedFlower: AIFlower?
    @State private var importedSenderInfo: FlowerOwner?
    @State private var showingImportConfirmation = false
    @State private var currentAppIcon: String = ""
    @State private var showingIconChangeAlert = false
    
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
                            HStack {
                                Label("API Configuration", systemImage: "key.fill")
                                    .font(.system(size: 18, weight: .light, design: .serif))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                Spacer()
                                
                                if AppConfig.shared.hasBuiltInKeys {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.green)
                                        Text("Built-in")
                                            .font(.system(size: 12))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                }
                            }
                            
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
                            
                            if AppConfig.shared.hasBuiltInKeys {
                                Text("✨ Built-in API keys are provided. Leave fields empty to use them, or enter your own keys to override.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerTextSecondary)
                                    .padding(.top, 8)
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
                            
                            Toggle(isOn: $notificationsEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Flower Notifications")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Get notified when your daily flower blooms")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextSecondary)
                                }
                            }
                            .tint(.flowerPrimary)
                            .onChange(of: notificationsEnabled) { _, newValue in
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    disableNotifications()
                                }
                            }
                            
                            if notificationsEnabled && !notificationPermissionGranted {
                                Button(action: openSettings) {
                                    HStack {
                                        Image(systemName: "gear")
                                            .font(.system(size: 14))
                                        Text("Open Settings to Enable Notifications")
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .foregroundColor(.flowerPrimary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(25)
                        
                        // Appearance Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Appearance", systemImage: "paintbrush.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("App Icon")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                HStack(spacing: 16) {
                                    // Primary App Icon
                                    Button(action: {
                                        changeAppIcon(to: nil, name: "Default")
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(currentAppIcon.isEmpty ? Color.flowerPrimary.opacity(0.2) : Color.flowerCardBackground)
                                                    .stroke(currentAppIcon.isEmpty ? Color.flowerPrimary : Color.clear, lineWidth: 2)
                                                    .frame(width: 64, height: 64)
                                                
                                                Image("Icon Flowers")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 48, height: 48)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            
                                            Text("Default")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.flowerTextPrimary)
                                        }
                                    }
                                    
                                    // Alternate App Icon
                                    Button(action: {
                                        changeAppIcon(to: "AppIcon2", name: "AppIcon2")
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(currentAppIcon == "AppIcon2" ? Color.flowerPrimary.opacity(0.2) : Color.flowerCardBackground)
                                                    .stroke(currentAppIcon == "AppIcon2" ? Color.flowerPrimary : Color.clear, lineWidth: 2)
                                                    .frame(width: 64, height: 64)
                                                
                                                // Use a placeholder since we can't directly reference AppIcon2 assets
                                                Image(systemName: "flower.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.flowerPrimary)
                                            }
                                            
                                            Text("Alternative")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.flowerTextPrimary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text("Choose your preferred app icon. Changes take effect immediately.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.flowerTextSecondary)
                                    .padding(.top, 4)
                            }
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
                                
                                Divider()
                                
                                // Regenerate Onboarding Assets
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Regenerate Onboarding Assets")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Force regenerate the static flower images used in onboarding")
                                        .font(.system(size: 12))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    Button(action: regenerateOnboardingAssets) {
                                        Text("Regenerate Assets")
                                    }
                                    .flowerButtonStyle()
                                }
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
        .alert("App Icon Changed", isPresented: $showingIconChangeAlert) {
            Button("OK") { }
        } message: {
            Text("Your app icon has been updated successfully!")
        }
        .onAppear {
            checkNotificationPermissionStatus()
            updateCurrentAppIcon()
            
            // Update iCloud sync stats when view appears
            Task {
                await iCloudSync.updateSyncStats()
                
                // Force a sync to ensure data is up to date
                if iCloudSync.iCloudAvailable {
                    await iCloudSync.syncToICloud()
                }
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [UTType(filenameExtension: "flower") ?? UTType.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importFlowerFile(from: url)
                }
            case .failure(let error):
                print("File import failed: \(error)")
            }
        }
        .sheet(isPresented: $showingImportConfirmation) {
            if let flower = importedFlower, let sender = importedSenderInfo {
                ReceivedFlowerSheet(
                    flower: flower,
                    sender: sender,
                    onAccept: {
                        flowerStore.addReceivedFlower(flower)
                        showingImportConfirmation = false
                        importedFlower = nil
                        importedSenderInfo = nil
                        dismiss()
                    },
                    onReject: {
                        showingImportConfirmation = false
                        importedFlower = nil
                        importedSenderInfo = nil
                    }
                )
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
                if granted {
                    // Schedule the next flower generation
                    Task {
                        if let nextTime = FlowerNotificationSchedule.getNextScheduledTime() {
                            await self.flowerStore.generateDailyFlowerAndScheduleNotification(at: nextTime)
                        }
                    }
                } else {
                    // If permission was denied, turn off the toggle
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    private func disableNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func checkNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
                // If notifications are enabled but permission was revoked, turn off the toggle
                if self.notificationsEnabled && !self.notificationPermissionGranted {
                    self.notificationsEnabled = false
                } else if self.notificationsEnabled && self.notificationPermissionGranted {
                    // Schedule notifications if both toggle is on and permission is granted
                    Task {
                        if let nextTime = FlowerNotificationSchedule.getNextScheduledTime() {
                            await self.flowerStore.generateDailyFlowerAndScheduleNotification(at: nextTime)
                        }
                    }
                }
            }
        }
    }
    
    private func scheduleDebugNotification() {
        flowerStore.scheduleDebugNotification(in: debugNotificationSeconds)
        dismiss()
    }
    
    private func regenerateOnboardingAssets() {
        Task {
            await OnboardingAssetsService.shared.regenerateAssets()
        }
    }
    
    private func performICloudRestore() async {
        // Set loading state
        await MainActor.run {
            isRestoringFromICloud = true
            restoreResult = nil
        }
        
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
    }
    
    private func importFlowerFile(from url: URL) {
        do {
            let (flower, senderInfo) = try FlowerTransferService.shared.importFlower(from: url)
            importedFlower = flower
            importedSenderInfo = senderInfo
            showingImportConfirmation = true
        } catch {
            print("Failed to import flower: \(error)")
            // TODO: Show error alert to user
        }
    }
    
    // MARK: - Helper Functions
    private func formattedSyncTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Yesterday at \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
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
                        Text("Last synced \(formattedSyncTime(lastSync))")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerTextSecondary)
                    } else {
                        Text("Not synced yet")
                            .font(.system(size: 12))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    
                    // Sync statistics
                    if iCloudSync.iCloudAvailable {
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
                                Animation.linear(duration: 0.8).repeatForever(autoreverses: false) :
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
                            .foregroundColor(.flowerPrimary)
                        Text("Restore from iCloud")
                            .foregroundColor(.flowerPrimary)
                    }
                }
                .flowerSecondaryButtonStyle()
                .disabled(iCloudSync.syncStatus == .syncing || isRestoringFromICloud)
                
                // Import from Files button
                Button(action: {
                    showingFileImporter = true
                }) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.flowerPrimary)
                        Text("Import from Files")
                            .foregroundColor(.flowerPrimary)
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
    
    // MARK: - App Icon Management
    private func updateCurrentAppIcon() {
        if let alternateIconName = UIApplication.shared.alternateIconName {
            currentAppIcon = alternateIconName
        } else {
            currentAppIcon = ""
        }
    }
    
    private func changeAppIcon(to iconName: String?, name: String) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Alternate icons are not supported on this device")
            return
        }
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to change app icon: \(error.localizedDescription)")
                } else {
                    self.currentAppIcon = iconName ?? ""
                    self.showingIconChangeAlert = true
                    
                    // Haptic feedback for successful icon change
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
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