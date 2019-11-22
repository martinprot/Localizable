//
//  LocalizeDocument.swift
//  App
//
//  Created by Martin Prot on 23/03/2018.
//

import Foundation

struct LocalizeDocument {
	
	enum ParseError: Error {
		case noLangTitle
		case cannotReadComment(Int)
	}
	
	let commentRegex = try! NSRegularExpression(pattern: "^(?:(?:\\/\\/)|(?:\\/\\*+))\\s*(.+?)\\s*(?:\\*+\\/)?$", options: .anchorsMatchLines)
	
	let csvLines: [[String]]
	
	func parseDocument() throws -> Document {
		guard let firstLine = csvLines.first else { return .empty }

        // retrieving the language list (the first line, except the first column, wich is the key)
		let languages: [Language] = firstLine.dropFirst().compactMap { cell in
			let trimmedCell = cell.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
			return Language(code: trimmedCell)
		}
		if languages.count == 0 {
			throw ParseError.noLangTitle
		}
		
		// Preparing the entries dictionary
		var entries: [Language: [Entry]] = languages.reduce(into: [:]) { dic, lang in
			dic[lang] = []
		}
		
		var lineNumber: Int = 0
		try csvLines.dropFirst().forEach { columns in
			lineNumber += 1
			guard let key = columns.first?.trimmingCharacters(in: .whitespacesAndNewlines)
			else { return }
			
			// Here, blank line
			if key.count == 0 {
				languages.forEach { entries[$0]?.append(.blankLine) }
			}
			// Here, comment line
			else if let match = self.commentRegex.firstMatch(in: key, options: [], range: NSRange(location: 0, length: key.count)) {
				if let range = Range(match.range(at: 1), in: key) {
					let commentString = String(key[range])
					languages.forEach { entries[$0]?.append(.comment(commentString)) }
				}
				else {
					throw ParseError.cannotReadComment(lineNumber)
				}
			}
			// Here, real key with translations
			else {
				zip(firstLine.dropFirst(), columns.dropFirst()).forEach { code, cell in
					guard let language = Language(code: code) else { return }
					let escapedCell = cell.replacingOccurrences(of: "\"", with: "\\\"")
					entries[language]?.append(.translation(key, escapedCell))
				}
			}
		}
		return Document(languages: languages, entries: entries)
	}
}
