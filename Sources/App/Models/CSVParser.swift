//
//  CSVDocument.swift
//  App
//
//  Created by Martin Prot on 22/03/2018.
//

import Foundation

struct CSVParser {
	
	struct Defaults {
		static let separator = ";"
		static let quote = "\""
	}
	
	enum ParsingError: Error {
		case quoteInNotQuotedWord
		case letterOutsideQuotedWord
		case eofInQuotedWord
	}
	
	enum State {
		case wordStart
		case inWord
		case firstQuote
		case secondQuote
	}
	
	let csvData: String
	let separator: Character
	let quote: Character
	
	init(csvData: String, separator: String = Defaults.separator) {
		guard let sep = separator.first, let quote = Defaults.quote.first else {
			fatalError("wrong separator given to csv parser")
		}
		self.csvData = csvData
		self.separator = sep
		self.quote = quote
	}
	
	func parse() throws -> [[String]] {
		var state = State.wordStart
		var word: [Character] = []
		var columns: [String] = []
		var lines: [[String]] = []
		
		try self.csvData.forEach { char in
			// first, check if new line
			guard String(char).rangeOfCharacter(from: CharacterSet.newlines) == nil else {
				switch state {
				case .wordStart:
					columns.append("")
					lines.append(columns)
					columns.removeAll()
				case .inWord:
					columns.append(String(word))
					word.removeAll()
					lines.append(columns)
					columns.removeAll()
					state = .wordStart
				case .firstQuote:
					word.append(char)
				case .secondQuote:
					columns.append(String(word))
					word.removeAll()
					lines.append(columns)
					columns.removeAll()
					state = .wordStart
				}
				return
			}
			
			switch state {
			case .wordStart:
				switch char {
				case separator:
					columns.append("")
				case quote:
					state = .firstQuote
				default:
					word.append(char)
					state = .inWord
				}
			
			case .inWord:
				switch char {
				case separator:
					columns.append(String(word))
					word.removeAll()
					state = .wordStart
				case quote:
					throw ParsingError.quoteInNotQuotedWord
				default:
					word.append(char)
				}
				
			case .firstQuote:
				switch char {
				case separator:
					word.append(char)
				case quote:
					state = .secondQuote
				default:
					word.append(char)
				}
				
			case .secondQuote:
				switch char {
				case separator:
					columns.append(String(word))
					word.removeAll()
					state = .wordStart
				case quote:
					word.append(char)
					state = .firstQuote
				default:
					throw ParsingError.letterOutsideQuotedWord
				}
			}
		}
		
		switch state {
		case .wordStart, .inWord, .secondQuote:
			columns.append(String(word))
			lines.append(columns)
		case .firstQuote:
			throw ParsingError.eofInQuotedWord
		}
		
		return lines
	}
	
}
