//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

// Tabla intermedia o pivot para la relación N-N, que tiene una forma especial de ser creada
// Hay que poner dos padres obligatorios que unan las dos tablas

final class PersonasProject: Model, Content {
	static let schema: String = "personas_projects"
	
	@ID(key: .id) var id: UUID?
	@Parent(key: "project") var project: Projects
	@Parent(key: "persona") var persona: Personas
	
	init(id: UUID? = nil, project: Projects, persona: Personas) throws {
		self.id = id
		self.$project.id = try project.requireID()
		self.$persona.id = try persona.requireID()
	}
	
	init() {}
}

extension PersonasProject: @unchecked Sendable {}
