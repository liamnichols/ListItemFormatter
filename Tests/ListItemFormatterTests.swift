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

import XCTest
@testable import ListItemFormatter

extension NSAttributedString.Key {

    static let identifier = NSAttributedString.Key("io.github.liamnichols.listitemformatter.identifier")
}

class ListItemFormatterTests: XCTestCase {

    func testBadDataTypesNotFormatted() {

        let formatter = ListItemFormatter()
        XCTAssertNil(formatter.string(for: Data()))
        XCTAssertNil(formatter.string(for: "One"))
        XCTAssertNil(formatter.string(for: 1))
        XCTAssertNil(formatter.string(for: nil))
    }

    func testNoItems() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let expected = ""
        let actual = formatter.string(from: [])
        XCTAssertEqual(actual, expected)
    }

    func testOneItem() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let expected = "Liam"
        let actual = formatter.string(from: ["Liam"])
        XCTAssertEqual(actual, expected)
    }

    func testTwoItems() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let expected = "Liam and Jack"
        let actual = formatter.string(from: ["Liam", "Jack"])
        XCTAssertEqual(actual, expected)
    }

    func testThreeItems() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let expected = "Liam, Jack, and Joe"
        let actual = formatter.string(from: ["Liam", "Jack", "Joe"])
        XCTAssertEqual(actual, expected)
    }

    func testFourItems() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let expected = "Liam, Jack, Joe, and Bill"
        let actual = formatter.string(from: ["Liam", "Jack", "Joe", "Bill"])
        XCTAssertEqual(actual, expected)
    }

    func testLocaleSwitching() {

        let formatter = ListItemFormatter()

        formatter.locale = Locale(identifier: "ar_LB")
        XCTAssertEqual(formatter.string(from: ["ليام", "ليندا", "كوكباد"]), "ليام وليندا وكوكباد")

        formatter.locale = Locale(identifier: "fr_LB")
        XCTAssertEqual(formatter.string(from: ["Liam", "Thomas", "Cookpad"]), "Liam, Thomas et Cookpad")
    }

    func testMode() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        formatter.mode = .standard
        XCTAssertEqual(formatter.string(from: ["Liam", "Thomas"]), "Liam and Thomas")

        formatter.mode = .or
        XCTAssertEqual(formatter.string(from: ["Liam", "Thomas"]), "Liam or Thomas")

        formatter.mode = .unit
        XCTAssertEqual(formatter.string(from: ["Liam", "Thomas"]), "Liam, Thomas")
    }

    func testAllLocales() {

        let formatter = ListItemFormatter()

        for identifier in Locale.availableIdentifiers {

            formatter.locale = Locale(identifier: identifier)

            let output = formatter.string(from: ["ONE", "TWO", "THREE"])
            XCTAssertTrue(output.contains("ONE"))
            XCTAssertTrue(output.contains("TWO"))
            XCTAssertTrue(output.contains("THREE"))
        }
    }

    func testNSSecureCodingConformance() {

        XCTAssertTrue(ListItemFormatter.supportsSecureCoding)
        XCTAssertTrue(ListItemFormatter.conforms(to: NSSecureCoding.self))
    }

    func testDecodedPropertiesMatchAfterEncoding() throws {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "ar_LB")
        formatter.mode = .unit
        formatter.style = .narrow

        let data = NSKeyedArchiver.archivedData(withRootObject: formatter)

        XCTAssertFalse(data.isEmpty)

        let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data) as? ListItemFormatter

        XCTAssertNotNil(unarchived)
        XCTAssertEqual(unarchived?.locale, formatter.locale)
        XCTAssertEqual(unarchived?.mode, formatter.mode)
        XCTAssertEqual(unarchived?.style, formatter.style)
    }

    func testDecodingInvalidDataFails() throws {

        let bundle = Bundle(for: ListPatternBuilderTests.self)
        let data = try Data(contentsOf: bundle.url(forResource: "ArchivedFormatter_Invalid", withExtension: "plist")!)

        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        XCTAssertNil(ListItemFormatter(coder: unarchiver))
    }

    func testDecodingValidDataSucceeds() throws {

        let bundle = Bundle(for: ListPatternBuilderTests.self)
        let data = try Data(contentsOf: bundle.url(forResource: "ArchivedFormatter_Valid", withExtension: "plist")!)

        XCTAssertNotNil(NSKeyedUnarchiver.unarchiveObject(with: data) as? ListItemFormatter)
    }

    func testNSCopyingConformance() {

        XCTAssertTrue(ListItemFormatter.conforms(to: NSCopying.self))
    }

    func testCopy() {

        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "ar_LB")
        formatter.mode = .unit
        formatter.style = .narrow

        let copy = formatter.copy() as? ListItemFormatter

        XCTAssertNotNil(copy)
        XCTAssertEqual(copy?.locale, formatter.locale)
        XCTAssertEqual(copy?.mode, formatter.mode)
        XCTAssertEqual(copy?.style, formatter.style)
    }

    func testAttributedString() {

        let formatter = ListItemFormatter()
        formatter.defaultAttributes = [.identifier: "DEFAULT"]
        formatter.itemAttributes = [.identifier: "ITEM"]

        let output = formatter.attributedString(from: ["one", "two"])
        XCTAssertNotNil(output)
        XCTAssertEqual(output.string, "one and two")

        var range = NSRange(location: NSNotFound, length: 0)

        XCTAssertEqual(output.attribute(.identifier, at: 0, effectiveRange: &range) as? String, "ITEM")
        XCTAssertEqual(range, NSRange(location: 0, length: 3))

        XCTAssertEqual(output.attribute(.identifier, at: 3, effectiveRange: &range) as? String, "DEFAULT")
        XCTAssertEqual(range, NSRange(location: 3, length: 5))

        XCTAssertEqual(output.attribute(.identifier, at: 8, effectiveRange: &range) as? String, "ITEM")
        XCTAssertEqual(range, NSRange(location: 8, length: 3))
    }

    func testFallbackValues() {

        let bundle = Bundle(for: ListItemFormatterTests.self)
        let provider = FormatProvider(bundle: bundle)
        let formatter = ListItemFormatter(formatProvider: provider)

        let string = formatter.string(from: ["ONE", "TWO", "THREE"])
        let attributedString = formatter.attributedString(from: ["ONE", "TWO", "THREE"])

        XCTAssertEqual(string, "")
        XCTAssertEqual(attributedString, NSAttributedString())
    }
}
