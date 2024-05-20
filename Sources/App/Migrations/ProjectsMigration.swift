//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

// Hay que crear también la enumeración en la DB, añadiendo sus case
struct CreateProjects: AsyncMigration {
	func prepare(on database: any Database) async throws {
		let projectTypes = try await database.enum("projectTypes")
			.case("design")
			.case("frontend")
			.case("backend")
			.case("mobile")
			.create()
		
		// esto lo haríamos si queremos usar el enum pero si ya estuviera creado en la DB en otro momento anterior. Así rescatamos el tipo para usarlo en .field
//		let type = try await database.enum("projectTypes").read()
		
		try await database.schema(Projects.schema)
			.id()
			.field("name", .string, .required)
			.field("summary", .string)
			.field("type", projectTypes, .required, .custom("DEFAULT 'mobile'")) // al ser un enum requerido hay que añadirle una sentencia de sql para decirle cual es el valor por defecto
			.unique(on: "name")
			.create()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(Projects.schema)
			.delete()
		try await database.enum("projectTypes")
			.delete()
	}
}
