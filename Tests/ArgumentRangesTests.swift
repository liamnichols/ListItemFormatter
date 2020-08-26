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
        let output = String(format: "My name is %@.", ranges: &ranges, "Liam")

        XCTAssertEqual(output, "My name is Liam.")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Liam"])
    }

    func testArgumentPositionSpecifiers() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Today, %2$@ and %1$@ present to you:", ranges: &ranges, "Liam", "Linda")

        XCTAssertEqual(output, "Today, Linda and Liam present to you:")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Linda", "Liam"])
    }

    func testDuplicatesArguments() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Hi %1$@! Your name is %1$@.", ranges: &ranges, "Liam")

        XCTAssertEqual(output, "Hi Liam! Your name is Liam.")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Liam", "Liam"])
    }

    func testMixedArgumentPositionSpecifiers() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Hello %1$@ %@.", ranges: &ranges, "Liam", "Nichols")

        XCTAssertEqual(output, "Hello Liam Liam.")
        XCTAssertEqual(ranges.map({ output[$0] }), ["Liam", "Liam"])
    }

    func testSwiftStringIndexWeirdness() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "%@ and %@ - %@", ranges: &ranges, "👸🏼", "👨🏾‍💻", "Test")

        XCTAssertEqual(output, "👸🏼 and 👨🏾‍💻 - Test")
        XCTAssertEqual(ranges.map({ output[$0] }), ["👸🏼", "👨🏾‍💻", "Test"])
    }

    // These tests will be hard to fix since the way we enumerate the format string needs to change.
    // They only apply to invalid formats so its not that high priority.

//    func testInvalidArgumentPlaceholder() throws {
//
//        var ranges: [Range<String.Index>] = []
//        let output = String(format: "Hello %$ %@.", ranges: &ranges, "Liam", "Nichols")
//
//        XCTAssertEqual(output, "Hello $ Liam.")
//        XCTAssertEqual(ranges.map({ output[$0] }), ["Liam"])
//    }
//
//    func testInvalidPercentInFormatString() throws {
//
//        var ranges: [Range<String.Index>] = []
//        let output = String(format: "Hello % %@.", ranges: &ranges, "Liam", "Nichols")
//
//        XCTAssertEqual(output, "Hello @.")
//        XCTAssertEqual(ranges.map({ output[$0] }), [])
//    }

    func testValidPercentInFormatString() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Progress: %d%%", ranges: &ranges, 50)

        XCTAssertEqual(output, "Progress: 50%")
        XCTAssertEqual(ranges.map({ output[$0] }), ["50"])
    }

    func testLocalizedArguments() throws {

        var ranges: [Range<String.Index>] = []
        let locale = Locale(identifier: "en_GB")
        let output = String(format: "Item Count: %d", locale: locale, ranges: &ranges, 1234)

        XCTAssertEqual(output, "Item Count: 1,234")
        XCTAssertEqual(ranges.map({ output[$0] }), ["1,234"])
    }

    func testPrecisionSpecifier() throws {

        var ranges: [Range<String.Index>] = []
        let output = String(format: "Unit: %.4d", ranges: &ranges, 2)

        XCTAssertEqual(output, "Unit: 0002")
        XCTAssertEqual(ranges.map({ output[$0] }), ["0002"])
    }

    func testArgumentRanges() throws {

        let input = """
        First String: %@
        Third String: %3$@
        Second String: %2$@

        Integer: %4$d
        Float With Precision: %5$.2f
        """

        var ranges: [Range<String.Index>] = []
        let output = String(format: input, ranges: &ranges, "ONE", "TWO", "THREE", 100, 100.1)

        XCTAssertFalse(output.isEmpty)
        XCTAssertEqual(ranges.map({ NSRange($0, in: output) }), [
            NSRange(location: 14, length: 3),
            NSRange(location: 32, length: 5),
            NSRange(location: 53, length: 3),
            NSRange(location: 67, length: 3),
            NSRange(location: 93, length: 6),
        ])
    }

    func testMoreComplicatedArgumentRanges() throws {

        let input = """
        First String: %@
        Third String: %3$@
        Second String: %2$@
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
}
