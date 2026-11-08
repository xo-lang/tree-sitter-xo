import XCTest
import SwiftTreeSitter
import TreeSitterXo

final class TreeSitterXoTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_xo())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Xo grammar")
    }
}
