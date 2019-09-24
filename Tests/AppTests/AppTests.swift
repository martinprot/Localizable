@testable import App
import Dispatch
import XCTest

final class CSVDocumentTests: XCTestCase {
	
	let csvString = """
	KEY (don’t edit this column);infos;EN;FR;ES;IT
	/* General */;;;;;
	Ok;;Ok;Ok;Ok;Ok
	CellWithSemiColon;;\"Hey; you\";\"Salut; toi\";\"Ola; tu\";\"Ola; ti\"
	CellWithColon;;Hey, you;Salut, toi;Ola, tu;Ola, ti
	CellWithQuote;;\"Say \"\"Hello\"\"\";\"Dit \"\"Bonjour\"\"\";\"Dice \"\"Ola\"\"\";\"Dicho \"\"Buenjourno\"\"\"
	;;;;;
	CellWithReturn;;\"Oops
	returned\";\"Oups
	saut de ligne\";\"¡Ups!
	tototo\";\"Oops
	tititi\"
	"""
	
	func openCSV(named: String) -> String? {
		let bundle = Bundle(for: CSVDocumentTests.self)
		guard let csvDataPath = bundle.path(forResource: named, ofType: nil),
			  let data = try? Data(contentsOf: URL(fileURLWithPath: csvDataPath))
		else {
			return .none
		}
		return String(data: data, encoding: .utf8)
	}
	
    func testCSVParser() throws {
		do {
			let parser = CSVParser(csvData: self.csvString)
			let lines = try parser.parse()
			XCTAssert(lines.count == 8, "Lines should count 8 elements. Counting \(lines.count)")
			let checks: [(Int, Int, String)] = [
				(2, 0, "Ok"),
				(3, 2, "Hey; you"),
				(4, 3, "Salut, toi"),
				(5, 3, "Dit \"Bonjour\""),
				(7, 2, "Oops\nreturned"),
			]
			checks.forEach { check in
				guard lines.count > check.0, lines[check.0].count > check.1
				else {
					return XCTAssert(false, "Wrong number of lines or colomns")
				}
				let word = lines[check.0][check.1]
				XCTAssert(word == check.2, "This line should be \(check.2). Got: \(word)")
			}
		}
		catch {
			XCTAssert(false, "\(error)")
		}
    }
	
	func testLocalizeDocument() throws {
		do {
			let parser = CSVParser(csvData: self.csvString)
			let lines = try parser.parse()
			let documentParser = LocalizeDocument(csvLines: lines)
			let document = try documentParser.parseDocument()
			zip(document.languages, ["EN", "FR", "ES", "IT"]).forEach { tuple in
				let (lang, str) = tuple
				XCTAssert(lang.code == str.lowercased(), "Languages should be: EN;FR;ES;IT. Found '\(str)'")
			}
			let FR = Language(code: "fr")!
			
			guard let frenchEntries = document.entries[FR] else {
				return XCTAssert(false, "No entry found for FR")
			}
			
			switch frenchEntries[0] {
			case .comment(let string):
				XCTAssert(string == "General", "first line should be a comment saying 'general', not '\(string)'")
			default:
				XCTAssert(false, "first line should be a comment")
			}
			switch frenchEntries[4] {
			case .translation(let key, let frenchTr):
				XCTAssert(key == "CellWithQuote", "this line should have 'CellWithQuote' key, not '\(key)'")
				XCTAssert(frenchTr == "Dit \\\"Bonjour\\\"", "this line should have 'Dit \\\"Bonjour\\\"' french translation, not '\(frenchTr)'")
			default:
				XCTAssert(false, "first line should be a translation")
			}
			switch frenchEntries[5] {
			case .blankLine:
				break
			default:
				XCTAssert(false, "this line should be blank")
			}
		}
		catch {
			XCTAssert(false, "\(error)")
		}
	}

    static let allTests = [
        ("testCSVParser", testCSVParser)
    ]
}
