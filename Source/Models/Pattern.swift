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

import Foundation

struct Pattern: ExpressibleByStringLiteral {
    enum Token: Equatable {
        case text(Substring)
        case placeholder(Int)

        var isPlaceholder: Bool {
            guard case .placeholder = self else { return false }
            return true
        }
    }

    let base: String
    let tokens: [Token]

    init(stringLiteral value: StringLiteralType) {
        self.init(base: value)
    }

    init(base: String) {
        var tokens: [Token] = []

        let regex = try! NSRegularExpression(pattern: "\\{([0-9]+)\\}")
        var startIndex = base.startIndex
        regex.enumerateMatches(in: base, range: NSRange(base.startIndex ..< base.endIndex, in: base)) { result, _, _ in
            let result = result!
            let placeholderRange = Range(result.range(at: 0), in: base)!

            // Up until this point, it's text
            let leadingTextRange = startIndex ..< placeholderRange.lowerBound
            tokens.append(.text(base[leadingTextRange]))

            // Track the placeholder
            let indexRange = Range(result.range(at: 1), in: base)!
            let index = Int(base[indexRange])!
            tokens.append(.placeholder(index))

            // Move on
            startIndex = placeholderRange.upperBound
        }

        // Close up
        if startIndex < base.endIndex {
            let range = startIndex ..< base.endIndex
            tokens.append(.text(base[range]))
        }

        // Hold
        self.base = base
        self.tokens = tokens
    }

    func argCount() -> Int {
        tokens.filter(\.isPlaceholder).count
    }
}
