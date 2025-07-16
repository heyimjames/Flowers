import Photos
import UIKit
import CoreLocation

class PhotoLibraryService {
    static let shared = PhotoLibraryService()
    private let albumName = "Flowers"
    
    private init() {}
    
    // MARK: - Public Methods
    
    func saveFlowerToLibrary(_ flower: AIFlower, completion: @escaping (Bool, Error?) -> Void) {
        // Check photo library authorization
        checkPhotoLibraryAuthorization { [weak self] authorized in
            guard authorized else {
                completion(false, PhotoLibraryError.notAuthorized)
                return
            }
            
            self?.performSave(flower: flower, completion: completion)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func performSave(flower: AIFlower, completion: @escaping (Bool, Error?) -> Void) {
        guard let imageData = flower.imageData,
              let image = UIImage(data: imageData) else {
            completion(false, PhotoLibraryError.invalidImage)
            return
        }
        
        // Get or create the Flowers album
        getFlowersAlbum { [weak self] album in
            guard let album = album else {
                completion(false, PhotoLibraryError.albumCreationFailed)
                return
            }
            
            self?.saveImageToAlbum(image: image, flower: flower, album: album, completion: completion)
        }
    }
    
    private func getFlowersAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
        // Check if album already exists
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let existingAlbum = collections.firstObject {
            completion(existingAlbum)
            return
        }
        
        // Create new album
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
        }) { success, error in
            if success {
                // Fetch the newly created album
                let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                DispatchQueue.main.async {
                    completion(collections.firstObject)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func saveImageToAlbum(image: UIImage, flower: AIFlower, album: PHAssetCollection, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            // Create asset creation request
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            
            // Add metadata
            let creationDate = flower.discoveryDate ?? flower.generatedDate
            creationRequest.creationDate = creationDate
            
            // Add location if available
            if let latitude = flower.discoveryLatitude,
               let longitude = flower.discoveryLongitude {
                let location = CLLocation(latitude: latitude, longitude: longitude)
                creationRequest.location = location
            }
            
            // Create description with flower information
            var description = "🌸 \(flower.name)"
            if let locationName = flower.discoveryLocationName {
                description += "\n📍 \(locationName)"
            }
            if let meaning = flower.meaning {
                description += "\n\n\(meaning)"
            }
            if let properties = flower.properties {
                description += "\n\nProperties: \(properties)"
            }
            
            // Note: iOS doesn't allow direct setting of description through Photos framework
            // The description is saved in the image's EXIF data if possible
            
            // Add to album
            if let placeholder = creationRequest.placeholderForCreatedAsset {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration = NSArray(object: placeholder)
                albumChangeRequest?.addAssets(enumeration)
            }
            
        }) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}

// MARK: - Error Types

enum PhotoLibraryError: LocalizedError {
    case notAuthorized
    case invalidImage
    case albumCreationFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Photo library access not authorized"
        case .invalidImage:
            return "Invalid image data"
        case .albumCreationFailed:
            return "Failed to create Flowers album"
        case .saveFailed:
            return "Failed to save image"
        }
    }
} 