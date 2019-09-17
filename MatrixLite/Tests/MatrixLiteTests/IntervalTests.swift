//
// Copyright (c) 2017 Set. All rights reserved.
//

import XCTest
@testable import MatrixLite

class IntervalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCountableClosedRange() {
        let a = (0...5)
        // Should satisfy Interval Protocol
        XCTAssertEqual(a.start!, 0)
        XCTAssertEqual(a.end!, 5)
    }

    func testCountableRange() {
        let a = (0..<5)
        // Should satisfy Interval Protocol
        XCTAssertEqual(a.start!, 0)
        XCTAssertEqual(a.end!, 4)
    }

    func testCountableOpenEndedRangePrefix() {
        let a = (...5)
        // Should satisfy Interval Protocol
        XCTAssertNil(a.start)
        XCTAssertEqual(a.end!, 5)
    }

    func testCountableOpenEndedRangePostfix() {
        let a = (0...)
        // Should satisfy Interval Protocol
        XCTAssertEqual(a.start!, 0)
        XCTAssertNil(a.end)
    }

    func testCountableOpenRangePrefix() {
        let a = (..<6)
        // Should satisfy Interval Protocol
        XCTAssertNil(a.start)
        XCTAssertEqual(a.end!, 5)
    }

    func testIntAsInterval() {
        let a = 5
        // Should satisfy Interval Protocol
        XCTAssertEqual(a.start!, 5)
        XCTAssertEqual(a.end!, 5)
    }
}
