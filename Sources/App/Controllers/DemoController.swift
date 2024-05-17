//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Vapor

// Este protocolo solo tiene un requisito: la función boot que recogerá todas las routes
struct DemoController: RouteCollection {
	// esto es una agrupación de routes, donde se recogen todas las rutas que vamos a usar, asociadas a una función o código a ejecutar en cada una
	// lo que hagamos aquí hay que registrarlo en routes.swift
	func boot(routes: any RoutesBuilder) throws {
		let api = routes.grouped("demo") // agrupación de rutas, que estarán todas sobre demo/lo-que-sea
		// dentro de esta función ponemos todas las rutas, con su .get o .post, su nombre, y la función que tiene que usar
		api.get("hello", use: hello)
		api.get("whatsup", ":name", use: whatsup)
	}
	
	// fuera de la función boot pero dentro del struct van todas las funciones que se correspondan con cada uno de los endpoints de la función boot
	// Hay que poner @Sendable porque tenemos activado .enableExperimentalFeature("StrictConcurrency") en Package.swift, que lo que hace es activar esa característica experimental. O sea, que cuando salga Swift 6, este código no funcionará si no tiene puesto @Sendable
	// Recordar que un elemento Sendable es el que puede pasarse entre diferentes contextos sin provocar data races
	// O sea, al usar la función hello, garantizamos como developers que no se modificará ningún contexto por lo que es seguro usarla
	@Sendable func hello(req: Request) async throws -> String {
		if let name = req.query[String.self, at: "name"] {
			"Hello, \(name)!"
		} else {
			"Hello"
		}
	}
	
	@Sendable func whatsup(req: Request) async throws -> String {
		guard let name = req.parameters.get("name") else {
			throw Abort(.notFound, reason: "Se necesita la inclusión del parámetro name.")
		}
		return "What's Up \(name)"
	}
}
