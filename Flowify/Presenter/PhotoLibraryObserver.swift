//
//  PhotoLibraryObserver.swift
//  Flowify
//
//  Created by jambo on 10/2/24.
//

import Foundation
import Photos
import UIKit

class PhotoLibraryObserver: NSObject {
    private var isObserving = false
    private var screenshotHandler: ScreenshotHandler?
    private var processedAssets = Set<String>()
    
    init(albumName: String) {
        super.init()
        self.screenshotHandler = ScreenshotHandler()
        self.screenshotHandler?.updateData(formData: ["name": albumName])
    }
    
    func startObserving() {
        screenshotHandler?.albumCreation { [weak self] success, error in
            if success {
                guard !(self?.isObserving ?? true) else { return }
                PHPhotoLibrary.shared().register(self!)
                self?.isObserving = true
                print("Started observing photo library changes.")
            } else if let error = error {
                print("Failed to create/verify album: \(error.localizedDescription)")
            }
        }
    }
    
    func stopObserving() {
        guard isObserving else { return }
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        isObserving = false
        print("Stopped observing photo library changes.")
    }
    
    private func isScreenshot(_ asset: PHAsset) -> Bool {
        return asset.mediaSubtypes.contains(.photoScreenshot)  // More reliable screenshot check
    }
}

// MARK: - PhotoLibraryObserver Extension
extension PhotoLibraryObserver: PHPhotoLibraryChangeObserver {
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
        
        // Merge images after processing the batch of new assets
//        screenshotHandler?.mergeImagesAfterProcessing(assets: newScreenshots)
    }
}
