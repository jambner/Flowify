//
//  ScreenshotPresenter.swift
//  Flowify
//
//  Created by Ramon Martinez on 8/31/24.
//

import Foundation
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

    // TODO: Fix this issue where @objc selector is being unrecognized when in presenter class.
    @objc func toggleRecordButtonAction() {
        recordingToggle { success in
            if success {
                print("worked")
                // have submit completion here as well
            } else {
                print("no work")
            }
        }
    }

    // Completion handler to make sure the recording is starting or ending
    func recordingToggle(completion: @escaping RecordCompletion) {
        if let existingObserver = observerFlag {
            if existingObserver {
                notificationCenter.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
                print("Stopped recording toggle")
                observerFlag = false
            } else {
                notificationCenter.addObserver(self, selector: #selector(handler?.handleScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
                print("Started recording toggle")
                observerFlag = true
            }
        } else {
            // First time toggle
            notificationCenter.addObserver(self, selector: #selector(handler?.handleScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
            print("Started recording toggle")
            observerFlag = true
        }

        completion(true)
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
