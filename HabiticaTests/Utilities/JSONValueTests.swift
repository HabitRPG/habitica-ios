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

    func testParsesScalarsWithoutMixingTypes() throws {
        let values = try JSONDecoder().decode([JSONValue].self, from: Data("[true, 1, 0, 1.5, \"1\", null]".utf8))
        XCTAssertEqual(values, [.bool(true), .int(1), .int(0), .double(1.5), .string("1"), .null])
    }

    func testNumbersAreNotBools() {
        // A server sending 0/1 for a flag falls back to the default instead of being misread
        XCTAssertThrowsError(try JSONValue.int(1).decodeAllowingJSONString(Bool.self))
        XCTAssertThrowsError(try JSONValue.string("1").decodeAllowingJSONString(Bool.self))
    }

    func testIntDecodesAsDouble() throws {
        XCTAssertEqual(try JSONValue.int(2).decodeAllowingJSONString(Double.self), 2.0)
    }

    func testRoundTripsThroughCache() throws {
        let config: [String: JSONValue] = [
            "a": .object(["b": .array([.int(1), .null, .string("x")])]),
            "c": .bool(false),
            "d": .double(0.25)
        ]
        let decoded = try JSONDecoder().decode([String: JSONValue].self, from: JSONEncoder().encode(config))
        XCTAssertEqual(decoded, config)
    }

    func testStringValue() {
        XCTAssertEqual(JSONValue.string("a").stringValue, "a")
        XCTAssertNil(JSONValue.int(1).stringValue)
        XCTAssertNil(JSONValue.null.stringValue)
    }

    func testInvalidValuesThrow() {
        XCTAssertThrowsError(try JSONValue.string("abc").decodeAllowingJSONString(Int.self))
        XCTAssertThrowsError(try JSONValue.bool(true).decodeAllowingJSONString([String].self))
    }
}
