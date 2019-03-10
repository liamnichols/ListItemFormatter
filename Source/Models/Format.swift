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

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


struct Format: Decodable {

    class Patterns: Decodable {

        internal let start: String

        internal let middle: String

        internal let end: String

        internal let fixed: [Int: String]

        init?(listPatterns: [String: String]) {

            var _start: String? = nil
            var _middle: String? = nil
            var _end: String? = nil
            var fixed: [Int: String] = [:]

            for (key, value) in listPatterns {
                if let number = Int(key), number > 0 {
                    fixed[number] = value
                } else if key == "start" {
                    _start = value
                } else if key == "middle" {
                    _middle = value
                } else if key == "end" {
                    _end = value
                } else {
                    return nil
                }
            }

            guard let start = _start, let middle = _middle, let end = _end else { return nil }
            guard start.argCount() == 2, middle.argCount() == 2, end.argCount() == 2 else { return nil }
            for (count, string) in fixed {
                guard string.argCount() == count else { return nil }
            }

            self.start = start
            self.middle = middle
            self.end = end
            self.fixed = fixed
        }
    }

    let localeIdentifier: String

    let listPatterns: [String: [String: String]]

    init(localeIdentifier: String, bundle: Bundle = .main) throws {
        let asset = try NSDataAsset.loadDataAsset(named: localeIdentifier, in: bundle)
        self = try PropertyListDecoder().decode(Format.self, from: asset.data)
    }

    func getPatterns(for style: ListItemFormatter.Style, mode: ListItemFormatter.Mode) -> Patterns? {
        let key = mode.keyPrefix + style.keySuffix
        return listPatterns[key].flatMap { Patterns(listPatterns: $0) }
    }
}

private extension ListItemFormatter.Mode {

    var keyPrefix: String {
        switch self {
        case .standard:
            return "standard"
        case .or:
            return "or"
        case .unit:
            return "unit"
        }
    }
}

private extension ListItemFormatter.Style {

    var keySuffix: String {
        switch self {
        case .default:
            return ""
        case .narrow:
            return "Narrow"
        case .short:
            return "Short"
        }
    }
}

private extension String {

    func argCount() -> Int {
        let regex = try? NSRegularExpression(pattern: "%([0-9]+\\$)?@", options: [])
        return regex?.numberOfMatches(in: self, options: [], range: NSRange(startIndex ..< endIndex, in: self)) ?? 0
    }
}
