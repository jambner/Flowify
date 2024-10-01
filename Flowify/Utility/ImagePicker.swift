//
//  ImagePicker.swift
//  Flowify
//
//  Created by jambo on 9/21/24.
//


import UIKit
import Photos
import PhotosUI

protocol ImagePickerDelegate: AnyObject {
    func didSelectImages(images: [UIImage])
}

class ImagePicker: NSObject, PHPickerViewControllerDelegate {
    weak var delegate: ImagePickerDelegate?

    func present(from viewController: UIViewController) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // Allow multiple selection
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - PHPickerViewControllerDelegate

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            var selectedImages: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                if let assetIdentifier = result.assetIdentifier {
                    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true

                    if let asset = asset {
                        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, _) in
                            if let image = image {
                                selectedImages.append(image)
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.delegate?.didSelectImages(images: selectedImages)
            }
        }
    }
}
