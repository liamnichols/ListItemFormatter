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

class FormatTests: XCTestCase {

    func testWrongBundleThrows() {

        XCTAssertThrowsError(try Format(localeIdentifier: "", bundle: Bundle(for: FormatTests.self)))
    }

    func testPatternArgumentCounts() {

        XCTAssertNotNil(Format.Patterns(listPatterns: [
            "2": "{0} and {1}",
            "3": "{0} and {1} and {2}",
            "start": "{0}, {1}",
            "middle": "{0}, {1}",
            "end": "{0} and {1}"
        ]))

        XCTAssertNil(Format.Patterns(listPatterns: [
            "3": "{0}",
            "start": "{0}, {1}",
            "middle": "{0}, {1}",
            "end": "{0} and {1}"
        ]))

        XCTAssertNil(Format.Patterns(listPatterns: [
            "3": "{0} and {1} and {2}",
            "start": "{0}",
            "middle": "{0}, {1}",
            "end": "{0} and {1}"
        ]))

        XCTAssertNil(Format.Patterns(listPatterns: [
            "3": "{0} and {1} and {2}",
            "start": "{0}, {1}",
            "middle": "{0}, {1}",
            "end": ""
        ]))
    }

    func testMissingPatterns() {

        XCTAssertNil(Format.Patterns(listPatterns: [:]))
    }
}
