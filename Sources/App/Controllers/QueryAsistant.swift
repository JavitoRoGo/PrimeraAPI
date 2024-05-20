//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

struct QueryAsistant {
	static let shared = QueryAsistant()
	
	// creamos una función auxiliar de búsqueda por email para reutilizarla en otros endpoints
	func queryEmail(email: String, req: Request) async throws -> Personas {
		if let persona = try await Personas.query(on: req.db)
			.filter(\.$email == email)
			//			.filter(\.$email, .custom("ILKE"), email) // esta línea solo funcionaría con postgre, y es una operación directa de base de datos para búsqueda case insensitive y sin diacríticos
			.first() {
			return persona
		} else {
			throw Abort(.notFound, reason: "No existe el email \(email).")
		}
	}
}
