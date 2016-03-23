//
//  uuid4.swift
//  twohundred
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Foundation

import XCTest
@testable import UnchainedUUID

class uuidTests: XCTestCase {
    
    func testUUIDFromString() throws {
        let uuid = UUID4(string: "de305d54-75b4-431b-adb2-eb6b9e546014")
        XCTAssertNotNil(uuid)
        XCTAssert(uuid!.description == "DE305D54-75B4-431B-ADB2-EB6B9E546014")
    }

    func testUUIDFromStringFail1() throws {
        let uuid = UUID4(string: "de305d54-75b4-431badb2-eb6b9e546014")
        XCTAssertNil(uuid)
    }

    func testUUIDFromStringFail2() throws {
        let uuid = UUID4(string: "de305d54-75b4-431b-adb2-b6b9e546014")
        XCTAssertNil(uuid)
    }

    func testUUIDFromStringFail3() throws {
        let uuid = UUID4(string: "de305d54-75b4-431b-adb2-b6b9e54601")
        XCTAssertNil(uuid)
    }

}

#if os(Linux)
extension uuidTests {
    static var allTests : [(String, uuidTests -> () throws -> Void)] {
        return [
            ("testUUIDFromString", testUUIDFromString),
            ("testUUIDFromStringFail1", testUUIDFromStringFail1),
            ("testUUIDFromStringFail2", testUUIDFromStringFail2),
            ("testUUIDFromStringFail3", testUUIDFromStringFail3)
        ]
    }
}
#endif