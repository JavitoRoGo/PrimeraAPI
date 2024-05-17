//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Fluent
import Vapor

final class Cursos: Model {
	static let schema: String = "cursos"
	
	@ID(custom: .id) var id: Int?
	@Field(key: "nombre_curso") var nombreCurso: String
	@Timestamp(key: "updated", on: .update) var updateDate: Date? // podemos tener el time stamp de un evento en la DB, update en este caso
	
	@Children(for: \.$curso) var personas: [Personas] // esto es como una consulta, no hay que añadir a migration ni nada, es para consultar desde curso qué personas tiene
	
	init(id: Int? = nil, nombreCurso: String) {
		self.id = id
		self.nombreCurso = nombreCurso
	}
	
	init() {}
}

extension Cursos: @unchecked Sendable {}
