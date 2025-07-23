import Foundation
import SwiftUI

class iCloudSyncManager: ObservableObject {
    static let shared = iCloudSyncManager()
    
    @Published var iCloudAvailable = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var syncedFlowersCount: Int = 0
    @Published var syncedDataSize: Int64 = 0 // in bytes
    
    private let iCloudContainerURL: URL?
    private let flowersFileName = "flowers_collection.json"
    private let metadataFileName = "sync_metadata.json"
    private var metadataQuery: NSMetadataQuery?
    private var syncTimer: Timer?
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    struct SyncMetadata: Codable {
        let lastModified: Date
        let deviceID: String
        let flowersCount: Int
    }
    
    init() {
        // Get iCloud container URL
        if let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.OCTOBER.Flowers") {
            self.iCloudContainerURL = containerURL.appendingPathComponent("Documents")
            self.iCloudAvailable = true
            
            // Create Documents directory if needed
            try? FileManager.default.createDirectory(at: self.iCloudContainerURL!, withIntermediateDirectories: true)
            
            setupMetadataQuery()
            startPeriodicSync()
            
            // Load initial sync stats
            Task {
                await updateSyncStats()
            }
        } else {
            self.iCloudContainerURL = nil
            self.iCloudAvailable = false
            print("iCloud is not available")
        }
        
