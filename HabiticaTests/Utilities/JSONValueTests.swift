//
//  JSONValueTests.swift
//  HabiticaTests
//

import XCTest
import Habitica_Models

class JSONValueTests: XCTestCase {

    func testDecodesJSONInsideStrings() throws {
        XCTAssertEqual(try JSONValue.string("3000").decodeAllowingJSONString(Int.self), 3000)
        XCTAssertEqual(try JSONValue.string("true").decodeAllowingJSONString(Bool.self), true)
        XCTAssertEqual(try JSONValue.string("[\"a\",\"b\"]").decodeAllowingJSONString([String].self), ["a", "b"])
        XCTAssertEqual(try JSONValue.string("{\"k\":\"v\"}").decodeAllowingJSONString([String: String].self), ["k": "v"])
    }

    func testPlainValuesDecodeDirectly() throws {
        // A string that happens to be valid JSON stays a string when a string is wanted
        XCTAssertEqual(try JSONValue.string("[]").decodeAllowingJSONString(String.self), "[]")
        XCTAssertEqual(try JSONValue.int(5).decodeAllowingJSONString(Int.self), 5)
        XCTAssertEqual(try JSONValue.array([.string("a")]).decodeAllowingJSONString([String].self), ["a"])
    }

    func testInvalidValuesThrow() {
        XCTAssertThrowsError(try JSONValue.string("abc").decodeAllowingJSONString(Int.self))
        XCTAssertThrowsError(try JSONValue.bool(true).decodeAllowingJSONString([String].self))
    }
}
