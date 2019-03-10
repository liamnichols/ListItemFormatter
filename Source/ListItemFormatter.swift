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

/// ListItemFormatter can be used to format variable-length lists of things in a
///  locale-sensitive manner, such as "Monday, Tuesday, Friday, and Saturday" (in
///  English) versus "lundi, mardi, vendredi et samedi" (in French)
@objc(LNListItemFormatter) public class ListItemFormatter: Formatter, NSSecureCoding {

    /// TBC
    @objc(LNListItemFormatterMode) public enum Mode: Int {
        case standard, or, unit
    }

    /// TBC
    @objc(LNListItemFormatterStyle) public enum Style: Int {
        case `default`, narrow, short
    }

    /// TBC
    @objc public var mode: Mode

    /// TBC
    @objc public var style: Style

    /// TBC
    @objc public var locale: Locale

    /// TBC
    @objc public var defaultAttributes: [NSAttributedString.Key: Any] = [:]

    /// TBC
    @objc public var itemAttributes: [NSAttributedString.Key: Any] = [:]

    /// TBC
    ///
    /// - Parameter list: TBC
    /// - Returns: TBC
    @objc public func string(from list: [String]) -> String? {
        return string(for: list)
    }

    /// TBC
    ///
    /// - Parameter list: TBC
    /// - Returns: TBC
    @objc public func attributedString(from list: [String]) -> NSAttributedString? {

        return attributedString(for: list, withDefaultAttributes: defaultAttributes)
    }

    private let formatProvider = FormatProvider()

    public override init() {
        mode = .standard
        style = .default
        locale = .autoupdatingCurrent
        super.init()
    }

    // MARK: - NSSecureCoding

    public static let supportsSecureCoding: Bool = true

    required public init?(coder aDecoder: NSCoder) {

        guard let mode = Mode(rawValue: aDecoder.decodeInteger(forKey: "mode")),
            let style = Style(rawValue: aDecoder.decodeInteger(forKey: "style")),
            let locale = (aDecoder.decodeObject(of: NSLocale.self, forKey: "locale") as Locale?) else { return nil }

        self.mode = mode
        self.style = style
        self.locale = locale

        super.init(coder: aDecoder)
    }

    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(mode.rawValue, forKey: "mode")
        aCoder.encode(style.rawValue, forKey: "style")
        aCoder.encode(locale, forKey: "locale")
    }

    // MARK: - NSFormatter

    public override func string(for obj: Any?) -> String? {

        guard let obj = obj else { return nil }
        return attributedString(for: obj, withDefaultAttributes: nil)?.string
    }

    public override func attributedString(for obj: Any,
                                          withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {

        guard let items = obj as? [String],
            let format = formatProvider.format(for: locale),
            let patterns = format.getPatterns(for: style, mode: mode) else { return nil }

        let builder = ListPatternBuilder(patterns: patterns)
        let list = builder.build(from: items)

        let attributedString = NSMutableAttributedString(string: list.string, attributes: attrs)
        list.itemRanges.forEach { attributedString.addAttributes(itemAttributes, range: NSRange($0, in: list.string)) }
        return attributedString
    }
}
