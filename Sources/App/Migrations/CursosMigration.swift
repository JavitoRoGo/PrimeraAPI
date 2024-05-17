//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Fluent
import Vapor

struct CursosMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(Cursos.schema)
			.field(.id, .int, .identifier(auto: true)) // con esta constrain se construye solo de forma incremental
			.field("nombre_curso", .string, .required)
			.field("updated", .datetime)
			.create()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(Cursos.schema)
			.delete()
	}
}

// No olvidar añadir la migración a configure.swift y ejecutar en Terminal para crear la tabla
