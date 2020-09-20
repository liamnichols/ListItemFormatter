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

class LocaleInformationTests: XCTestCase {

    let localeInformation = LocaleInformation(
        localeIdentifiers: [],
        parentLocale: [
            "xx_XX": "root"
        ]
    )

    func testParentLocaleLookup() {

        XCTAssertEqual(localeInformation.parentLocale(forLocaleIdentifier: ""), nil)

        XCTAssertEqual(localeInformation.parentLocale(forLocaleIdentifier: "en_GB"), "en")

        XCTAssertEqual(localeInformation.parentLocale(forLocaleIdentifier: "zh_Hant_HK"), "zh_Hant")

        XCTAssertEqual(localeInformation.parentLocale(forLocaleIdentifier: "en"), "root")

        XCTAssertEqual(localeInformation.parentLocale(forLocaleIdentifier: "xx_XX"), "root")

        XCTAssertEqual(localeInformation.parentLocale(forLocaleIdentifier: "root"), nil)
    }

    func testInheritenceSearchChain() {

        XCTAssertEqual(
            localeInformation.inheritenceSearchChain(forLocaleIdentifier: "root"),
            ["root"]
        )

        XCTAssertEqual(
            localeInformation.inheritenceSearchChain(forLocaleIdentifier: "en"),
            ["en", "root"]
        )

        XCTAssertEqual(
            localeInformation.inheritenceSearchChain(forLocaleIdentifier: "en_GB"),
            ["en_GB", "en", "root"]
        )

        XCTAssertEqual(
            localeInformation.inheritenceSearchChain(forLocaleIdentifier: "xx_XX_Xxxx"),
            ["xx_XX_Xxxx", "xx_XX", "root"]
        )
    }

    func testIdentifierNormalizer() {

        XCTAssertEqual(LocaleInformation.normalizedIdentifier(from: "en_GB"), "en_GB")
        XCTAssertEqual(LocaleInformation.normalizedIdentifier(from: "zh-Hant-HK"), "zh_Hant_HK")
    }
}
