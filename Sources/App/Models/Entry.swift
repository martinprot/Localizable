//
//  Entry.swift
//  App
//
//  Created by Martin Prot on 22/03/2018.
//

import Vapor

class Language: Hashable, Codable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
	
	static func == (lhs: Language, rhs: Language) -> Bool {
		return lhs.code == rhs.code
	}
	
	let code: String
	
	var localized: String
	
	init?(code: String) {
		if code.count != 2 { return nil }
		self.code = code.lowercased()
		self.localized = code.uppercased()
	}
}

enum Entry {
	case blankLine
	case comment(String)
	case translation(String, String)
}

extension Entry {
	var description: String {
		switch self {
		case .blankLine:
			return "blank"
		case .comment(let comment):
			return "comment: \(comment)"
		case .translation(let key, let value):
			return "\(key) - \(value)"
		}
	}
}

struct Document: Content {
	let languages: [Language]
	let entries: [Language: [Entry]]
	
	static var empty: Document {
		return Document(languages: [], entries: [:])
	}
}

////////////////////////////////////////////////////////////////////////////
// MARK: Codable support
////////////////////////////////////////////////////////////////////////////

extension Document {
	private struct Element: Codable {
		let language: Language
		let entries: [Entry]
	}
	
	private var elements: [Element] {
		return self.languages.map { Element(language: $0, entries: self.entries[$0] ?? []) }
	}

	enum CodingKeys: String, CodingKey {
		case elements
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let elements = try container.decode([Element].self, forKey: .elements)
		self.languages = elements.map { $0.language }
		self.entries = elements.reduce(into: [:]) { entries, element in
			entries[element.language] = element.entries
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.elements, forKey: .elements)
	}
}

extension Entry: Codable {
	private enum EntryType: String, Codable {
		case blank, comment, translation
	}
	enum CodingKeys: String, CodingKey {
		case type, key, value
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(EntryType.self, forKey: .type)
		
		switch type {
		case .blank:
			self = .blankLine
		case .comment:
			let comment = try container.decode(String.self, forKey: .value)
			self = .comment(comment)
		case .translation:
			let key = try container.decode(String.self, forKey: .key)
			let value = try container.decode(String.self, forKey: .value)
			self = .translation(key, value)
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .blankLine:
			try container.encode(EntryType.blank, forKey: .type)
		case .comment(let comment):
			try container.encode(EntryType.comment, forKey: .type)
			try container.encode(comment, forKey: .value)
		case .translation(let key, let value):
			try container.encode(EntryType.translation, forKey: .type)
			try container.encode(key, forKey: .key)
			try container.encode(value, forKey: .value)
		}
	}
}
