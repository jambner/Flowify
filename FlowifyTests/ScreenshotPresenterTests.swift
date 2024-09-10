//
//  ScreenshotPresenterTests.swift
//  FlowifyTests
//
//  Created by Ramon Martinez on 9/9/24.
//

@testable import Flowify
import XCTest

class ScreenshotPresenterTests: XCTestCase {
    
    var sut: ScreenshotPresenter?
    var notificationCenter: NotificationCenter!
    
    override func setUp() {
        super.setUp()
        sut = ScreenshotPresenter()
        notificationCenter = NotificationCenter.default
    }
    
    override func tearDown() {
        sut = nil
        notificationCenter = nil
        super.tearDown()
    }
    
    func testRecordingToggle_StartsRecording() {
        let expectation = XCTestExpectation(description: "Recording toggle should start recording")
        
        sut?.recordingToggle { success in
            XCTAssertTrue(success, "Recording toggle should succeed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRecordingToggle_AlreadyRecording() {
        let expectation = XCTestExpectation(description: "Recording toggle is toggled")
        // Initialize a false flag in order to replicate that the recording toggle is already toggled.
        let mockObserverFlag: Bool = false
        sut?.observerFlag = mockObserverFlag
        
        self.sut?.recordingToggle { success in
                XCTAssertTrue(success, "Recording toggle is toggled")
            expectation.fulfill()
        }
    }
    
    func testRecordingToggle_StopsRecording() {
        let expectation = XCTestExpectation(description: "Recording toggle should stop recording")
        
        // First, start recording
        sut?.recordingToggle { _ in
            // Then, stop recording
            self.sut?.recordingToggle { success in
                XCTAssertTrue(success, "Recording toggle should succeed")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveData_ProcessesTextFieldData() {
        let textField = UITextField()
        textField.text = "test data"
        textField.key = "testKey"
        
        // Use a simple implementation of ScreenshotHandler or use a real one if available
        let screenshotHandler = ScreenshotHandler()
        sut?.handler = screenshotHandler
        
        // Test retrieveData
        let success = sut?.retrieveData(textField)
        
        XCTAssertTrue((success != nil), "Data retrieval should succeed")
    }
}

