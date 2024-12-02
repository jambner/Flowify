//
//  AlbumManager.swift
//  Flowify
//
//  Created by Ramon Martinez on 11/13/24.
//

import Photos
import UIKit

class AlbumManager {
    private var dataModel = DataModel.shared
    private var processedAssets = Set<String>()

    func albumCreation(completion: @escaping (Bool, Error?) -> Void) {
        let nameData = dataModel.dictionaryLookUp(forKey: "name", in: dataModel.currentFormData)

        PHPhotoLibrary.shared().performChanges({
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "title = %@", nameData)
            let existingAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options).firstObject
            if existingAlbum == nil {
                print("Creating new album: \(nameData)")
                _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: nameData)
            } else {
                print("Album \(nameData) already exists")
            }
        }) { success, error in
            completion(success, error)
        }
    }

    func fetchAlbumForNameData() -> PHAssetCollection? {
        let nameData = dataModel.dictionaryLookUp(forKey: "name", in: dataModel.currentFormData)
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", nameData)

        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject
    }

    func copyImagesIntoAlbum(processedImages: [(PHAsset, Data)], album: PHAssetCollection) {
        guard !processedImages.isEmpty else { return }

        PHPhotoLibrary.shared().performChanges({
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            var assetPlaceholders: [PHObjectPlaceholder] = []

            for (asset, imageData) in processedImages {
                if let image = UIImage(data: imageData) {
                    let creationRequest = PHAssetCreationRequest.creationRequestForAsset(from: image)
                    if let placeholder = creationRequest.placeholderForCreatedAsset {
                        assetPlaceholders.append(placeholder)
                        self.processedAssets.insert(asset.localIdentifier)
                    }
                }
            }

            albumChangeRequest?.addAssets(assetPlaceholders as NSArray)

        }) { success, error in
            if let error = error {
                print("Error saving images: \(error.localizedDescription)")
            } else if success {
                print("Successfully saved \(processedImages.count) images to album")
            }
        }
    }

    func loadImagesFromAlbum(_ assets: PHFetchResult<PHAsset>, completion: @escaping ([UIImage]) -> Void) {
        var images: [UIImage] = []
        let group = DispatchGroup()

        assets.enumerateObjects { asset, _, _ in
            group.enter()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .default,
                options: options
            ) { image, info in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(images)
        }
    }
    
    func filterAssetsInAlbum(after timestamp: Date, albumName: String?, completion: @escaping ([PHAsset]) -> Void) {
        guard let album = fetchAlbumForNameData() else {
            print("No album found")
            completion([])
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "creationDate > %@", timestamp as NSDate) // Filter assets after the timestamp
        let albumAssets = PHAsset.fetchAssets(in: album, options: fetchOptions)

        var filteredAssets: [PHAsset] = []
        albumAssets.enumerateObjects { (asset, _, _) in
            filteredAssets.append(asset)
        }
        completion(filteredAssets)
    }

    func saveImageToAlbum(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        if let album = fetchAlbumForNameData() {
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = creationRequest.placeholderForCreatedAsset

                // Add the image to the fetched album
                if let assetPlaceholder = assetPlaceholder {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    albumChangeRequest?.addAssets([assetPlaceholder] as NSArray)
                }
            }) { success, error in
                if let error = error {
                    print("Error saving image to album: \(error.localizedDescription)")
                } else {
                    print("Image successfully saved to album!")
                }
                completion(success, error)
            }
        } else {
            print("Target album not found for saving merged image.")
            completion(false, nil)
        }
    }

}
