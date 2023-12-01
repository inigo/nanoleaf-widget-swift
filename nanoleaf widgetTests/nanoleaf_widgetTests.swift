//
//  nanoleaf_widgetTests.swift
//  nanoleaf widgetTests
//
//  Created by Inigo Surguy on 30/11/2023.
//

import XCTest
import Foundation
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

}
