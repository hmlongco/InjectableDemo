//
//  InjectableDemoTests.swift
//  InjectableDemoTests
//
//  Created by Michael Long on 7/31/21.
//

import XCTest
@testable import InjectableDemo

class InjectableDemoTests: XCTestCase {

    override func setUpWithError() throws {
        Injections.registerMockServices()
    }

    func testExample() throws {
        let viewModel = ContentViewModel()
        XCTAssert(viewModel.id.contains("Mock"))
    }

}
