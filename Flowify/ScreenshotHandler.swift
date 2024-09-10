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
        viewController = FormViewController()
    }

    func updateData(formData _: [String: String]) {
        print("success")
    }

    @objc func handleScreenshot() {
        print("hi")
    }
}
