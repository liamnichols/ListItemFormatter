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

public struct CLDRData: Decodable, Equatable {

    public struct Supplemental: Decodable, Equatable {

        public struct ParentLocales: Decodable, Equatable {

            public let parentLocale: [String: String]?
        }

        public let parentLocales: ParentLocales?
    }

    public struct Main: Decodable, Equatable {

        public struct ListPatterns: Decodable, Equatable {

            public enum CodingKeys: String, CodingKey {
                case standard = "listPattern-type-standard"
                case standardNarrow = "listPattern-type-standard-narrow"
                case standardShort = "listPattern-type-standard-short"
                case or = "listPattern-type-or"
                case orNarrow = "listPattern-type-or-narrow"
                case orShort = "listPattern-type-or-short"
                case unit = "listPattern-type-unit"
                case unitNarrow = "listPattern-type-unit-narrow"
                case unitShort = "listPattern-type-unit-short"
            }

            public struct ListPatternType: Decodable, Equatable {

                enum CodingKeys: String, CodingKey {
                    case two = "2"
                    case start, middle, end
                }

                public let two: String

                public let start: String

                public let middle: String

                public let end: String
            }

            public let standard: ListPatternType

            public let standardNarrow: ListPatternType

            public let standardShort: ListPatternType

            public let or: ListPatternType

            public let orNarrow: ListPatternType

            public let orShort: ListPatternType

            public let unit: ListPatternType

            public let unitNarrow: ListPatternType

            public let unitShort: ListPatternType
        }

        public let listPatterns: ListPatterns?
    }

    public let supplemental: Supplemental?

    public let main: [String: Main]?
}
