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
    private var dataModel = DataModel.shared
    private let imageMerger = ImageMerger()
    private var albumManager: AlbumManager?
    private var processedAssets = Set<String>()

    override init() {
        super.init()
        albumManager = AlbumManager()
    }

    lazy var album: PHAssetCollection? = {
        return albumManager?.fetchAlbumForNameData()
    }()

    func processScreenshots(assets: [PHAsset]) {
        guard let validAlbum = album else {
            print("Target album not found")
            return
        }

        let albumAssets = PHAsset.fetchAssets(in: validAlbum, options: nil)
        albumManager?.loadImagesFromAlbum(albumAssets) { [weak self] images in
            if !images.isEmpty {
                print("Images loaded from album, waiting to merge.")
            }
        }

        processNewAssets(assets, to: validAlbum)
    }

    func mergeImagesAfterProcessing(assets: [PHAsset]) {
        guard let validAlbum = album else {
            print("Target album not found for merging.")
            return
        }

        let albumAssets = PHAsset.fetchAssets(in: validAlbum, options: nil)
        albumManager?.loadImagesFromAlbum(albumAssets) { [weak self] images in
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

        if !newAssets.isEmpty {
            print("Processing \(newAssets.count) new assets.")
            processBatch(assets: newAssets, to: album)
        } else {
            print("No new assets to process.")
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
            self.albumManager?.copyImagesIntoAlbum(processedImages: processedImages, album: album)
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

    // MARK: Image Merging
    func mergeAndSaveImages(images: [UIImage], completion: @escaping (Bool, Error?) -> Void) {
        let imageBundles = bundleImages(images: images, bundleSize: 5)

        for bundle in imageBundles {
            guard let mergedImage = imageMerger.mergeImages(images: bundle) else {
                print("Error merging images in the bundle.")
                completion(false, nil)
                return
            }

            albumManager?.saveImageToAlbum(mergedImage) { success, error in
                if success {
                    print("Merged image saved to album successfully!")
                } else {
                    print("Error saving merged image to album: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        completion(true, nil)
    }

    private func bundleImages(images: [UIImage], bundleSize: Int) -> [[UIImage]] {
        var imageBundles: [[UIImage]] = []
        var currentBundle: [UIImage] = []

        for image in images {
            currentBundle.append(image)

            if currentBundle.count == bundleSize {
                imageBundles.append(currentBundle)
                currentBundle = []
            }
        }

        if !currentBundle.isEmpty {
            imageBundles.append(currentBundle)
        }

        return imageBundles
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving merged image: \(error.localizedDescription)")
        } else {
            print("Merged image saved successfully!")
        }
    }
}
