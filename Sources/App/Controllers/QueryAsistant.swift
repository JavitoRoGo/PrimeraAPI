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
	
	// estas funciones podrían declararse directamente como static, pero las buenas prácticas de Apple dicen que es mejor usar el patrón singleton
	
	// creamos una función auxiliar de búsqueda por email para reutilizarla en otros endpoints
	func queryEmail(email: String, db: Database) async throws -> Personas {
		if let persona = try await Personas.query(on: db)
			.filter(\.$email == email)
			//			.filter(\.$email, .custom("ILKE"), email) // esta línea solo funcionaría con postgre, y es una operación directa de base de datos para búsqueda case insensitive y sin diacríticos
			.first() {
			return persona
		} else {
			throw Abort(.notFound, reason: "No existe el email \(email).")
		}
	}
	
	func queryName(name: String, db: Database) async throws -> Projects {
		if let project = try await Projects
			.query(on: db)
			.filter(\.$name == name)
			.first() {
			return project
		} else {
			throw Abort(.notFound, reason: "No existe el proyecto de nombre \(name).")
		}
	}
}
