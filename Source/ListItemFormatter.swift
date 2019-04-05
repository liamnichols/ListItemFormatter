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
///  English) versus "lundi, mardi, vendredi et samedi" (in French).
@objc(LNListItemFormatter) public class ListItemFormatter: Formatter, NSSecureCoding {

    /// The following constants specify predefined format modes for list items.
    ///
    /// The mode is used in conjuction with the `Style` to pick the most appropriate
    ///  set of patterns used by the formatter. You can read more about the patterns
    ///  in the [Unicode documentation](http://unicode.org/reports/tr35/tr35-general.html#ListPatterns).
    @objc(LNListItemFormatterMode) public enum Mode: Int {

        /// Mode for a typical 'and' list of arbitrary placeholders.
        case standard

        /// Mode for a typical 'or' list of arbitrary placeholders.
        case or

        /// A format mode suitable for arbitrary placeholder units with no mode (i.e
        ///  measurement units).
        case unit
    }

    /// The style is used in conjuction with the `Mode` to pick the most appropriate
    ///  set of patterns used by the formatter. You can read more about the patterns
    ///  in the [Unicode documentation](http://unicode.org/reports/tr35/tr35-general.html#ListPatterns).
    @objc(LNListItemFormatterStyle) public enum Style: Int {

        /// A style suitable for regular values and wide units.
        case `default`

        /// A shorter style typically suitable for short or abbreviated placeholder
        ///  values.
        case short

        /// The narrowest style where space on the screen is very limited. This style
        ///  will only have an effect when used with the `.unit` mode.
        case narrow
    }

    /// The format mode of the receiver.
    ///
    /// The default value is set to `.standard`.
    @objc public var mode: Mode

    /// The format style of the reciever.
    ///
    /// The default value is set to `.default`.
    @objc public var style: Style

    /// The locale for the receiver.
    ///
    /// The default value is set to `Locale.autoupdatingCurrent`.
    @objc public var locale: Locale

    /// The default text attributes used to display the output string.
    ///
    /// The value of this property is used by the receiver to produce the output
    ///  `NSAttributedString` object of `ListItemFormatter.attributedString(from:)`.
    ///
    /// The default value is an empty dictionary.
    @objc public var defaultAttributes: [NSAttributedString.Key: Any] = [:]

    /// The item specific attributes used to display the list items within the output
    ///  string.
    ///
    /// The value of this property is used by the receiver to produce the output
    ///  `NSAttributedString` object of `ListItemFormatter.attributedString(from:)`,
    ///  specifically by applying these attributes only to the items within the `list`
    ///  array. These attributes are applied on top of `defaultAttributes`.
    ///
    /// The default value of this property is an empty dictionary.
    @objc public var itemAttributes: [NSAttributedString.Key: Any] = [:]

    /// Returns a string representation of the given list items formatted using the
    /// receiver’s current settings.
    ///
    /// - Parameter list: The list items to be formatted into a localised, human
    ///  readable list.
    ///
    /// - Returns: A string representation of `list` formatted using the receiver’s
    ///  current settings.
    @objc public func string(from list: [String]) -> String {
        return string(for: list) ?? ""
    }

    /// Returns an attributed strign representation of the given list items formatted
    ///  using the receiver's current settings.
    ///
    /// The receiver uses the values set in its `defaultAttributes` and
    ///  `itemAttributes` properties by first applying the default attributes to the
    ///  entire string and then adding `itemAttributes` to the range of each item
    ///  within `list`. This means that attributes in the default attributes will
    ///  first be applied to the `list` item ranges and then will be overwritten with
    ///  values from the item specific attributes if they conflict. This means that
    ///  you do not need to set the same attributes twice.
    ///
    /// - Parameter list: The list items to be formatted into an attributed,
    ///  localised, human readable list.
    ///
    /// - Returns: An attributed string representation of `list` formatted using the
    ///  receiver’s current settings.
    @objc public func attributedString(from list: [String]) -> NSAttributedString {

        return attributedString(for: list, withDefaultAttributes: defaultAttributes) ?? NSAttributedString()
    }

    public convenience override init() {
        self.init(formatProvider: FormatProvider())
    }

    // MARK: - Internal Interface

    let formatProvider: FormatProvider

    init(formatProvider: FormatProvider) {
        self.formatProvider = formatProvider
        self.mode = .standard
        self.style = .default
        self.locale = .autoupdatingCurrent
        super.init()
    }

    // MARK: - NSSecureCoding

    public static let supportsSecureCoding: Bool = true

    required public init?(coder aDecoder: NSCoder) {

        guard let mode = Mode(rawValue: aDecoder.decodeInteger(forKey: "mode")),
            let style = Style(rawValue: aDecoder.decodeInteger(forKey: "style")),
            let locale = (aDecoder.decodeObject(of: NSLocale.self, forKey: "locale") as Locale?) else { return nil }

        self.formatProvider = FormatProvider()
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
