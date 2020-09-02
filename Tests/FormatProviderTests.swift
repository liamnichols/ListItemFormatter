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

class FormatProviderTests: XCTestCase {

    func testLoadingFormat() {

        let provider = FormatProvider()
        let format = provider.format(for: Locale(identifier: "en_CA"))
        XCTAssertEqual(format?.localeIdentifier, "en_CA")
    }

    func testInvalidLocaleReturnsRoot() {

        let provider = FormatProvider()
        let format = provider.format(for: Locale(identifier: ""))
        XCTAssertEqual(format?.localeIdentifier, "root")
    }

    func testParentLocaleResolves() {

        let provider = FormatProvider()
        let format = provider.format(for: Locale(identifier: "ar_GB"))
        XCTAssertEqual(format?.localeIdentifier, "ar")
    }

    func testExplicitParentLocaleResolves() {

        let provider = FormatProvider()
        let format = provider.format(for: Locale(identifier: "uz_Arab"))
        XCTAssertEqual(format?.localeIdentifier, "root")
    }

    func testNormalizedLocaleIdentifiers() {

        let provider = FormatProvider()
        let format = provider.format(for: Locale(identifier: "zh_Hant-HK"))
        XCTAssertEqual(format?.localeIdentifier, "zh_Hant_HK")
    }

    func testInvalidLocaleReturnsNil() {

        let provider = FormatProvider(bundle: Bundle(for: FormatProviderTests.self))
        let format = provider.format(for: Locale(identifier: ""))
        XCTAssertNil(format)
    }
}

class FormatProviderPatternTests: XCTestCase {

    func testAllPatternsInBundle() throws {

        let bundle = Bundle(for: ListItemFormatter.self)

        let localeInformation = try LocaleInformation(bundle: bundle)
        let provider = FormatProvider(bundle: bundle)

        XCTAssertFalse(localeInformation.localeIdentifiers.isEmpty)

        let combinations: [(ListItemFormatter.Mode, ListItemFormatter.Style)] = [
            (.standard, .default),
            (.standard, .short),
            (.standard, .narrow),
            (.or, .default),
            (.or, .short),
            (.or, .narrow),
            (.unit, .default),
            (.unit, .short),
            (.unit, .narrow),
        ]

        for identifier in localeInformation.localeIdentifiers {
            for (mode, style) in combinations {

                let locale = Locale(identifier: identifier)
                let format = provider.format(for: locale)
                let patterns = format?.getPatterns(for: style, mode: mode)

                XCTAssertNotNil(format)
                XCTAssertNotNil(patterns)
            }
        }
    }
}
