/// MIT License
///
/// Copyright (c) 2020 Liam Nichols
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

@testable import ListItemFormatter
import XCTest

final class PerformanceTests: XCTestCase {
    let items: [String] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let items = (0..<100).map({ formatter.string(from: NSNumber(value: $0))! })
        return items
    }()

    let patterns = Format.Patterns(listPatterns: [
        "2": "{0} [2] {1}",
        "6": "{5} {4} {3} {2} {1} {0}",
        "7": "{0} {1} {2} {3} {4} {5} {6}",
        "start": "{0} [START] {1}",
        "middle": "{0} [MIDDLE] {1}",
        "end": "{0} [END] {1}"
    ])!

    func testOverall() {
        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        measure {
            _ = formatter.string(from: items)
        }
    }

    func testPatternBuilder() {
        measure {
            _ = ListPatternBuilder(patterns: patterns).build(from: items)
        }
    }
}
