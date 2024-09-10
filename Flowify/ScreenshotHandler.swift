//
//  ScreenshotHandler.swift
//  Flowify
//
//  Created by Ramon Martinez on 8/31/24.
//

import Foundation


class ScreenshotHandler {
    
    let viewController: FormViewController?
    
    init() {
        self.viewController = FormViewController()
    }
    
    func updateData(formData: [String: String]) {
        print("success")
    }
    
    @objc func handleScreenshot() {
        print("hi")
    }
}
