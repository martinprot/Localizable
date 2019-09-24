import Routing
import Vapor
import Leaf

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {

    let parserController = CSVParserController()
    router.post("uploadcsv", use: parserController.csvToWeb)
	
	router.post("csv2json", use: parserController.csvToJson)
	
	router.get("index") { req -> Future<View> in
		let leaf = try req.make(LeafRenderer.self)
		let context = [String: String]()
		return leaf.render("index", context)
	}

}
