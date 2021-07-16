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

final class FormatProvider {

    private class CachedFormat {

        let format: Format

        init(format: Format) {
            self.format = format
        }
    }

    private let cache: NSCache<NSString, CachedFormat>

    private let bundle: Bundle

    private lazy var localeInformation: LocaleInformation = {
        return (try? LocaleInformation(bundle: bundle)) ?? LocaleInformation()
    }()

    init(bundle: Bundle = .resources) {

        cache = NSCache()
        cache.countLimit = 5

        self.bundle = bundle
    }

    func format(for locale: Locale) -> Format? {

        let cacheKey = locale.identifier as NSString
        if let object = cache.object(forKey: cacheKey) {
            return object.format
        }

        let normalizedIdentifier = LocaleInformation.normalizedIdentifier(from: locale.identifier)
        let searchChain = localeInformation.inheritenceSearchChain(forLocaleIdentifier: normalizedIdentifier)
        let localeIdentifier = searchChain.first(where: { localeInformation.localeIdentifiers.contains($0) }) ?? "root"

        guard let format = try? Format(localeIdentifier: localeIdentifier, bundle: bundle) else {
            return nil
        }

        cache.setObject(CachedFormat(format: format), forKey: cacheKey)
        return format
    }
}
