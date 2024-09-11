//
//  ScreenshotHandler.swift
//  Flowify
//
//  Created by Ramon Martinez on 8/31/24.
//

import Foundation
import Photos
import UIKit

class ScreenshotHandler {
    // FormData; will most likely move to a different class
    private(set) var formData: [String: String] = [:]

    func updateData(formData: [String: String]) {
        let data = formData
        self.formData = data
    }

    private func dictionaryLookUp(forKey key: String, in dictionary: [String: String]) -> String {
        return dictionary[key] ?? ""
    }

    func albumCreation(completion: @escaping (Bool, Error?) -> Void) {
        let nameData = dictionaryLookUp(forKey: "name", in: formData)
        PHPhotoLibrary.shared().performChanges({
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "title = %@", nameData)
            let existingAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options).firstObject

            if existingAlbum == nil {
                // Creates new album
                _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: nameData)
            }
        }) { success, error in
            completion(success, error)
        }
    }

    @objc func handleScreenshot(notification _: NSNotification) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        guard let lastScreenshotAsset = fetchResult.firstObject else {
            print("No screenshots found")
            return
        }

        // Process the screenshot
        processScreenshot(asset: lastScreenshotAsset)
    }

    private func processScreenshot(asset: PHAsset) {
        let options = PHImageRequestOptions()
        var SSID = 0
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: asset, options: options) { data, _, _, _ in
            guard let imageData = data else {
                print("Failed to get image data")
                return
            }

            let newFileName = "Screenshot_\(SSID += 1).png"
            self.copyImageIntoAlbum(imageData: imageData, fileName: newFileName, originalAsset: asset)
        }
    }

    private func copyImageIntoAlbum(imageData: Data, fileName _: String, originalAsset _: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            // Fetch the album where we want to save the new image
            let nameData = self.dictionaryLookUp(forKey: "name", in: self.formData)
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", nameData)
            let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject

            // Create the new image asset in the album
            if let album = album {
                let creationRequest = PHAssetCreationRequest.creationRequestForAsset(from: UIImage(data: imageData)!)
                let assetPlaceholder = creationRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([assetPlaceholder!] as NSArray)
            } else {
                print("Album not found")
            }
        }) { success, error in
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            } else if success {
                print("Image successfully saved")
            }
        }
    }
}
