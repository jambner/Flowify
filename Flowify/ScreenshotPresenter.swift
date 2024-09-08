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
    private var observerFlag: Bool?
    private weak var viewController: FormViewController?
    private var model: ScreenshotHandler?

    //TODO: Fix this issue where @objc selector is being unrecognized when in presenter class.
    @objc func toggleRecordButtonAction() {
        recordingToggle{ success in
            if success {
                print("worked")
                //have submit completion here as well
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
                notificationCenter.addObserver(self, selector: #selector(handleScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
                print("Started recording toggle")
                observerFlag = true
            }
        } else {
            // First time toggle
            notificationCenter.addObserver(self, selector: #selector(handleScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
            print("Started recording toggle")
            observerFlag = true
        }
        
        completion(true)
    }
    
    func prepareFormData(name: String, email: String) {

    }
    
    func getData(_ textfield: UITextField) -> Bool {
        return true
    }
    
    @objc func notify() {
        print("Submit button tapped")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background")
    }
    
    // Should be moved to handler
    @objc private func handleScreenshot() {
        print("hi")
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

        model?.updateData(formData: [key: data])
        return true
    }
}
