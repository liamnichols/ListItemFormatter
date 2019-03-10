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

extension String {

    init(format: String, ranges: inout [Range<String.Index>], _ args: CVarArg...) {
        self.init(format: format, ranges: &ranges, arguments: args)
    }

    init(format: String, ranges: inout [Range<String.Index>], arguments: [CVarArg]) {
        self.init(format: format, locale: nil, ranges: &ranges, arguments: arguments)
    }

    init(format: String, locale: Locale?, ranges: inout [Range<String.Index>], _ args: CVarArg...) {
        self.init(format: format, locale: locale, ranges: &ranges, arguments: args)
    }

    init(format _format: String, locale: Locale?, ranges: inout [Range<String.Index>], arguments: [CVarArg]) {
        self.init(format: _format, locale: locale, arguments: arguments)

        let format = _format as NSString
        var nextUnassignedIndex: Int = 0
        var locationOffset: String.IndexDistance = 0

        let pattern = "%(([0-9]+)\\$)?(\\.[0-9]+)?([@aAcCdDeEfFgGopsSuUxX]|ld|lu|lx|zx)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: format.length)
        regex.enumerateMatches(in: _format, options: [], range: range) { _match, _, stop in
            let match = _match!
            let range = match.range

            let argIndex: Int
            let indexValueRange = match.range(at: 2)
            if indexValueRange.location != NSNotFound,
                let index = Int(format.substring(with: indexValueRange)) {
                argIndex = index - 1
            } else {
                argIndex = nextUnassignedIndex
                nextUnassignedIndex += 1
            }

            let argValueFormat: NSString
            let indexRange = match.range(at: 1)
            if indexRange.location != NSNotFound {
                let placeholder = format.substring(with: range) as NSString
                let indexString = format.substring(with: indexRange)
                argValueFormat = placeholder.replacingOccurrences(of: indexString, with: "") as NSString
            } else {
                argValueFormat = format.substring(with: range) as NSString
            }

            let argValue = NSString(format: argValueFormat, locale: locale, arguments[argIndex])
            let argRange = NSRange(location: range.location + locationOffset, length: argValue.length)

            ranges.append(Range(argRange, in: self)!)

            locationOffset += (argValue.length - range.length)
        }
    }
}