        // Load last sync date
        if let lastSync = UserDefaults.standard.object(forKey: "lastICloudSync") as? Date {
            self.lastSyncDate = lastSync
        }
    }
    
    private func setupMetadataQuery() {
        metadataQuery = NSMetadataQuery()
        guard let query = metadataQuery else { return }
        
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K LIKE '*.json'", NSMetadataItemFSNameKey)
        
        // Listen for updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidUpdate),
            name: .NSMetadataQueryDidUpdate,
            object: query
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidFinishGathering),
            name: .NSMetadataQueryDidFinishGathering,
            object: query
        )
        
        query.start()
    }
    
    @objc private func queryDidUpdate(_ notification: Notification) {
        processQueryResults()
    }
    
    @objc private func queryDidFinishGathering(_ notification: Notification) {
        processQueryResults()
    }
    
    private func processQueryResults() {
        guard let query = metadataQuery else { return }
        
        query.disableUpdates()
        defer { query.enableUpdates() }
        
        // Check if remote data is newer
        for item in query.results {
            guard let metadataItem = item as? NSMetadataItem,
                  let fileName = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String,
                  fileName == flowersFileName else { continue }
            
            // Check if download is needed
            if let isDownloaded = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String,
               isDownloaded != NSMetadataUbiquitousItemDownloadingStatusDownloaded {
                // Start download
                if let url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL {
                    try? FileManager.default.startDownloadingUbiquitousItem(at: url)
                }
            }
        }
    }
    
    // MARK: - Sync Statistics
    
    func updateSyncStats() async {
        guard let containerURL = iCloudContainerURL else { 
            print("iCloudSyncManager: No container URL available")
            return 
        }
        
        let flowersURL = containerURL.appendingPathComponent(flowersFileName)
        print("iCloudSyncManager: Checking sync stats at: \(flowersURL.path)")
        
        do {
            // Check if file exists
            if FileManager.default.fileExists(atPath: flowersURL.path) {
                // Get file size
                let attributes = try FileManager.default.attributesOfItem(atPath: flowersURL.path)
                let fileSize = attributes[.size] as? Int64 ?? 0
                
                // Read and count flowers
                let data = try Data(contentsOf: flowersURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let flowers = try decoder.decode([AIFlower].self, from: data)
                
                await MainActor.run {
                    self.syncedDataSize = fileSize
                    self.syncedFlowersCount = flowers.count
                    print("iCloudSyncManager: Updated stats - \(flowers.count) flowers, \(fileSize) bytes")
                }
            } else {
                await MainActor.run {
                    self.syncedDataSize = 0
                    self.syncedFlowersCount = 0
                }
            }
        } catch {
            print("Error updating sync stats: \(error)")
            await MainActor.run {
                self.syncedDataSize = 0
                self.syncedFlowersCount = 0
            }
        }
    }
    
    var formattedDataSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: syncedDataSize)
    }
    
    // MARK: - Automatic Sync
    
    func startPeriodicSync() {
        // Sync every 5 minutes when app is active
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                await self.syncToICloud()
            }
        }
    }
    
    // MARK: - Public Methods
    
    func syncToICloud() async {
        guard iCloudAvailable, let containerURL = iCloudContainerURL else {
            print("iCloud not available, skipping sync")
            return
        }
        
        await MainActor.run {
            self.syncStatus = .syncing
        }
        
        // Ensure minimum sync duration for better UX (3+ rotations at 0.8s each)
        let startTime = Date()
        let minimumSyncDuration: TimeInterval = 2.5
        
        do {
            // First, get existing iCloud flowers
            let existingICloudFlowers = await restoreFromICloud() ?? []
            print("Found \(existingICloudFlowers.count) existing flowers in iCloud")
            
            // Get current local flowers from UserDefaults
            let localFlowers = await MainActor.run { () -> [AIFlower] in
                let userDefaults = UserDefaults.standard
                if let data = userDefaults.data(forKey: "discoveredFlowers") {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let decoded = try? decoder.decode([AIFlower].self, from: data) {
                        print("iCloudSyncManager: Found \(decoded.count) local flowers to sync")
                        return decoded
                    }
                }
                print("iCloudSyncManager: No flowers found in UserDefaults")
                return []
            }
            
            // Merge flowers - combine both sets, keeping newer versions
            var mergedFlowersDict = Dictionary(uniqueKeysWithValues: localFlowers.map { ($0.id, $0) })
            
            // Add iCloud flowers that don't exist locally or are newer
            for iCloudFlower in existingICloudFlowers {
                if let existingFlower = mergedFlowersDict[iCloudFlower.id] {
                    // Keep the newer version
                    if iCloudFlower.generatedDate > existingFlower.generatedDate {
                        mergedFlowersDict[iCloudFlower.id] = iCloudFlower
                    }
                } else {
                    // Add flower that only exists in iCloud
                    mergedFlowersDict[iCloudFlower.id] = iCloudFlower
                }
            }
            
            let flowers = Array(mergedFlowersDict.values).sorted {
                ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate)
            }
            
            print("Merged collection has \(flowers.count) flowers (was \(localFlowers.count) local + \(existingICloudFlowers.count) iCloud)")
            
            // Prepare data
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let flowersData = try encoder.encode(flowers)
            
            // Create metadata
            let metadata = SyncMetadata(
                lastModified: Date(),
                deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
                flowersCount: flowers.count
            )
            let metadataData = try encoder.encode(metadata)
            
            // Save to iCloud
            let flowersURL = containerURL.appendingPathComponent(flowersFileName)
            let metadataURL = containerURL.appendingPathComponent(metadataFileName)
            
            // Use coordinated write for safety
            var coordinatorError: NSError?
            var writeError: Error?
            
            NSFileCoordinator(filePresenter: nil).coordinate(
                writingItemAt: flowersURL,
                options: .forReplacing,
                error: &coordinatorError
            ) { writingURL in
                do {
                    try flowersData.write(to: writingURL)
                    try metadataData.write(to: metadataURL)
                } catch {
                    writeError = error
                }
            }
            
            if let error = coordinatorError ?? writeError {
                throw error
            }
            
            // Ensure minimum sync duration has passed
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < minimumSyncDuration {
                try await Task.sleep(nanoseconds: UInt64((minimumSyncDuration - elapsed) * 1_000_000_000))
            }
            
            // Update sync status
            await MainActor.run {
                self.syncStatus = .success
                self.lastSyncDate = Date()
                UserDefaults.standard.set(self.lastSyncDate, forKey: "lastICloudSync")
            }
            
            // Update sync statistics
            await updateSyncStats()
            
            print("Successfully synced \(flowers.count) flowers to iCloud at: \(flowersURL.path)")
            
        } catch {
            await MainActor.run {
                self.syncStatus = .error(error.localizedDescription)
            }
            print("Failed to sync to iCloud: \(error)")
        }
    }
    
    func restoreFromICloud() async -> [AIFlower]? {
        guard iCloudAvailable, let containerURL = iCloudContainerURL else {
            print("iCloud not available for restore - iCloudAvailable: \(iCloudAvailable), containerURL: \(iCloudContainerURL?.path ?? "nil")")
            return nil
        }
        
        print("Starting iCloud restore - container available at: \(containerURL.path)")
        
        do {
            let flowersURL = containerURL.appendingPathComponent(flowersFileName)
            print("Looking for iCloud file at: \(flowersURL.path)")
            
            // Check iCloud status first
            var resourceValues: URLResourceValues?
            do {
                resourceValues = try flowersURL.resourceValues(forKeys: [
                    .ubiquitousItemDownloadingStatusKey,
                    .ubiquitousItemHasUnresolvedConflictsKey
                ])
                
                if let downloadStatus = resourceValues?.ubiquitousItemDownloadingStatus {
                    print("iCloud download status: \(downloadStatus.rawValue)")
                }
                // Use ubiquitousItemDownloadingStatus instead of deprecated ubiquitousItemIsDownloaded
                let isDownloaded = (resourceValues?.ubiquitousItemDownloadingStatus == .current)
                print("iCloud file is downloaded: \(isDownloaded)")
            } catch {
                print("Error checking iCloud resource values: \(error)")
            }
            
            // Try to download the file first if it's not local
            do {
                print("Attempting to download iCloud file if needed...")
                try FileManager.default.startDownloadingUbiquitousItem(at: flowersURL)
                
                // Wait longer for download to complete
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                print("Download request completed, waiting for file availability")
            } catch {
                print("Error requesting iCloud file download: \(error)")
            }
            
            // Check if file exists
            var isDownloaded = false
            var coordinatorError: NSError?
            
            NSFileCoordinator(filePresenter: nil).coordinate(
                readingItemAt: flowersURL,
                options: .withoutChanges,
                error: &coordinatorError
            ) { readingURL in
                isDownloaded = FileManager.default.fileExists(atPath: readingURL.path)
                if isDownloaded {
                    print("iCloud file exists at: \(readingURL.path)")
                } else {
                    print("iCloud file not found at: \(readingURL.path)")
                }
            }
            
            if !isDownloaded {
                print("No iCloud backup found after download attempt")
                
                // Debug: List all files in the iCloud directory
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: [.ubiquitousItemDownloadingStatusKey], options: [])
                    print("Contents of iCloud directory (\(contents.count) items):")
                    for url in contents {
                        let fileName = url.lastPathComponent
                        var status = "unknown"
                        if let resourceValues = try? url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]),
                           let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus {
                            status = downloadStatus.rawValue
                        }
                        print("  - \(fileName) (status: \(status))")
                    }
                } catch {
                    print("Error listing iCloud directory contents: \(error)")
                }
                
                return nil
            }
            
            // Read the file
            var flowersData: Data?
            NSFileCoordinator(filePresenter: nil).coordinate(
                readingItemAt: flowersURL,
                options: .withoutChanges,
                error: &coordinatorError
            ) { readingURL in
                do {
                    flowersData = try Data(contentsOf: readingURL)
                    print("Successfully read \(flowersData?.count ?? 0) bytes from iCloud")
                } catch {
                    print("Error reading iCloud file: \(error)")
                }
            }
            
            guard let data = flowersData else {
                print("Failed to read iCloud data")
                return nil
            }
            
            // Decode flowers
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let flowers = try decoder.decode([AIFlower].self, from: data)
            
            print("Successfully restored \(flowers.count) flowers from iCloud")
            return flowers
            
        } catch {
            print("Failed to restore from iCloud: \(error)")
            return nil
        }
    }
    
    func mergeWithICloudData(flowerStore: FlowerStore) async {
        print("Starting iCloud merge process...")
        
        guard let iCloudFlowers = await restoreFromICloud() else {
            print("No iCloud data found, syncing current local data to iCloud")
            await syncToICloud()
            return
        }
        
        print("Found \(iCloudFlowers.count) flowers in iCloud backup")
        
        await MainActor.run {
            let localFlowers = flowerStore.discoveredFlowers
            print("Found \(localFlowers.count) local flowers")
            
            // Create a dictionary for quick lookup
            var mergedFlowersDict = Dictionary(uniqueKeysWithValues: localFlowers.map { ($0.id, $0) })
            print("Created lookup dictionary with \(mergedFlowersDict.count) local flowers")
            
            var addedFromiCloud = 0
            var updatedFromiCloud = 0
            
            // Merge iCloud flowers (newer dates win)
            for iCloudFlower in iCloudFlowers {
                if let existingFlower = mergedFlowersDict[iCloudFlower.id] {
                    // Compare dates and keep the newer one
                    let existingDate = existingFlower.generatedDate
                    let iCloudDate = iCloudFlower.generatedDate
                    
                    if iCloudDate > existingDate {
                        mergedFlowersDict[iCloudFlower.id] = iCloudFlower
                        updatedFromiCloud += 1
                        print("Updated flower '\(iCloudFlower.name)' from iCloud (newer date)")
                    } else {
                        print("Kept local flower '\(existingFlower.name)' (newer or same date)")
                    }
                } else {
                    // New flower from iCloud
                    mergedFlowersDict[iCloudFlower.id] = iCloudFlower
                    addedFromiCloud += 1
                    print("Added new flower '\(iCloudFlower.name)' from iCloud")
                }
            }
            
            // Update FlowerStore with merged data
            let mergedFlowers = Array(mergedFlowersDict.values).sorted {
                ($0.discoveryDate ?? $0.generatedDate) > ($1.discoveryDate ?? $1.generatedDate)
            }
            
            print("Merge complete: \(mergedFlowers.count) total flowers (\(addedFromiCloud) added, \(updatedFromiCloud) updated from iCloud)")
            
            flowerStore.discoveredFlowers = mergedFlowers
            
            // Update favorites
            flowerStore.favorites = mergedFlowers.filter { $0.isFavorite }
            
            // Save to local storage
            flowerStore.saveFlowers()
            
            print("Saved merged collection to local storage")
        }
        
        // Don't sync back immediately - the merged data was already saved locally
        // The next regular sync will upload the merged collection
        print("Merge complete. Merged data saved locally.")
    }
    
    /// Performs a full sync - merges iCloud data with local and then syncs back
    func performFullSync(flowerStore: FlowerStore) async {
        // First merge with iCloud data
        await mergeWithICloudData(flowerStore: flowerStore)
        
        // Then sync the merged data back to iCloud
        await syncToICloud()
    }
    
    func deleteICloudData() async {
        guard iCloudAvailable, let containerURL = iCloudContainerURL else { return }
        
        do {
            let flowersURL = containerURL.appendingPathComponent(flowersFileName)
            let metadataURL = containerURL.appendingPathComponent(metadataFileName)
            
            var coordinatorError: NSError?
            NSFileCoordinator(filePresenter: nil).coordinate(
                writingItemAt: flowersURL,
                options: .forDeleting,
                error: &coordinatorError
            ) { writingURL in
                try? FileManager.default.removeItem(at: writingURL)
                try? FileManager.default.removeItem(at: metadataURL)
            }
            
            await MainActor.run {
                self.lastSyncDate = nil
                UserDefaults.standard.removeObject(forKey: "lastICloudSync")
            }
            
            print("Deleted iCloud data")
        }
    }
    
    deinit {
        syncTimer?.invalidate()
        metadataQuery?.stop()
    }
} 