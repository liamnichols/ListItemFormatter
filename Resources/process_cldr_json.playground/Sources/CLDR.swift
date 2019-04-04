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

public class CLDR {

    public enum Error: Swift.Error {
        case missingRootData
    }

    public let dataDirectory: URL

    private let parentLocaleMap: [String: String]

    private let allListPatterns: [String: CLDRData.Main.ListPatterns]

    private let rootListPatterns: CLDRData.Main.ListPatterns

    private let localeIds: Set<String>

    public init(dataDirectory: URL) throws {
        self.dataDirectory = dataDirectory

        parentLocaleMap = Dictionary(uniqueKeysWithValues: try CLDRData.getParentLocaleMappings(from: dataDirectory)
            .map { (CLDR.normalise($0.key), CLDR.normalise($0.value)) })

        allListPatterns = Dictionary.init(uniqueKeysWithValues: try CLDRData.getListPatterns(from: dataDirectory)
            .map { (CLDR.normalise($0.key), $0.value) })

        guard let root = allListPatterns["root"] else { throw Error.missingRootData }
        rootListPatterns = root

        localeIds = Set(allListPatterns.keys)
    }

    public func writeOutputs(to outputDirectory: URL) throws {

        // Filter down so that we only have the most common locale and aren't duplicating along the parent locale chain
        var requiredListPatterns: [String: CLDRData.Main.ListPatterns] = allListPatterns
        for localeId in localeIds {
            guard let parentLocaleId = parentLocale(for: localeId) else { continue }
            if allListPatterns[localeId] != nil, allListPatterns[localeId] == allListPatterns[parentLocaleId] {
                requiredListPatterns.removeValue(forKey: localeId)
            }
        }

        // Construct the base locale information
        let localeInformation = LocaleInformation(parentLocale: parentLocaleMap,
                                                  localeIdentifiers: requiredListPatterns.keys.sorted())

        // Construct a LocaleData object for each locale we export
        let localeDataObjects = requiredListPatterns.map { localeData(for: $0.key, using: $0.value) }

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)

        let localeInformationFile = outputDirectory.appendingPathComponent("localeInformation.plist", isDirectory: false)
        try encoder.encode(localeInformation).write(to: localeInformationFile)

        for dataObject in localeDataObjects {
            let dataObjectFile = outputDirectory.appendingPathComponent(dataObject.localeIdentifier + ".plist", isDirectory: false)
            try encoder.encode(dataObject).write(to: dataObjectFile)
        }
    }

    private func localeData(for localeIdentifier: String,
                            using listPatterns: CLDRData.Main.ListPatterns) -> LocaleData {

        return LocaleData(localeIdentifier: localeIdentifier, listPatterns: .from(listPatterns: listPatterns))
    }

    private func parentLocale(for _locale: String) -> String? {
        let locale = CLDR.normalise(_locale)
        if let mappedValue = parentLocaleMap[locale] {
            return mappedValue
        }

        var components = locale.split(separator: "_")
        components.removeLast()
        guard !components.isEmpty else { return nil }
        return components.joined(separator: "_")
    }

    private static func normalise(_ localeIdentifier: String) -> String {
        return localeIdentifier.replacingOccurrences(of: "-", with: "_")
    }
}
