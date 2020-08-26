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

class ListPatternBuilderTests: XCTestCase {

    let patterns = Format.Patterns(listPatterns: [
        "2": "{0} [2] {1}",
        "6": "{5} {4} {3} {2} {1} {0}",
        "7": "{0} {1} {2} {3} {4} {5} {6}",
        "start": "{0} [START] {1}",
        "middle": "{0} [MIDDLE] {1}",
        "end": "{0} [END] {1}"
    ])!

    func testNoItemsItems() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: [])
        XCTAssertEqual(result.string, "")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, [])
    }

    func testSinguleItem() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["ONE"])
        XCTAssertEqual(result.string, "ONE")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["ONE"])
    }

    func testFixedAmount2() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["ONE", "TWO"])
        XCTAssertEqual(result.string, "ONE [2] TWO")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["ONE", "TWO"])
    }

    func testAllPatternsUsed() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["ONE", "TWO", "THREE", "FOUR"])
        XCTAssertEqual(result.string, "ONE [START] TWO [MIDDLE] THREE [END] FOUR")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["ONE", "TWO", "THREE", "FOUR"])
    }

    func testMiddleUsedRepeatedly() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["ONE", "TWO", "THREE", "FOUR", "FIVE"])
        XCTAssertEqual(result.string, "ONE [START] TWO [MIDDLE] THREE [MIDDLE] FOUR [END] FIVE")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["ONE", "TWO", "THREE", "FOUR", "FIVE"])
    }

    func testFormatArgumentOrdering() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX"])
        XCTAssertEqual(result.string, "SIX FIVE FOUR THREE TWO ONE")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["SIX", "FIVE", "FOUR", "THREE", "TWO", "ONE"])
    }

    func testFormatArgumentWithNoOrdering() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN"])
        XCTAssertEqual(result.string, "ONE TWO THREE FOUR FIVE SIX SEVEN")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN"])
    }

    func testFormatArgumentWithUnicodeWeirdness() {

        let builder = ListPatternBuilder(patterns: patterns)
        let result = builder.build(from: ["👍🏽", "👍", "👍👎🏼", "👍👍🏽👍"])
        XCTAssertEqual(result.string, "👍🏽 [START] 👍 [MIDDLE] 👍👎🏼 [END] 👍👍🏽👍")
        XCTAssertEqual(result.itemRanges.map { result.string[$0] }, ["👍🏽", "👍", "👍👎🏼", "👍👍🏽👍"])
    }
}
