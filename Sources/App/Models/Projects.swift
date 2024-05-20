//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

enum ProjectType: String, Codable {
	case design, frontend, backend, mobile
}

final class Projects: Model, Content {
	static let schema: String = "projects"
	
	@ID(key: .id) var id: UUID?
	@Field(key: "name") var name: String
	@Field(key: "summary") var summary: String?
	@Enum(key: "type") var type: ProjectType
	
	@Siblings(through: PersonasProject.self, from: \.$project, to: \.$persona) var personas: [Personas]
	
	init(id: UUID? = nil, name: String, summary: String? = nil, type: ProjectType) {
		self.id = id
		self.name = name
		self.summary = summary
		self.type = type
	}
	
	init() {}
}

extension Projects: @unchecked Sendable {}
