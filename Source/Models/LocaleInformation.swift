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

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct LocaleInformation: Decodable {

    let localeIdentifiers: [String]

    let parentLocale: [String: String]

    init(bundle: Bundle) throws {

        let asset = try NSDataAsset.loadDataAsset(named: "localeInformation", in: bundle)
        self = try JSONDecoder().decode(LocaleInformation.self, from: asset.data)
    }

    init(localeIdentifiers: [String] = [], parentLocale: [String: String] = [:]) {

        self.localeIdentifiers = localeIdentifiers
        self.parentLocale = parentLocale
    }

    static func normalizedIdentifier(from localeIdentifier: String) -> String {
        return localeIdentifier.replacingOccurrences(of: "-", with: "_")
    }

    func parentLocale(forLocaleIdentifier localeIdentifier: String) -> String? {

        guard !localeIdentifier.isEmpty && localeIdentifier != "root" else {
            return nil
        }

        if let override = parentLocale[localeIdentifier] {
            return override
        }

        var components = localeIdentifier.split(separator: "_")
        components.removeLast()

        if components.isEmpty {
            return "root"
        }

        return components.joined(separator: "_")
    }

    // https://unicode.org/reports/tr35/#Locale_Inheritance
    func inheritenceSearchChain(forLocaleIdentifier localeIdentifier: String) -> [String] {

        var searchChain = [localeIdentifier]
        while let parent = parentLocale(forLocaleIdentifier: searchChain.last!) {
            searchChain.append(parent)
        }
        return searchChain
    }
}
