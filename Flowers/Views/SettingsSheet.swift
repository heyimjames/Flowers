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
    @State private var showingBouquetImporter = false
    @State private var backupResult: BackupResult?
    @State private var bouquetRestoreResult: BouquetRestoreResult?
    @State private var isCreatingBackup = false
    @State private var isRestoringBouquet = false
    @State private var showingImportConfirmation = false
    @State private var currentAppIcon: String = ""
    @State private var showingCustomFlowerSheet = false
    @State private var showingWeatherTestSheet = false
    @State private var syncSuccessMessage: String?
    @State private var showingSyncSuccess = false
    @AppStorage("userName") private var userName = ""
    
    // Developer detection
    private var isDeveloper: Bool {
        // Check if this is James' device using device identifier
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let developerDeviceIDs = [
            "1CE7A12B-37D2-4BA5-B9D9-88AB3EAFB828", // James' device
            // Add more device UUIDs if needed
        ]
        
        // Also check for specific iCloud account (you can add this)
        // let iCloudAccount = FileManager.default.ubiquityIdentityToken != nil
        
        // Print device UUID for developer to add to the list
        print("Current device UUID: \(deviceID)")
        
        return developerDeviceIDs.contains(deviceID) || Bundle.main.bundleIdentifier?.contains("debug") == true
    }
    
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
    
    enum BackupResult: Identifiable {
        case success(flowersCount: Int, fileSize: String, filePath: String)
        case failure(error: String)
        
        var id: String {
            switch self {
            case .success: return "backup_success"
            case .failure: return "backup_failure"
            }
        }
    }
    
    enum BouquetRestoreResult: Identifiable {
        case success(flowersCount: Int, newFlowers: Int, updatedFlowers: Int)
        case failure(error: String)
        
        var id: String {
            switch self {
            case .success: return "bouquet_success"
            case .failure: return "bouquet_failure"
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
                        // API Configuration Section (only show if needed)
                        if !AppConfig.shared.hasBuiltInKeys || isDeveloper {
                            VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label("API Configuration", systemImage: "key.fill")
                                    .font(.system(size: 18, weight: .light, design: .serif))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                Spacer()
                                
                                if AppConfig.shared.hasBuiltInKeys {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.green)
                                        Text("Built-in")
                                            .font(.system(size: 12, design: .rounded))
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
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .padding(.top, 8)
                            }
                            
                            Button(action: { showingAPIKeyInfo = true }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("How to get API keys")
                                }
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.flowerPrimary)
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(25)
                        }
                        
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
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    Text("Automatically save new flowers to a 'Flowers' album in your photo library")
                                        .font(.system(size: 12, design: .rounded))
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
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(25)
                        
                        // Notifications Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Notifications", systemImage: "bell.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            Toggle(isOn: $notificationsEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Flower Notifications")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Get notified when your daily flower blooms")
                                        .font(.system(size: 12, design: .rounded))
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
                                            .font(.system(size: 14, design: .rounded))
                                        Text("Open Settings to Enable Notifications")
                                            .font(.system(size: 14, design: .rounded))
                                        Spacer()
                                    }
                                    .foregroundColor(.flowerPrimary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(25)
                        
                        // Appearance Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Appearance", systemImage: "paintbrush.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("App Icon")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                HStack(spacing: 16) {
                                    // Primary App Icon
                                    Button(action: {
                                        changeAppIcon(to: nil, name: "Default")
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(currentAppIcon.isEmpty ? Color.flowerPrimary.opacity(0.2) : Color.black.opacity(0.05))
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
                                                    .fill(currentAppIcon == "AppIcon2" ? Color.flowerPrimary.opacity(0.2) : Color.black.opacity(0.05))
                                                    .stroke(currentAppIcon == "AppIcon2" ? Color.flowerPrimary : Color.clear, lineWidth: 2)
                                                    .frame(width: 64, height: 64)
                                                
                                                // Try to load AppIcon2 preview image
                                                if let appIcon2Preview = UIImage(named: "AppIcon2Preview") {
                                                    Image(uiImage: appIcon2Preview)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 48, height: 48)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                } else {
                                                    // Fallback different design to distinguish from default
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.orange.opacity(0.8))
                                                            .frame(width: 48, height: 48)
                                                        
                                                        Image(systemName: "sparkles")
                                                            .font(.system(size: 20))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            }
                                            
                                            Text("Alternative")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.flowerTextPrimary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text("Choose your preferred app icon. Changes take effect immediately.")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(25)
                        
                        // Debug Section (developer only)
                        if isDeveloper {
                            VStack(alignment: .leading, spacing: 16) {
                            Label("Debug Options", systemImage: "wrench.and.screwdriver.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            // Debug Notification Scheduler
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Test Notification")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                HStack {
                                    Text("Schedule in \(debugNotificationSeconds) seconds")
                                        .font(.system(size: 14, design: .rounded))
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
                                Text("Test Flower Reveal")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                Text("Instantly show the Hold to Reveal flower screen for testing")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                Button(action: {
                                    flowerStore.triggerTestFlowerReveal()
                                }) {
                                    Text("Show Test Flower")
                                }
                                .flowerButtonStyle()
                                
                                Divider()
                                
                                // Restart Onboarding
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Restart Onboarding")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Reset onboarding state and start from the beginning")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    Button(action: restartOnboarding) {
                                        Text("Restart Onboarding")
                                    }
                                    .flowerButtonStyle()
                                }
                                
                                Divider()
                                
                                // Custom Flower Generation
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Custom Flower Generation")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Generate a custom flower with a specific prompt")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    Button(action: { showingCustomFlowerSheet = true }) {
                                        Text("Generate Custom Flower")
                                    }
                                    .flowerButtonStyle()
                                }
                                
                                Divider()
                                
                                // Weather Component Test
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Weather Component Test")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Test different weather component variations for the flower detail view")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    Button(action: { showingWeatherTestSheet = true }) {
                                        Text("Test Weather Components")
                                    }
                                    .flowerButtonStyle()
                                }
                                
                                Divider()
                                
                                // Regenerate Onboarding Assets
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Regenerate Onboarding Assets")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.flowerTextPrimary)
                                    
                                    Text("Force regenerate the static flower images used in onboarding")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    Button(action: regenerateOnboardingAssets) {
                                        Text("Regenerate Assets")
                                    }
                                    .flowerButtonStyle()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(25)
                        }
                        
                        // Profile Section
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Profile", systemImage: "person.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            // Username display
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                if !userName.isEmpty {
                                    HStack {
                                        Text(userName)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.flowerTextPrimary)
                                        
                                        Spacer()
                                        
                                        Button("Edit") {
                                            // Trigger onboarding to edit username
                                            flowerStore.shouldShowOnboarding = true
                                            dismiss()
                                        }
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.flowerPrimary)
                                    }
                                } else {
                                    Button("Set Username") {
                                        // Trigger onboarding to set username
                                        flowerStore.shouldShowOnboarding = true
                                        dismiss()
                                    }
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.flowerPrimary)
                                }
                            }
                            .padding(.bottom, 8)
                            
                            Divider()
                                .background(Color.flowerTextTertiary)
                            
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.flowerError)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Reset Profile")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.flowerError)
                                        Text("Start fresh with onboarding and lose all flowers")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.flowerTextSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.05))
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
                            .font(.system(size: 14, design: .rounded))
                            
                            HStack {
                                Text("Flowers Discovered")
                                    .foregroundColor(.flowerTextSecondary)
                                Spacer()
                                Text("\(flowerStore.totalDiscoveredCount)")
                                    .foregroundColor(.flowerTextPrimary)
                            }
                            .font(.system(size: 14, design: .rounded))
                            
                            Divider()
                                .background(Color.flowerTextTertiary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Built by James Frewin with the help of AI")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                Button(action: {
                                    if let url = URL(string: "https://x.com/jamesfrewin1") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "link")
                                            .font(.system(size: 12, design: .rounded))
                                        Text("@jamesfrewin1")
                                            .font(.system(size: 14, design: .rounded))
                                    }
                                    .foregroundColor(.flowerPrimary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.05))
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
        .alert("Merge from iCloud?", isPresented: $showingICloudRestoreConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Merge") {
                Task {
                    await performICloudRestore()
                }
            }
        } message: {
            Text("This will bring back any flowers you have stored in iCloud and add them to your collection. You won't lose any of your current flowers.")
        }
        .alert(item: $restoreResult) { result in
            switch result {
            case .success(let count):
                return Alert(
                    title: Text("Flowers Retrieved!"),
                    message: Text("Found \(count) flowers stored in your iCloud and added them to your collection. All your flowers are now up to date!"),
                    dismissButton: .default(Text("OK")) {
                        // Show success in the UI
                        syncSuccessMessage = "Successfully restored \(count) flowers from iCloud!"
                        showingSyncSuccess = true
                        // Clear the message after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            syncSuccessMessage = nil
                        }
                    }
                )
            case .failure(let error):
                return Alert(
                    title: Text("Couldn't Get Flowers"),
                    message: Text("We couldn't get your flowers from iCloud: \(error)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .alert(item: $backupResult) { result in
            switch result {
            case .success(let flowersCount, let fileSize, _):
                return Alert(
                    title: Text("Flowers Saved!"),
                    message: Text("Successfully saved all \(flowersCount) of your flowers (\(fileSize)). The file has been saved where you can share it or keep it extra safe."),
                    dismissButton: .default(Text("OK")) {
                        // Show success in the UI
                        syncSuccessMessage = "Backup created with \(flowersCount) flowers!"
                        // Clear the message after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            syncSuccessMessage = nil
                        }
                    }
                )
            case .failure(let error):
                return Alert(
                    title: Text("Couldn't Save Flowers"),
                    message: Text("We couldn't save your flowers: \(error)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .alert(item: $bouquetRestoreResult) { result in
            switch result {
            case .success(let flowersCount, let newFlowers, let updatedFlowers):
                return Alert(
                    title: Text("Flowers Restored!"),
                    message: Text("Successfully brought back \(flowersCount) flowers! Added \(newFlowers) new flowers and updated \(updatedFlowers) existing ones."),
                    dismissButton: .default(Text("OK")) {
                        // Show success in the UI
                        let message = newFlowers > 0 ? "Restored \(flowersCount) flowers (\(newFlowers) new)!" : "Collection restored successfully!"
                        syncSuccessMessage = message
                        // Clear the message after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            syncSuccessMessage = nil
                        }
                    }
                )
            case .failure(let error):
                return Alert(
                    title: Text("Couldn't Get Flowers Back"),
                    message: Text("We couldn't restore your flowers: \(error)"),
                    dismissButton: .default(Text("OK"))
                )
            }
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
        .fileImporter(
            isPresented: $showingBouquetImporter,
            allowedContentTypes: [UTType(filenameExtension: "bouquet") ?? UTType.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importBouquetFile(from: url)
                }
            case .failure(let error):
                print("Bouquet import failed: \(error)")
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
        .sheet(isPresented: $showingCustomFlowerSheet) {
            CustomFlowerGenerationSheet()
                .environmentObject(flowerStore)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showingWeatherTestSheet) {
            WeatherComponentTestSheet()
                .presentationDetents([.large])
                .presentationCornerRadius(32)
                .presentationDragIndicator(.visible)
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
    
    private func restartOnboarding() {
        flowerStore.resetOnboardingState()
        dismiss()
    }
    
    private func performSyncWithFeedback() async {
        await iCloudSync.performFullSync(flowerStore: flowerStore)
        
        // Show success feedback when sync completes successfully
        await MainActor.run {
            if case .success = iCloudSync.syncStatus {
                syncSuccessMessage = "Flowers saved to iCloud successfully!"
                // Clear the message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    syncSuccessMessage = nil
                }
            }
        }
    }
    
    private func performICloudRestore() async {
        // Set loading state
        await MainActor.run {
            isRestoringFromICloud = true
            restoreResult = nil
        }
        
        // Get iCloud flowers directly to report accurate count
        if let iCloudFlowers = await iCloudSync.restoreFromICloud() {
            print("Found \(iCloudFlowers.count) flowers in iCloud during restore")
            
            // Get the count of flowers before restore
            let flowersBeforeRestore = await MainActor.run { flowerStore.discoveredFlowers.count }
            
            // Perform the merge
            await iCloudSync.mergeWithICloudData(flowerStore: flowerStore)
            
            // Get the count after restore
            let flowersAfterRestore = await MainActor.run { flowerStore.discoveredFlowers.count }
            
            // Calculate how many were actually added
            let newFlowersAdded = flowersAfterRestore - flowersBeforeRestore
            
            await MainActor.run {
                isRestoringFromICloud = false
                // Report the number of flowers found in iCloud, not just new ones added
                restoreResult = .success(flowersCount: iCloudFlowers.count)
            }
            
            print("iCloud restore complete: \(iCloudFlowers.count) flowers found in iCloud, \(newFlowersAdded) new flowers added locally")
        } else {
            // No iCloud data found
            await MainActor.run {
                isRestoringFromICloud = false
                restoreResult = .failure(error: "No flowers found in your iCloud. Try using 'Save Now' first to store your current flowers, or check that you're signed into the same iCloud account where your flowers were saved.")
            }
            print("No iCloud data found during restore attempt")
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
    
    private func createCompleteBackup() {
        isCreatingBackup = true
        backupResult = nil
        
        Task {
            let serviceResult = await FlowerBackupService.shared.createQuickBackup(from: flowerStore)
            
            await MainActor.run {
                isCreatingBackup = false
                
                // Convert service result to local result type
                switch serviceResult {
                case .success(let flowersCount, let fileSize, let filePath):
                    backupResult = .success(flowersCount: flowersCount, fileSize: fileSize, filePath: filePath)
                    shareBackupFile(at: filePath)
                case .failure(let error):
                    backupResult = .failure(error: error)
                }
            }
        }
    }
    
    private func importBouquetFile(from url: URL) {
        isRestoringBouquet = true
        bouquetRestoreResult = nil
        
        Task {
            let serviceResult = await FlowerBackupService.shared.restoreFromBackup(fileURL: url, flowerStore: flowerStore)
            
            await MainActor.run {
                isRestoringBouquet = false
                
                // Convert service result to local result type
                switch serviceResult {
                case .success(let flowersCount, let newFlowers, let updatedFlowers):
                    bouquetRestoreResult = .success(flowersCount: flowersCount, newFlowers: newFlowers, updatedFlowers: updatedFlowers)
                case .failure(let error):
                    bouquetRestoreResult = .failure(error: error)
                }
            }
        }
    }
    
    private func shareBackupFile(at filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // Use UIDocumentInteractionController to share the backup
        let documentController = UIDocumentInteractionController(url: fileURL)
        documentController.delegate = FlowerBackupService.shared
        documentController.presentOptionsMenu(from: CGRect.zero, in: UIApplication.shared.windows.first?.rootViewController?.view ?? UIView(), animated: true)
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
            Text("Your Flower Backup")
                .font(.system(size: 16, weight: .light, design: .serif))
                .foregroundColor(.flowerTextPrimary)
            
            HStack {
                Image(systemName: "icloud")
                    .font(.system(size: 18))
                    .foregroundColor(iCloudSync.iCloudAvailable ? .flowerPrimary : .flowerTextTertiary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(iCloudSync.iCloudAvailable ? "Backup is On" : "Backup is Off")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.flowerTextPrimary)
                    
                    if let lastSync = iCloudSync.lastSyncDate {
                        Text("Last saved \(formattedSyncTime(lastSync))")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    } else {
                        Text("Not saved yet")
                            .font(.system(size: 12, design: .rounded))
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
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                            }
                            
                            Text("•")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.flowerTextTertiary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "internaldrive")
                                    .font(.system(size: 11))
                                    .foregroundColor(.flowerPrimary)
                                Text(iCloudSync.formattedDataSize)
                                    .font(.system(size: 12, design: .rounded))
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
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.flowerError)
                }
            }
            
            if iCloudSync.iCloudAvailable {
                VStack(spacing: 16) {
                    // Save Now button with description
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            Task {
                                await performSyncWithFeedback()
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
                                Text("Save Now")
                            }
                        }
                        .flowerButtonStyle()
                        .disabled(iCloudSync.syncStatus == .syncing || isRestoringFromICloud)
                        
                        Text("Safely stores all your flowers to your personal iCloud")
                            .font(.system(size: 11))
                            .foregroundColor(.flowerTextTertiary)
                            .padding(.leading, 8)
                    }
                    
                    // Get My Flowers button with description
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingICloudRestoreConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "icloud.and.arrow.down")
                                    .foregroundColor(.flowerPrimary)
                                Text("Get My Flowers")
                                    .foregroundColor(.flowerPrimary)
                            }
                        }
                        .flowerSecondaryButtonStyle()
                        .disabled(iCloudSync.syncStatus == .syncing || isRestoringFromICloud)
                        
                        Text("Brings back any flowers you have stored in iCloud")
                            .font(.system(size: 11))
                            .foregroundColor(.flowerTextTertiary)
                            .padding(.leading, 8)
                    }
                    
                    // Save All My Flowers button with description
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            createCompleteBackup()
                        }) {
                            HStack {
                                Image(systemName: "archivebox")
                                    .foregroundColor(.flowerPrimary)
                                Text("Save All My Flowers")
                                    .foregroundColor(.flowerPrimary)
                            }
                        }
                        .flowerSecondaryButtonStyle()
                        .disabled(isCreatingBackup || isRestoringBouquet)
                        
                        Text("Creates a file you can keep safe with every flower you've collected")
                            .font(.system(size: 11))
                            .foregroundColor(.flowerTextTertiary)
                            .padding(.leading, 8)
                    }
                    
                    // Get All My Flowers Back button with description
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingBouquetImporter = true
                        }) {
                            HStack {
                                Image(systemName: "archivebox.fill")
                                    .foregroundColor(.flowerPrimary)
                                Text("Get All My Flowers Back")
                                    .foregroundColor(.flowerPrimary)
                            }
                        }
                        .flowerSecondaryButtonStyle()
                        .disabled(isCreatingBackup || isRestoringBouquet)
                        
                        Text("Brings back your entire collection from a saved file")
                            .font(.system(size: 11))
                            .foregroundColor(.flowerTextTertiary)
                            .padding(.leading, 8)
                    }
                    
                    // Add a Friend's Flower button with description
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingFileImporter = true
                        }) {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                    .foregroundColor(.flowerPrimary)
                                Text("Add a Friend's Flower")
                                    .foregroundColor(.flowerPrimary)
                            }
                        }
                        .flowerSecondaryButtonStyle()
                        .disabled(iCloudSync.syncStatus == .syncing || isRestoringFromICloud)
                        
                        Text("Add flowers that friends have shared with you")
                            .font(.system(size: 11))
                            .foregroundColor(.flowerTextTertiary)
                            .padding(.leading, 8)
                    }
                }
                
                if isRestoringFromICloud {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Getting your flowers...")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.top, 8)
                }
                
                if isCreatingBackup {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Saving your flowers...")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.top, 8)
                }
                
                if isRestoringBouquet {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Getting your flowers back...")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.flowerTextSecondary)
                    }
                    .padding(.top, 8)
                }
                
                // Show success message if there is one
                if let successMessage = syncSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(successMessage)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 8)
                }
                
                Text("💡 Your flowers are safely saved to iCloud every day automatically")
                    .font(.system(size: 11))
                    .foregroundColor(.flowerTextTertiary)
                    .padding(.top, 16)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Sign in to iCloud in your device Settings to keep your flowers safe")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.flowerTextTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.05))
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
        
        print("Attempting to change app icon to: \(iconName ?? "nil (default)")")
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to change app icon to \(iconName ?? "default"): \(error.localizedDescription)")
                    print("Error details: \(error)")
                } else {
                    print("Successfully changed app icon to: \(iconName ?? "default")")
                    self.currentAppIcon = iconName ?? ""
                    
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
            .font(.system(size: 16, design: .rounded))
    }
}

