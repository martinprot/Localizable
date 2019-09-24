//
//  CSVDocument.swift
//  App
//
//  Created by Martin Prot on 26/03/2018.
//

import Vapor

struct CSVDocument: Content {
	let path: String = "path"
	var csvfile: Data
}
