//
//  CSVParserController.swift
//  App
//
//  Created by Martin Prot on 26/03/2018.
//

import Vapor
import Foundation
import Multipart
import Leaf

struct CSVFile: Content {
    var csv: Data
}

final class CSVParserController {
	
	func csvToJson(_ req: Request) throws -> Future<Document> {
        return try req.content.decode(CSVFile.self).map(to: Document.self, { file in
            guard let fileContent = String(data: file.csv, encoding: .utf8) else {
                throw Abort(.badRequest, reason: "Unreadable CSV file")
            }
            let parser = CSVParser(csvData: fileContent, separator: ";")
            let lines = try parser.parse()
            let localizer = LocalizeDocument(csvLines: lines)
            return try localizer.parseDocument()
		})
	}
	
	func csvToWeb(_ req: Request) throws -> Future<View> {
		return try self.csvToJson(req).flatMap(to: View.self, { document in
			// Transforming to view
			let leaf = try req.make(LeafRenderer.self)
			let context = ["document": document]
			return leaf.render("results", context)
		})
	}
	
}
