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

public extension CLDRData {

    public enum Error: Swift.Error {
        case missingData
    }

    public static func getParentLocaleMappings(from directory: URL) throws -> [String: String] {
        let fileURL = directory.appendingPathComponent("parentLocales.json")
        let fileData = try Data(contentsOf: fileURL)
        let json = try JSONDecoder().decode(CLDRData.self, from: fileData)
        return json.supplemental?.parentLocales?.parentLocale ?? [:]
    }

    private static func getListPatternsAndLocale(from fileURL: URL) throws -> (locale: String, lostPatterns: CLDRData.Main.ListPatterns) {
        let fileData = try Data(contentsOf: fileURL)
        let json = try JSONDecoder().decode(CLDRData.self, from: fileData)

        guard let main = json.main, let (key, value) = main.first, let listPatterns = value.listPatterns else { throw Error.missingData }
        return (key, listPatterns)
    }

    public static func getListPatterns(from directory: URL) throws -> [String: CLDRData.Main.ListPatterns] {
        let directoryURL = directory.appendingPathComponent("listPatterns", isDirectory: true)
        let fileManager = FileManager.default
        let keysAndValues = try fileManager.contentsOfDirectory(atPath: directoryURL.path)
            .filter { $0.hasSuffix(".json") }
            .map { directoryURL.appendingPathComponent($0) }
            .map { try getListPatternsAndLocale(from: $0) }
        return Dictionary(uniqueKeysWithValues: keysAndValues)
    }
}
