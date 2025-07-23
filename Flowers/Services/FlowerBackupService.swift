import Foundation
import UIKit
import UniformTypeIdentifiers

// MARK: - Bouquet Document Type
extension UTType {
    static let bouquetDocument = UTType(exportedAs: "com.october.flowers.bouquet")
}

// MARK: - Bouquet Document Structure
struct BouquetDocument: Codable {
    let flowers: [AIFlower]
    let metadata: BouquetMetadata
    let version: Int = 1
    
    struct BouquetMetadata: Codable {
        let exportDate: Date
        let deviceID: String
        let deviceName: String
        let appVersion: String
        let totalFlowers: Int
        let exporterName: String?
        let exporterLocation: String?
        let checksum: String // For integrity verification
        
        init(totalFlowers: Int, exporterName: String? = nil, exporterLocation: String? = nil, flowers: [AIFlower]) {
            self.exportDate = Date()
            self.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            self.deviceName = UIDevice.current.name
            self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            self.totalFlowers = totalFlowers
            self.exporterName = exporterName
            self.exporterLocation = exporterLocation
            
            // Create a checksum for integrity verification
            let flowerIDs = flowers.map { $0.id.uuidString }.sorted().joined()
            self.checksum = String(flowerIDs.hashValue)
        }
    }
}

// MARK: - Backup Result Types
enum BackupResult {
    case success(flowersCount: Int, fileSize: String, filePath: String)
    case failure(String)
}

enum RestoreResult {
    case success(flowersCount: Int, newFlowers: Int, updatedFlowers: Int)
    case failure(String)
}

// MARK: - Flower Backup Service
class FlowerBackupService: NSObject {
    static let shared = FlowerBackupService()
    
    // MARK: - Error Types
    enum BackupError: Error, LocalizedError {
        case noFlowersToBackup
        case encodingError(String)
        case decodingError(String)
        case fileSystemError(String)
        case corruptedBackup(String)
        case incompatibleVersion(Int)
        
        var errorDescription: String? {
            switch self {
            case .noFlowersToBackup:
                return "No flowers found to backup"
            case .encodingError(let details):
                return "Failed to create backup file: \(details)"
            case .decodingError(let details):
                return "Failed to read backup file: \(details)"
            case .fileSystemError(let details):
                return "File system error: \(details)"
            case .corruptedBackup(let details):
                return "Backup file is corrupted: \(details)"
            case .incompatibleVersion(let version):
                return "Backup file version \(version) is not supported by this app version"
            }
        }
    }
    
    // MARK: - Export Complete Collection (.bouquet file)
    func exportCompleteCollection(
        flowers: [AIFlower], 
        exporterName: String? = nil, 
        exporterLocation: String? = nil
    ) async throws -> URL {
        
        guard !flowers.isEmpty else {
            throw BackupError.noFlowersToBackup
        }
        
        print("🌻 Starting complete collection export for \(flowers.count) flowers")
        
        // Create bouquet metadata
        let metadata = BouquetDocument.BouquetMetadata(
            totalFlowers: flowers.count,
            exporterName: exporterName,
            exporterLocation: exporterLocation,
            flowers: flowers
        )
        
        // Create bouquet document
        let bouquet = BouquetDocument(
            flowers: flowers,
            metadata: metadata
        )
        
        // Encode with pretty printing for readability
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(bouquet)
            
            // Create filename with timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
            let timestamp = dateFormatter.string(from: Date())
            
            let fileName = "FlowerCollection_\(timestamp).bouquet"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            // Write to file
            try data.write(to: fileURL)
            
            let fileSize = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
            print("🌻 Successfully exported \(flowers.count) flowers to \(fileName) (\(fileSize))")
            
            return fileURL
            
        } catch {
            throw BackupError.encodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Import Complete Collection (.bouquet file)
    func importCompleteCollection(from url: URL) async throws -> (flowers: [AIFlower], metadata: BouquetDocument.BouquetMetadata) {
        
        print("🌻 Starting collection import from: \(url.lastPathComponent)")
        
        // Read file data
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BackupError.fileSystemError("Could not read backup file: \(error.localizedDescription)")
        }
        
        // Decode bouquet document
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let bouquet: BouquetDocument
        do {
            bouquet = try decoder.decode(BouquetDocument.self, from: data)
        } catch {
            throw BackupError.decodingError("Invalid backup file format: \(error.localizedDescription)")
        }
        
        // Verify version compatibility
        guard bouquet.version <= 1 else {
            throw BackupError.incompatibleVersion(bouquet.version)
        }
        
        // Verify data integrity
        let flowerIDs = bouquet.flowers.map { $0.id.uuidString }.sorted().joined()
        let computedChecksum = String(flowerIDs.hashValue)
        
        guard computedChecksum == bouquet.metadata.checksum else {
            throw BackupError.corruptedBackup("Checksum mismatch - backup file may be corrupted")
        }
        
        // Verify flower count matches
        guard bouquet.flowers.count == bouquet.metadata.totalFlowers else {
            throw BackupError.corruptedBackup("Flower count mismatch: expected \(bouquet.metadata.totalFlowers), found \(bouquet.flowers.count)")
        }
        
        print("🌻 Successfully verified and imported \(bouquet.flowers.count) flowers from backup")
        print("🌻 Backup created on \(bouquet.metadata.exportDate) from device: \(bouquet.metadata.deviceName)")
        
        return (bouquet.flowers, bouquet.metadata)
    }
    
