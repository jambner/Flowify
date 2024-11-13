//
//  ScreenshotHandler.swift
//  Flowify
//
//  Created by Ramon Martinez on 8/31/24.
//

import Foundation
import Photos
import UIKit

class ScreenshotHandler: NSObject {
    private(set) var formData: [String: String] = [:]
    private let imageMerger = ImageMerger()
    private var processedAssets = Set<String>()

    override init() {
        super.init()
    }

    func updateData(formData: [String: String]) {
        self.formData = formData
    }

    func dictionaryLookUp(forKey key: String, in dictionary: [String: String]) -> String {
        return dictionary[key] ?? ""
    }
    
    func albumCreation(completion: @escaping (Bool, Error?) -> Void) {
        let nameData = dictionaryLookUp(forKey: "name", in: formData)

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

    func processScreenshots(assets: [PHAsset]) {
        let nameData = dictionaryLookUp(forKey: "name", in: formData)
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", nameData)
        
        guard let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject else {
            print("Target album not found")
            return
        }
    
        let albumAssets = PHAsset.fetchAssets(in: album, options: nil)
        loadImagesFromAlbum(albumAssets) { [weak self] images in
            if !images.isEmpty {
                print("Images loaded from album, waiting to merge.")
            }
        }
    
        // Process new assets
        processNewAssets(assets, to: album)
    }

    func mergeImagesAfterProcessing(assets: [PHAsset]) {
        // Once new assets have been processed, perform image merging
        let nameData = dictionaryLookUp(forKey: "name", in: formData)
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", nameData)
        
        guard let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject else {
            print("Target album not found for merging.")
            return
        }

        // Load images for merging
        let albumAssets = PHAsset.fetchAssets(in: album, options: nil)
        loadImagesFromAlbum(albumAssets) { [weak self] images in
            if !images.isEmpty {
                self?.mergeAndSaveImages(images: images) { success, error in
                    if let error = error {
                        print("Error merging images: \(error.localizedDescription)")
                    } else {
                        print("Images merged successfully")
                    }
                }
            } else {
                print("No images found to merge.")
            }
        }
    }
    
    private func processNewAssets(_ assets: [PHAsset], to album: PHAssetCollection) {
        let albumAssets = PHAsset.fetchAssets(in: album, options: nil)
        var existingAssetIds = Set<String>()
        albumAssets.enumerateObjects { asset, _, _ in
            existingAssetIds.insert(asset.localIdentifier)
        }

        let newAssets = assets.filter { asset in
            let isNew = !existingAssetIds.contains(asset.localIdentifier) && !processedAssets.contains(asset.localIdentifier)
            if isNew {
                print("New asset to process: \(asset.localIdentifier)")
            }
            return isNew
        }

        if newAssets.isEmpty {
            print("No new assets to process.")
        } else {
            print("Processing \(newAssets.count) new assets.")
            processBatch(assets: newAssets, to: album)
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

    private func processBatch(assets: [PHAsset], to album: PHAssetCollection) {
        let group = DispatchGroup()
        var processedImages: [(PHAsset, Data)] = []
        
        for asset in assets {
            group.enter()
            requestImageData(for: asset) { imageData in
                if let imageData = imageData {
                    processedImages.append((asset, imageData))
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.copyImagesIntoAlbum(processedImages: processedImages, album: album)
        }
    }

    private func requestImageData(for asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false

        PHImageManager.default().requestImageData(for: asset, options: options) { data, _, _, _ in
            completion(data)
        }
    }

    private func copyImagesIntoAlbum(processedImages: [(PHAsset, Data)], album: PHAssetCollection) {
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

    // MARK: Image Merging
    func mergeAndSaveImages(images: [UIImage], completion: @escaping (Bool, Error?) -> Void) {
        guard let mergedImage = imageMerger.mergeImages(images: images) else {
            completion(false, nil)
            return
        }
        UIImageWriteToSavedPhotosAlbum(mergedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        completion(true, nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving merged image: \(error.localizedDescription)")
        } else {
            print("Merged image saved successfully!")
        }
    }
}
