//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

struct PersonasProjectMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(PersonasProject.schema)
			.id()
			.field("project", .uuid, .references(Projects.schema, .id), .required)
			.field("persona", .uuid, .references(Personas.schema, .id), .required)
			.create()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(PersonasProject.schema)
			.delete()
	}
}
