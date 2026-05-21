//
//  ScanCamTests.swift
//  ScanCamTests
//
//  Created by NTTDATA on 21/05/26.
//

import XCTest
@testable import ScanCam

final class ScanCamTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    @MainActor
    func testImageToText() async throws {
        
        let vm = CaptureViewModel()
        
        let testBundle = Bundle(for: CaptureViewModel.self)
        
        let image = try XCTUnwrap(UIImage(named: "test_image", in: testBundle, with: nil), "Image asset 'testImage' not found." )
        
        let text = await vm.recognizeText(from: image)
        print(text)
        
        XCTAssertNotNil(text)
        XCTAssertNotEqual(text, "", "Text should not be empty if image has some Text")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
