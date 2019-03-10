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

public struct LocaleInformation: Codable {

    public let parentLocale: [String: String]

    public let localeIdentifiers: [String]

    public init(parentLocale: [String: String], localeIdentifiers: [String]) {
        self.parentLocale = parentLocale
        self.localeIdentifiers = localeIdentifiers
    }
}

public struct LocaleData: Codable {

    public struct ListPatterns: Codable {

        public struct ListPattern: Codable {

            enum CodingKeys: String, CodingKey {
                case two = "2"
                case start, middle, end
            }

            public let two: String
            public let start: String
            public let middle: String
            public let end: String

            public init(two: String,
                        start: String,
                        middle: String,
                        end: String) {
                self.two = two
                self.start = start
                self.middle = middle
                self.end = end
            }
        }

        public let standard: ListPattern
        public let standardNarrow: ListPattern
        public let standardShort: ListPattern
        public let or: ListPattern
        public let orNarrow: ListPattern
        public let orShort: ListPattern
        public let unit: ListPattern
        public let unitNarrow: ListPattern
        public let unitShort: ListPattern

        public init(standard: ListPattern,
                    standardNarrow: ListPattern,
                    standardShort: ListPattern,
                    or: ListPattern,
                    orNarrow: ListPattern,
                    orShort: ListPattern,
                    unit: ListPattern,
                    unitNarrow: ListPattern,
                    unitShort: ListPattern) {
            self.standard = standard
            self.standardNarrow = standardNarrow
            self.standardShort = standardShort
            self.or = or
            self.orNarrow = orNarrow
            self.orShort = orShort
            self.unit = unit
            self.unitNarrow = unitNarrow
            self.unitShort = unitShort
        }
    }

    public let localeIdentifier: String

    public let listPatterns: ListPatterns

    public init(localeIdentifier: String, listPatterns: ListPatterns) {
        self.localeIdentifier = localeIdentifier
        self.listPatterns = listPatterns
    }
}

public extension LocaleData.ListPatterns {

    public static func from(listPatterns: CLDRData.Main.ListPatterns) -> LocaleData.ListPatterns {
        return LocaleData.ListPatterns(standard: .from(listPatternType: listPatterns.standard),
                                       standardNarrow: .from(listPatternType: listPatterns.standardNarrow),
                                       standardShort: .from(listPatternType: listPatterns.standardShort),
                                       or: .from(listPatternType: listPatterns.or),
                                       orNarrow: .from(listPatternType: listPatterns.orNarrow),
                                       orShort: .from(listPatternType: listPatterns.orShort),
                                       unit: .from(listPatternType: listPatterns.unit),
                                       unitNarrow: .from(listPatternType: listPatterns.unitNarrow),
                                       unitShort: .from(listPatternType: listPatterns.unitShort))
    }
}

public extension LocaleData.ListPatterns.ListPattern {

    public static func from(listPatternType: CLDRData.Main.ListPatterns.ListPatternType) -> LocaleData.ListPatterns.ListPattern {
        return LocaleData.ListPatterns.ListPattern(two: listPatternType.two.replacingArgumentSpecifiers(),
                                                   start: listPatternType.start.replacingArgumentSpecifiers(),
                                                   middle: listPatternType.middle.replacingArgumentSpecifiers(),
                                                   end: listPatternType.end.replacingArgumentSpecifiers())
    }
}

public extension String {

    // TODO: It's late, I probably could do this in a better way
    //
    // "{0} and {1}"
    //
    //  - must become -
    //
    // "%1$@ and %2$@"
    //
    // (must increment because %$0@ is not valid)

    func replacingArgumentSpecifiers() -> String {

        var copy = self
        while copy.replaceArgumentSpecifier() { }
        return copy
    }

    mutating func replaceArgumentSpecifier() -> Bool {

        let regex = try! NSRegularExpression(pattern: "\\{([0-9]+)\\}", options: [])
        guard let result = regex.firstMatch(in: self, options: [], range: NSRange(startIndex ..< endIndex, in: self)) else { return false }


        let valueRange = Range<String.Index>(result.range(at: 1), in: self)!
        let value = Int(self[valueRange])!

        let replacement = "%\(value + 1)$@"
        let range = Range<String.Index>(result.range, in: self)!
        replaceSubrange(range, with: replacement)
        return true
    }
}

