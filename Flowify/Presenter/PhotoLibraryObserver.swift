//
//  PhotoLibraryObserver.swift
//  Flowify
//
//  Created by Ramon Martinez on 10/2/24.
//

import Photos

class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    private var isObserving = false
    private var dataModel = DataModel.shared
    private var albumManager: AlbumManager?
    private var screenshotHandler: ScreenshotHandler?
    private var processedAssets = Set<String>()

    override init() {
        super.init()
        self.screenshotHandler = ScreenshotHandler()
        albumManager = AlbumManager()
    }

    func startObserving() {
        albumManager?.albumCreation { [weak self] success, error in
            if success {
                guard !(self?.isObserving ?? true) else { return }
                PHPhotoLibrary.shared().register(self!) // Register as observer
                self?.isObserving = true
                print("Started observing photo library changes.")
            } else if let error = error {
                print("Failed to create/verify album: \(error.localizedDescription)")
            }
        }
    }

    func stopObserving() {
        guard isObserving else { return }
        PHPhotoLibrary.shared().unregisterChangeObserver(self) // Unregister as observer
        isObserving = false
        print("Stopped observing photo library changes.")
        
        // Fetch the album and its assets, then merge
        fetchAlbumAndMergeImages()
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            print("Photo library change detected")
            self.handlePhotoLibraryChange()
        }
    }

    private func handlePhotoLibraryChange() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var newScreenshots: [PHAsset] = []

        fetchResult.enumerateObjects { asset, _, _ in
            if !self.processedAssets.contains(asset.localIdentifier) && self.isScreenshot(asset) {
                newScreenshots.append(asset)
                self.processedAssets.insert(asset.localIdentifier)
            }
        }

        guard !newScreenshots.isEmpty else {
            print("No new screenshots found.")
            return
        }

        print("New screenshots detected: \(newScreenshots.count)")
        screenshotHandler?.processScreenshots(assets: newScreenshots)
    }

    private func isScreenshot(_ asset: PHAsset) -> Bool {
        return asset.mediaSubtypes.contains(.photoScreenshot)  // More reliable screenshot check
    }

    private func fetchAlbumAndMergeImages() {
        // Use ScreenshotHandler to fetch the album
        albumManager?.albumCreation { [weak self] success, error in
            if success {
                // Fetch the assets from the album
                let nameData = self?.dataModel.dictionaryLookUp(forKey: "name", in: self?.dataModel.currentFormData ?? [:]) ?? ""
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", nameData)
                
                // Fetch the album by title
                guard let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject else {
                    print("Album not found for merging.")
                    return
                }

                // Fetch assets within the album
                let albumAssets = PHAsset.fetchAssets(in: album, options: nil)

                // Load images and merge them
                self?.albumManager?.loadImagesFromAlbum(albumAssets) { images in
                    if !images.isEmpty {
                        self?.screenshotHandler?.mergeAndSaveImages(images: images) { success, error in
                            if let error = error {
                                print("Error merging images: \(error.localizedDescription)")
                            } else {
                                print("Images merged successfully.")
                            }
                        }
                    } else {
                        print("No images found to merge.")
                    }
                }
            } else if let error = error {
                print("Error creating album: \(error.localizedDescription)")
            }
        }
    }
}
