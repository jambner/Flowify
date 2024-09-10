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
    func retrieveData(_ textfield: UITextField) -> Bool {
        guard textfield.text != nil else {
            return false
        }
        var key: String
        var data: String

        key = textfield.key
        data = textfield.text ?? ""

        handler?.updateData(formData: [key: data])
        return true
    }
}
