//
//  nanoleaf_widgetTests.swift
//  nanoleaf widgetTests
//
//  Created by Inigo Surguy on 30/11/2023.
//

import XCTest
import Foundation
import Combine
@testable import nanoleaf_widget

final class nanoleaf_widgetTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCamelCase() throws {
        XCTAssertEqual(addSpacesToCamelCase("TastyFish"), "Tasty Fish")
        XCTAssertEqual(addSpacesToCamelCase("Cheese"), "Cheese")
    }
    
    
    func testUrlProcessing() throws {
        let url = URL(string: "nanoleafwidget://CocoaBeach")!
        XCTAssertEqual(url.host(), "CocoaBeach")
    }

    
    func testChangeScene() throws {
        changeScene(scene: "Blaze")
    }
    
    func testGetAuthToken() async throws {
        let result = await getAuthCode(ipAddressAndPort: "192.168.5.121:16021")
        print("Auth code is \(result)")
        XCTAssertNotNil(result)
    }
    
    
    func testChangeSceneNativeOther() async throws {
        let result = try await otherSendSceneChangeRequest(sceneName: "Cocoa Beach", ipAddressAndPort: "192.168.5.121:16021", authToken: "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c")
        XCTAssertNotNil(result)
    }
    
    
//    func testChangeSceneNative() throws {
//        let expectation = XCTestExpectation(description: "Network task complete")
//
//        let cancellable: AnyCancellable? = sendSceneChangeRequest(sceneName: "Jungle", ipAddressAndPort: "192.168.5.121:16021", authToken: "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c")
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print("Error: \(error)")
//                    XCTFail("Failed with \(error)")
//                case .finished:
//                    break
//                }
//                expectation.fulfill()
//            }, receiveValue: { data in
//                print("Got data back "+data.base64EncodedString())
//                
//                let decoded = String(data: data, encoding: .utf8)!
//                print("Decoded to \(decoded)")
//                
//                // Perform assertions with 'data'
//            })
//
//        wait(for: [expectation], timeout: 10.0)
//        cancellable?.cancel()
//    }

}
