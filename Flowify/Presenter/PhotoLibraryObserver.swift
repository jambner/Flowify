//
//  PhotoLibraryObserver.swift
//  Flowify
//
//  Created by jambo on 10/2/24.
//

import Photos

class PhotoLibraryObserver: NSObject {
    private var isObserving = false
    private var lastToken: Int = 0 // To keep track of the last assigned token

    // Start observing photo library changes
    func startObserving() {
        guard !isObserving else { return }
        PHPhotoLibrary.shared().register(self)
        isObserving = true
        print("Started observing photo library changes.")
    }

    // Stop observing photo library changes
    func stopObserving() {
        guard isObserving else { return }
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        isObserving = false
        print("Stopped observing photo library changes.")
    }
}

// Conforming to the PHPhotoLibraryChangeObserver protocol
extension PhotoLibraryObserver: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.handlePhotoLibraryChange()
        }
    }

    private func handlePhotoLibraryChange() {
        // Fetch the latest images from the library
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        // Process newly added assets
        if fetchResult.count > 0 {
            print("New images detected: (fetchResult.count)")
        } else {
            print("No new images found.")
        }
    }
}
