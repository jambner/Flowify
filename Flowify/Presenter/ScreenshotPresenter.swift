//
//  ScreenshotPresenter.swift
//  Flowify
//
//  Created by Ramon Martinez on 8/31/24.
//

import Foundation
import Photos
import UIKit

class ScreenshotPresenter {
    typealias RecordCompletion = (Bool) -> Void
    var notificationCenter = NotificationCenter.default
    var observerFlag: Bool?
    private weak var viewController: FormViewController?
    var handler: ScreenshotHandler?

    init() {
        handler = ScreenshotHandler()
    }

    // Completion handler to make sure the recording is starting or ending
    func recordingToggle(completion: @escaping RecordCompletion) {
        let notificationName = UIApplication.userDidTakeScreenshotNotification
        if let existingObserver = observerFlag {
            if existingObserver {
                notificationCenter.removeObserver(self, name: notificationName, object: nil)
                print("Stopped recording toggle")
                observerFlag = false
            } else {
                notificationCenter.addObserver(self, selector: #selector(handleScreenshotSelector(_:)), name: notificationName, object: nil)
                print("Started recording toggle")
                observerFlag = true
            }
        } else {
            // First time toggle
            notificationCenter.addObserver(self, selector: #selector(handleScreenshotSelector(_:)), name: notificationName, object: nil)
            print("Started recording toggle")
            observerFlag = true
        }

        completion(true)
    }
    
    @objc func handleScreenshotSelector(_ notification: NSNotification) {
        handler?.handleScreenshot(notification: notification)
    }

    func photoAccessAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
            case .authorized:
                // Allows album creation
                print("authorized")
                self.handler?.albumCreation { success, _ in
                    if success {
                        print("Successfully created album")
                    } else {
                        print("FAILED")
                    }
                }
            case .limited:
                // Allows album creation
                print("limited")
            @unknown default:
                print("Error!")
            }
        }
    }
}

extension ScreenshotPresenter: DataRetrieval {
    func retrieveData(from textfields: [UITextField]) -> Bool {
        var formData: [String: String] = [:]

        // Loop through each textfield for each key-data pair
        for textField in textfields {
            guard let key = textField.key, !key.isEmpty,
                  let data = textField.text, !data.isEmpty
            else {
                continue
            }

            // Combine all pairs into a dictionary
            formData[key] = data
        }

        // Call the updateData function with the combined formData dictionary
        if !formData.isEmpty {
            handler?.updateData(formData: formData)
            return true
        }

        // Return false if no valid data was collected
        return false
    }
}