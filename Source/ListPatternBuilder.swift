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
        var components = [OutputComponent(string: items.removeLast(), isItem: true)]
        var pattern = patterns.end

        while let nextItem = items.popLast() {
            // Ensure the next pattern is correctly picked
            defer { pattern = items.count == 1 ? patterns.start : patterns.middle }

            // Convert the tokens into a new array of output components
            components = pattern.tokens.reduce(into: [OutputComponent]()) { result, token in
                switch token {
                case .text(let value):
                    result.append(OutputComponent(string: String(value), isItem: false))
                case .placeholder(0):
                    result.append(OutputComponent(string: nextItem, isItem: true))
                case .placeholder(1):
                    result.append(contentsOf: components)
                case .placeholder:
                    fatalError("start/middle/end patterns must only contain 2 placeholders")
                }
            }
        }

        return List(components: components, items: items)
    }
}

extension ListPatternBuilder.List {
    init(components: [ListPatternBuilder.OutputComponent], items: [String]) {
        // Create the String before we construct the ranges
        let unicodeScalars = components.reduce(into: [UnicodeScalar]()) { result, component in
            result.append(contentsOf: component.string.unicodeScalars)
        }
        let unicodeScalarView = String.UnicodeScalarView(unicodeScalars)
        let string = String(unicodeScalarView)

        // Construct the ranges
        var itemRanges: [Range<String.Index>] = []
        var offset: Int = 0
        for component in components {
            let endOffset = offset + component.string.unicodeScalars.count
            let startIndex = unicodeScalarView.index(unicodeScalarView.startIndex, offsetBy: offset)
            let endIndex = unicodeScalarView.index(unicodeScalarView.startIndex, offsetBy: endOffset)

            if component.isItem {
                itemRanges.append(startIndex ..< endIndex)
            }

            offset = endOffset
        }

        self.init(string: string, items: items, itemRanges: itemRanges)
    }
}