    // MARK: - Merge Collection with Existing Flowers
    func mergeCollectionWithExisting(
        importedFlowers: [AIFlower],
        existingFlowers: [AIFlower]
    ) -> (merged: [AIFlower], stats: MergeStats) {
        
        print("🌻 Starting merge process: \(importedFlowers.count) imported + \(existingFlowers.count) existing")
        
        var mergedDict = Dictionary(uniqueKeysWithValues: existingFlowers.map { ($0.id, $0) })
        var stats = MergeStats()
        
        for importedFlower in importedFlowers {
            if let existingFlower = mergedDict[importedFlower.id] {
                // Flower exists - compare dates and keep newer version
                let existingDate = existingFlower.discoveryDate ?? existingFlower.generatedDate
                let importedDate = importedFlower.discoveryDate ?? importedFlower.generatedDate
                
                if importedDate > existingDate {
                    mergedDict[importedFlower.id] = importedFlower
                    stats.updatedFlowers += 1
                    print("🌻 Updated '\(importedFlower.name)' with newer version from backup")
                } else {
                    stats.keptExisting += 1
                    print("🌻 Kept existing '\(existingFlower.name)' (newer or same date)")
                }
            } else {
                // New flower from backup
                mergedDict[importedFlower.id] = importedFlower
                stats.newFlowers += 1
                print("🌻 Added new flower '\(importedFlower.name)' from backup")
            }
        }
        
        // Sort by discovery/generated date (newest first)
        let mergedFlowers = Array(mergedDict.values).sorted {
            let date1 = $0.discoveryDate ?? $0.generatedDate
            let date2 = $1.discoveryDate ?? $1.generatedDate
            return date1 > date2
        }
        
        print("🌻 Merge complete: \(mergedFlowers.count) total flowers (\(stats.newFlowers) new, \(stats.updatedFlowers) updated, \(stats.keptExisting) kept)")
        
        return (mergedFlowers, stats)
    }
    
    // MARK: - Quick Export/Import for Current Collection
    func createQuickBackup(from flowerStore: FlowerStore) async -> BackupResult {
        do {
            // Access FlowerStore properties on MainActor
            let flowers = await MainActor.run { flowerStore.discoveredFlowers }
            let userName = UserDefaults.standard.string(forKey: "userName")
            
            let fileURL = try await exportCompleteCollection(
                flowers: flowers,
                exporterName: userName,
                exporterLocation: nil
            )
            
            let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0
            let formattedSize = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
            
            return .success(
                flowersCount: flowers.count,
                fileSize: formattedSize,
                filePath: fileURL.path
            )
            
        } catch {
            return .failure(error.localizedDescription)
        }
    }
    
    func restoreFromBackup(fileURL: URL, flowerStore: FlowerStore) async -> RestoreResult {
        do {
            let (importedFlowers, metadata) = try await importCompleteCollection(from: fileURL)
            // Access FlowerStore properties on MainActor
            let existingFlowers = await MainActor.run { flowerStore.discoveredFlowers }
            
            let (mergedFlowers, stats) = mergeCollectionWithExisting(
                importedFlowers: importedFlowers,
                existingFlowers: existingFlowers
            )
            
            // Update flower store
            await MainActor.run {
                flowerStore.discoveredFlowers = mergedFlowers
                flowerStore.favorites = mergedFlowers.filter { $0.isFavorite }
                flowerStore.saveFlowers()
            }
            
            return .success(
                flowersCount: importedFlowers.count,
                newFlowers: stats.newFlowers,
                updatedFlowers: stats.updatedFlowers
            )
            
        } catch {
            return .failure(error.localizedDescription)
        }
    }
    
    // MARK: - Auto-Backup Feature
    func performAutoBackup(flowerStore: FlowerStore) async {
        let lastBackupKey = "lastAutoBackupDate"
        let backupIntervalHours = 24.0 // Backup every 24 hours
        
        // Check if backup is needed
        if let lastBackup = UserDefaults.standard.object(forKey: lastBackupKey) as? Date {
            let hoursSinceLastBackup = Date().timeIntervalSince(lastBackup) / 3600
            if hoursSinceLastBackup < backupIntervalHours {
                print("🌻 Auto-backup not needed yet (last backup \(Int(hoursSinceLastBackup)) hours ago)")
                return
            }
        }
        
        print("🌻 Performing auto-backup...")
        
        let result = await createQuickBackup(from: flowerStore)
        switch result {
        case .success(let flowersCount, let fileSize, let filePath):
            UserDefaults.standard.set(Date(), forKey: lastBackupKey)
            
            // Store backup info for settings display
            UserDefaults.standard.set(flowersCount, forKey: "lastBackupFlowerCount")
            UserDefaults.standard.set(fileSize, forKey: "lastBackupFileSize")
            UserDefaults.standard.set(Date(), forKey: "lastBackupDate")
            
            print("🌻 Auto-backup completed: \(flowersCount) flowers (\(fileSize))")
            
        case .failure(let error):
            print("🌻 Auto-backup failed: \(error)")
        }
    }
    
    // MARK: - Cleanup old backups
    func cleanupOldBackups() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: [.creationDateKey])
            let bouquetFiles = files.filter { $0.pathExtension == "bouquet" }
            
            // Keep only the 5 most recent backup files
            let sortedFiles = bouquetFiles.sorted { file1, file2 in
                let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                return date1 > date2
            }
            
            if sortedFiles.count > 5 {
                let filesToDelete = sortedFiles.dropFirst(5)
                for file in filesToDelete {
                    try? FileManager.default.removeItem(at: file)
                    print("🌻 Cleaned up old backup: \(file.lastPathComponent)")
                }
            }
            
        } catch {
            print("🌻 Failed to cleanup old backups: \(error)")
        }
    }
}

// MARK: - Supporting Types
struct MergeStats {
    var newFlowers = 0
    var updatedFlowers = 0
    var keptExisting = 0
}

// MARK: - Document Interaction Support
extension FlowerBackupService: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return UIViewController()
        }
        return rootViewController
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        // Clean up after successful transfer
        cleanupOldBackups()
    }
}