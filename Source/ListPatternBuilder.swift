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

    struct OutputComponent {

        let string: String

        let isItem: Bool
    }

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

    private func listByUsing(fixedFormat format: Pattern, for items: [String]) -> List {
        precondition(format.placeholderCount == items.count)

        let components = format.tokens.reduce(into: [OutputComponent]()) { result, token in
            switch token {
            case .text(let value):
                result.append(OutputComponent(string: String(value), isItem: false))
            case .placeholder(let index):
                result.append(OutputComponent(string: items[index], isItem: true))
            }
        }

        return List(components: components, items: items)
    }

    private func listByUsingStartMiddleAndEndFormat(between items: [String]) -> List {

        var items = items
        var string = items.removeLast()
        var itemRanges = [string.startIndex ..< string.endIndex]
        var remainingItems = items
        var nextFormat = patterns.end

        while !remainingItems.isEmpty {

            let nextItem = remainingItems.removeLast()
            var ranges: [Range<String.Index>] = []
            let formatted = String(format: nextFormat.base, ranges: &ranges, nextItem, string)

            let itemRange = ranges.first(where: { formatted[$0] == nextItem })!
            let stringRange = ranges.first(where: { formatted[$0] == string })!

            let baseIndex = stringRange.lowerBound.samePosition(in: formatted.unicodeScalars)!
            itemRanges = itemRanges.map {
                let startIndex = formatted.unicodeScalars.index(baseIndex, offsetBy: string.unicodeScalars.distance(from: string.unicodeScalars.startIndex, to: $0.lowerBound))
                let endIndex = formatted.unicodeScalars.index(baseIndex, offsetBy: string.unicodeScalars.distance(from: string.unicodeScalars.startIndex, to: $0.upperBound))
                return startIndex ..< endIndex
            }

            string = formatted
            itemRanges.insert(itemRange, at: 0)
            nextFormat = remainingItems.count == 1 ? patterns.start : patterns.middle
        }

        return List(string: string,
                    items: items,
                    itemRanges: itemRanges)
    }
}

extension ListPatternBuilder.List {
    init(components: [ListPatternBuilder.OutputComponent], items: [String]) {
        // Create the String before we construct the ranges
        let unicodeScalars = components.reduce(into: [UnicodeScalar]()) { result, component in
            result.append(contentsOf: component.string.unicodeScalars)
        }
        let string = String(String.UnicodeScalarView(unicodeScalars))

        // Construct the ranges
        var itemRanges: [Range<String.Index>] = []
        var offset: Int = 0
        for component in components {
            let startOffset = offset
            let endOffset = offset + component.string.unicodeScalars.count

            if component.isItem {
                itemRanges.append(String.Index(utf16Offset: startOffset, in: string) ..< String.Index(utf16Offset: endOffset, in: string))
            }

            offset = endOffset
        }

        self.init(string: string, items: items, itemRanges: itemRanges)
    }
}
