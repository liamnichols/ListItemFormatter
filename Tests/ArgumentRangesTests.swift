/// MIT License
///
/// Copyright (c) 2019 Liam Nichols
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import XCTest
@testable import ListItemFormatter

class ArgumentRangesTests: XCTestCase {

    func testBasicString() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "My name is {0}.", ranges: &ranges, "Liam")

        XCTAssertEqual(output, "My name is Liam.")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Liam"])
    }

    func testArgumentPositionSpecifiers() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Today, {1} and {0} present to you:", ranges: &ranges, "Liam", "Linda")

        XCTAssertEqual(output, "Today, Linda and Liam present to you:")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Linda", "Liam"])
    }

    func testDuplicatesArguments() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Hi {0}! Your name is {0}.", ranges: &ranges, "Liam")

        XCTAssertEqual(output, "Hi Liam! Your name is Liam.")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Liam", "Liam"])
    }

    func testSwiftStringIndexWeirdness() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "{0} and {1} - {2}", ranges: &ranges, "👸🏼", "👨🏾‍💻", "Test")

        XCTAssertEqual(output, "👸🏼 and 👨🏾‍💻 - Test")
        XCTAssertEqual(ranges.map({ output[$0] }), ["👸🏼", "👨🏾‍💻", "Test"])
    }

    func testArgumentRanges() throws {

        let input = """
        First String: {0}
        Third String: {2}
        Second String: {1}
        """

        var ranges: [Range<String.Index>] = []
        let output = String(format: input, ranges: &ranges, "ONE", "TWO", "THREE")

        XCTAssertFalse(output.isEmpty)
        XCTAssertEqual(ranges.map({ NSRange($0, in: output) }), [
            NSRange(location: 14, length: 3),
            NSRange(location: 32, length: 5),
            NSRange(location: 53, length: 3)
        ])
    }

    func testMoreComplicatedArgumentRanges() throws {

        let input = """
        First String: {0}
        Third String: {2}
        Second String: {1}
        """

        var ranges: [Range<String.Index>] = []
        let output = String(format: input, ranges: &ranges, "👍", "👍🏽", "👍👍👍")

        XCTAssertEqual(
            output,
            """
            First String: 👍
            Third String: 👍👍👍
            Second String: 👍🏽
            """
        )

        XCTAssertEqual(ranges.map({ NSRange($0, in: output) }), [
            NSRange(location: 14, length: 2),
            NSRange(location: 31, length: 6),
            NSRange(location: 53, length: 4)
        ])

        XCTAssertEqual(
            ranges.map({ String(output[$0]) }),
            ["👍", "👍👍👍", "👍🏽"]
        )
    }

    func testBug() throws {
        let json = #"["roro(همسات المستقبل)","َمنار منار، Alwahabi Alwahabi، و10 آخرين"]"#
        let data = try XCTUnwrap(json.data(using: .utf8))
        let array = try JSONDecoder().decode([String].self, from: data)
        XCTAssertEqual(array.count, 2)

        var ranges: [Range<String.Index>] = []
        let output = String(format: "{0}، {1}", ranges: &ranges, array.first!, array.last!)

        XCTAssertEqual(output, "roro(همسات المستقبل)، منار منار، Alwahabi Alwahabi، و10 آخرين")
        XCTAssertEqual(ranges.count, 2)
    }
}
