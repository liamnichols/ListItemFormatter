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

import Foundation

/// https://www.unicode.org/reports/tr35/tr35-53/tr35-general.html#ListPatterns
class ListPatternBuilder {

    struct List {

        let string: String

        let items: [String]

        let itemRanges: [Range<String.Index>]
    }

    let patterns: Format.Patterns

    init(patterns: Format.Patterns) {
        self.patterns = patterns
    }

    func build(from items: [String]) -> List {

        if let format = patterns.fixed[items.count] {
            return listByUsing(fixedFormat: format, for: items)
        }

        if items.isEmpty {
            return List(string: "", items: [], itemRanges: [])
        }

        if items.count == 1, let item = items.first {
            return List(string: item, items: [item], itemRanges: [item.startIndex ..< item.endIndex])
        }

        return listByUsingStartMiddleAndEndFormat(between: items)
    }

    private func listByUsing(fixedFormat format: String, for items: [String]) -> List {

        var ranges: [Range<String.Index>] = []
        return List(string: String(format: format, ranges: &ranges, arguments: items),
                    items: items,
                    itemRanges: ranges)
    }

    private func listByUsingStartMiddleAndEndFormat(between items: [String]) -> List {

        var items = items
        var string = items.removeLast()
        var itemRanges = [(string.startIndex ..< string.endIndex).sameRange(in: string.utf16)!]
        var remainingItems = items
        var nextFormat = patterns.end

        while !remainingItems.isEmpty {

            let nextItem = remainingItems.removeLast()
            var ranges: [Range<String.Index>] = []
            let formatted = String(format: nextFormat, ranges: &ranges, nextItem, string)

            let formattedUtf16 = formatted.utf16
            let itemRange = ranges.first(where: { formatted[$0] == nextItem })!.sameRange(in: formattedUtf16)!
            let stringRange = ranges.first(where: { formatted[$0] == string })!.sameRange(in: formattedUtf16)!

            let offset = formattedUtf16.distance(from: formattedUtf16.startIndex, to: stringRange.lowerBound)
            itemRanges = itemRanges.map {
                formattedUtf16.index($0.lowerBound, offsetBy: offset) ..< formattedUtf16.index($0.upperBound, offsetBy: offset)
            }

            string = formatted
            itemRanges.insert(itemRange, at: 0)
            nextFormat = remainingItems.count == 1 ? patterns.start : patterns.middle
        }

        return List(string: string,
                    items: items,
                    itemRanges: itemRanges.map({ $0.sameRange(in: string)! }))
    }
}

extension Range where Bound == String.Index {

    func sameRange(in utf16: String.UTF16View) -> Range<String.UTF16View.Index>? {

        guard let lowerBound = lowerBound.samePosition(in: utf16),
            let upperBound = upperBound.samePosition(in: utf16) else { return nil }
        return lowerBound ..< upperBound
    }
}

extension Range where Bound == String.UTF16View.Index {

    func sameRange(in string: String) -> Range<String.Index>? {

        guard let lowerBound = lowerBound.samePosition(in: string),
            let upperBound = upperBound.samePosition(in: string) else { return nil }
        return lowerBound ..< upperBound
    }
}
