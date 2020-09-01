@testable import ListItemFormatter
import XCTest

final class PerformanceTests: XCTestCase {
    let items: [String] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let items = (0..<100).map({ formatter.string(from: NSNumber(value: $0))! })
        return items
    }()

    let patterns = Format.Patterns(listPatterns: [
        "2": "{0} [2] {1}",
        "6": "{5} {4} {3} {2} {1} {0}",
        "7": "{0} {1} {2} {3} {4} {5} {6}",
        "start": "{0} [START] {1}",
        "middle": "{0} [MIDDLE] {1}",
        "end": "{0} [END] {1}"
    ])!

    func testOverall() {
        let formatter = ListItemFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        measure {
            _ = formatter.string(from: items)
        }
    }

    func testPatternBuilder() {
        measure {
            _ = ListPatternBuilder(patterns: patterns).build(from: items)
        }
    }
}
