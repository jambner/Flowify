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
    var handler: ScreenshotHandler?
    var notificationCenter: NotificationCenter!

    override func setUp() {
        super.setUp()
        sut = ScreenshotPresenter()
        notificationCenter = NotificationCenter.default
        handler = ScreenshotHandler()
        sut?.handler = handler
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
        let mockObserverFlag = false
        sut?.observerFlag = mockObserverFlag

        sut?.recordingToggle { success in
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

    // TODO: Complete testing for photoaccess authorization
    func testPhotoAccess_Authorized() {
        let expectation = XCTestExpectation(description: "PhotosPermissions is granted")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPhotoAccess_Limited() {
        let expectation = XCTestExpectation(description: "PhotosPermission is limited")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPhotoAccess_Denied() {
        let expectation = XCTestExpectation(description: "PhotosPermissions is denied")
        
        sut?.photoAccessAuthorization()
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testRetrieveData_Success() {
        let mockArray = [MockData().textField1, MockData().textField2]

        let expectedData: [String?: String?] = [MockData().textField1.key: MockData().textField1.text, MockData().textField2.key: MockData().textField2.text]

        // Test retrieveData
        let success = sut?.retrieveData(from: mockArray)

        XCTAssertTrue(success != nil, "Data retrieval should succeed")
        XCTAssertEqual(handler?.formData, expectedData)
    }

    func testRetrieveData_NoData() {
        let mockArray: [UITextField] = []

        let error = sut?.retrieveData(from: mockArray)

        XCTAssertTrue(error != nil, "Data retrieval should fail")
    }

    struct MockData {
        var textField1: UITextField = {
            let textfield1 = UITextField()
            textfield1.key = "name"
            textfield1.text = "Dog"
            return textfield1
        }()

        var textField2: UITextField = {
            let textfield2 = UITextField()
            textfield2.key = "email"
            textfield2.text = "Dog@gmail.com"
            return textfield2
        }()
    }
}