struct CustomFlowerGenerationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var flowerStore: FlowerStore
    @State private var customPrompt = "A beautiful ethereal flower with luminous petals that seem to glow from within, featuring delicate crystalline structures and soft pastel colors that shift between lavender and rose gold"
    @State private var customName = ""
    @State private var isGenerating = false
    @State private var isGeneratingPrompt = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false
    @State private var customLocation = ""
    @State private var showingLocationPicker = false
    @State private var selectedLatitude: Double?
    @State private var selectedLongitude: Double?
    @State private var useCurrentLocation = true
    @State private var fetchingWeather = false
    @State private var weatherData: (condition: String, temperature: Double)?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Custom Flower")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .foregroundColor(.flowerTextPrimary)
                    
                    Spacer()
                    
                    Button("Cancel") {
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
                        // Main Flower Generation Container
                        VStack(alignment: .leading, spacing: 24) {
                            // Flower Description Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Flower Description")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                Text("Describe the flower you'd like to generate. Be as detailed as possible - include colors, textures, style, and any special characteristics.")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.flowerTextSecondary)
                                
                                // Text Editor
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Prompt")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.flowerTextSecondary)
                                        
                                        Spacer()
                                        
                                        Button(action: generatePrompt) {
                                            HStack(spacing: 4) {
                                                if isGeneratingPrompt {
                                                    ProgressView()
                                                        .scaleEffect(0.6)
                                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.flowerPrimary))
                                                } else {
                                                    Image(systemName: "sparkles")
                                                        .font(.system(size: 12, design: .rounded))
                                                }
                                                Text("Generate")
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.flowerPrimary.opacity(0.1))
                                            .foregroundColor(.flowerPrimary)
                                            .cornerRadius(12)
                                        }
                                        .disabled(isGeneratingPrompt)
                                    }
                                    
                                    ZStack(alignment: .topLeading) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.flowerInputBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.flowerTextTertiary.opacity(0.2), lineWidth: 1)
                                            )
                                        
                                        TextEditor(text: $customPrompt)
                                            .padding(12)
                                            .scrollContentBackground(.hidden)
                                            .background(Color.clear)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.flowerTextPrimary)
                                    }
                                    .frame(minHeight: 120)
                                }
                            }
                            
                            Divider()
                                .background(Color.flowerTextTertiary.opacity(0.3))
                            
                            // Flower Name Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Custom Name (Optional)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Give your flower a unique name")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.flowerTextSecondary)
                                    
                                    TextField("Enter flower name", text: $customName)
                                        .textFieldStyle(FlowerTextFieldStyle())
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.words)
                                }
                            }
                            
                            Divider()
                                .background(Color.flowerTextTertiary.opacity(0.3))
                            
                            // Location Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Discovery Location")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.flowerTextPrimary)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    // Use current location toggle
                                    Toggle(isOn: $useCurrentLocation) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "location.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.flowerPrimary)
                                            Text("Use my current location")
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(.flowerTextPrimary)
                                        }
                                    }
                                    .tint(.flowerPrimary)
                                    .onChange(of: useCurrentLocation) { _, newValue in
                                        if newValue {
                                            customLocation = ""
                                            selectedLatitude = nil
                                            selectedLongitude = nil
                                            weatherData = nil
                                        }
                                    }
                                    
                                    if !useCurrentLocation {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Custom location")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.flowerTextSecondary)
                                            
                                            HStack {
                                                TextField("Enter city or location", text: $customLocation)
                                                    .textFieldStyle(FlowerTextFieldStyle())
                                                    .disabled(showingLocationPicker)
                                                
                                                Button(action: { showingLocationPicker = true }) {
                                                    Image(systemName: "map")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.flowerPrimary)
                                                }
                                                .padding(12)
                                                .background(Color.flowerPrimary.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                            
                                            if !customLocation.isEmpty || (selectedLatitude != nil && selectedLongitude != nil) {
                                                Button(action: fetchWeatherForLocation) {
                                                    HStack(spacing: 6) {
                                                        if fetchingWeather {
                                                            ProgressView()
                                                                .scaleEffect(0.8)
                                                        } else {
                                                            Image(systemName: "cloud.sun")
                                                                .font(.system(size: 14))
                                                        }
                                                        Text("Get Current Weather")
                                                            .font(.system(size: 14, weight: .medium))
                                                    }
                                                    .foregroundColor(.flowerPrimary)
                                                }
                                                .disabled(fetchingWeather)
                                            }
                                            
                                            if let weather = weatherData {
                                                HStack(spacing: 12) {
                                                    Image(systemName: weatherIcon(for: weather.condition))
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.flowerPrimary)
                                                    Text("\(Int(weather.temperature))°C, \(weather.condition)")
                                                        .font(.system(size: 14, design: .rounded))
                                                        .foregroundColor(.flowerTextSecondary)
                                                }
                                                .padding(.top, 4)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Generate Button
                            Button(action: generateCustomFlower) {
                                HStack {
                                    if isGenerating {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Generating...")
                                    } else {
                                        Image(systemName: "sparkles")
                                        Text("Generate Custom Flower")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isGenerating ? Color.flowerPrimary.opacity(0.6) : Color.flowerPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            .disabled(isGenerating || customPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            // Error Message
                            if let error = errorMessage {
                                Text(error)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.flowerError)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(24)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        
                        // Tips Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tips for Better Results")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.flowerTextPrimary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                TipRow(
                                    icon: "paintbrush.fill",
                                    title: "Be Specific",
                                    description: "Include colors, textures, and artistic styles"
                                )
                                
                                TipRow(
                                    icon: "eye.fill",
                                    title: "Visual Details",
                                    description: "Describe petal shapes, stem characteristics, and overall composition"
                                )
                                
                                TipRow(
                                    icon: "sparkles",
                                    title: "Atmosphere",
                                    description: "Add mood descriptors like 'ethereal', 'vibrant', or 'delicate'"
                                )
                                
                                TipRow(
                                    icon: "camera.fill",
                                    title: "Photography Style",
                                    description: "Mention lighting conditions or photographic techniques"
                                )
                            }
                        }
                        .padding(24)
                        .background(Color.flowerCardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color.flowerSheetBackground)
        }
        .alert("Success!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your custom flower has been generated and added to your collection!")
        }
    }
    
    private func generateCustomFlower() {
        guard !customPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a flower description"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                // Prepare location and weather data
                var locationName: String?
                var latitude: Double?
                var longitude: Double?
                var weatherCondition: String?
                var temperature: Double?
                
                if useCurrentLocation {
                    // Use current location
                    locationName = await LocationManager.shared.getCurrentLocationName()
                    if let location = LocationManager.shared.currentLocation {
                        latitude = location.coordinate.latitude
                        longitude = location.coordinate.longitude
                    }
                } else if !customLocation.isEmpty {
                    // Use custom location
                    locationName = customLocation
                    latitude = selectedLatitude
                    longitude = selectedLongitude
                    if let weather = weatherData {
                        weatherCondition = weather.condition
                        temperature = weather.temperature
                    }
                }
                
                try await flowerStore.generateCustomFlower(
                    prompt: customPrompt,
                    name: customName,
                    location: locationName,
                    latitude: latitude,
                    longitude: longitude,
                    weatherCondition: weatherCondition,
                    temperature: temperature
                )
                
                await MainActor.run {
                    isGenerating = false
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = "Failed to generate flower: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func fetchWeatherForLocation() {
        // This is a placeholder - you would implement actual weather API call here
        fetchingWeather = true
        
        // Simulate weather fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fetchingWeather = false
            // Mock weather data - replace with actual API call
            weatherData = (condition: "Sunny", temperature: 22.0)
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "sunny", "clear":
            return "sun.max.fill"
        case "cloudy":
            return "cloud.fill"
        case "rainy", "rain":
            return "cloud.rain.fill"
        case "snowy", "snow":
            return "cloud.snow.fill"
        default:
            return "cloud.sun.fill"
        }
    }
    
    private func generatePrompt() {
        isGeneratingPrompt = true
        errorMessage = nil
        
        Task {
            do {
                let generatedPrompt = try await OpenAIService.shared.generateFlowerPrompt()
                await MainActor.run {
                    customPrompt = generatedPrompt
                    isGeneratingPrompt = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingPrompt = false
                    errorMessage = "Failed to generate prompt: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.flowerPrimary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.flowerTextPrimary)
                
                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.flowerTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
} 