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

    
    func testChangeScene() async throws {
        try await changeScene(sceneName: "Blaze", ipAddressAndPort: "192.168.5.121:16021", authToken: "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c")
    }
    
    func testGetAuthToken() async throws {
        let result = await getAuthToken(ipAddressAndPort: "192.168.5.121:16021")
        print("Auth code is \(result)")
        XCTAssertNotNil(result)
    }
    
    
    func testChangeSceneNativeOther() async throws {
        let result = try await changeScene(sceneName: "Date Night", ipAddressAndPort: "192.168.5.121:16021", authToken: "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c")
        XCTAssertNotNil(result)
    }
    
}
