import Foundation
import UIKit
import UniformTypeIdentifiers

// MARK: - Custom Document Type
extension UTType {
    static let flowerDocument = UTType(exportedAs: "com.october.flowers.flower")
}

// MARK: - Flower Transfer Service
class FlowerTransferService: NSObject {
    static let shared = FlowerTransferService()
    
    // MARK: - Error Types
    enum TransferError: Error, LocalizedError {
        case invalidFlowerData
        case encodingError
        case decodingError
        case duplicateTransfer
        case transferCancelled
        
        var errorDescription: String? {
            switch self {
            case .invalidFlowerData:
                return "Invalid flower data"
            case .encodingError:
                return "Failed to prepare flower for transfer"
            case .decodingError:
                return "Failed to receive flower"
            case .duplicateTransfer:
                return "This flower has already been received"
            case .transferCancelled:
                return "Transfer was cancelled"
            }
        }
    }
    
    // MARK: - Export Flower for Transfer
    func exportFlower(_ flower: AIFlower, senderName: String = "Anonymous", senderLocation: String? = nil) throws -> URL {
        var flowerToTransfer = flower
        
        // Create owner info for current user
        let currentOwner = FlowerOwner(
            name: senderName,
            transferDate: Date(),
            location: senderLocation
        )
        
        // Prepare flower for transfer
        let metadata = flowerToTransfer.prepareForTransfer(from: currentOwner)
        
        // Create flower document
        let document = FlowerDocument(
            flower: flowerToTransfer,
            transferMetadata: metadata
        )
        
        // Encode to JSON with pretty printing
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(document) else {
            throw TransferError.encodingError
        }
        
        // Create temporary file with sanitized name
        let tempDir = FileManager.default.temporaryDirectory
        let sanitizedName = sanitizeFileName(flower.name)
        let fileName = "\(sanitizedName).flower"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // Write data to file
        try data.write(to: fileURL)
        
        print("FlowerTransferService: Exported flower '\(flower.name)' to \(fileURL.path)")
        return fileURL
    }
    
    // MARK: - Convenience Export Method
    func exportFlower(_ flower: AIFlower) throws -> URL {
        return try exportFlower(flower, senderName: "Anonymous", senderLocation: nil)
    }
    
    // MARK: - Import Received Flower
    func importFlower(from url: URL) throws -> (flower: AIFlower, senderInfo: FlowerOwner) {
        // Read data from file
        guard let data = try? Data(contentsOf: url) else {
            throw TransferError.invalidFlowerData
        }
        
        // Decode flower document
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let document = try? decoder.decode(FlowerDocument.self, from: data) else {
            throw TransferError.decodingError
        }
        
        // Validate transfer token (prevent duplicates)
        if document.flower.transferToken == nil {
            throw TransferError.duplicateTransfer
        }
        
        // Complete the transfer
        var receivedFlower = document.flower
        receivedFlower.completeTransfer()
        
        return (receivedFlower, document.transferMetadata.senderInfo)
    }
    
    // MARK: - Helper Methods
    private func sanitizeFileName(_ name: String) -> String {
        let invalidChars = CharacterSet(charactersIn: "/<>:\\|?*\"")
        return name.components(separatedBy: invalidChars).joined(separator: "_")
    }
    
    // MARK: - Clean up temporary files
    func cleanupTemporaryFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let flowerFiles = files.filter { $0.pathExtension == "flower" }
            
            for file in flowerFiles {
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Failed to cleanup temporary files: \(error)")
        }
    }
}

// MARK: - Document Interaction Support
extension FlowerTransferService: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return UIViewController()
        }
        return rootViewController
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        // Clean up after successful transfer
        cleanupTemporaryFiles()
    }
} 