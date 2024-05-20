//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Fluent
import Vapor

final class Cursos: Model, Content {
	static let schema: String = "cursos"
	
	@ID(custom: .id) var id: Int?
	@Field(key: "nombre_curso") var nombreCurso: String
	@Timestamp(key: "updated", on: .update, format: .default) var updateDate: Date? // podemos tener el time stamp de un evento en la DB, update en este caso. Y a la fecha también se le puede dar un formato
	
	@Children(for: \.$curso) var personas: [Personas] // esto es como una consulta que se añade al campo curso de la tabla de Personas, no hay que añadir a migration ni nada, es para consultar desde curso qué personas tiene
	// esta línea anterior es opcional, podemos no ponerla y funcionará igual; pero si la ponemos podemos hacer la consulta que se indica
	
	init(id: Int? = nil, nombreCurso: String) {
		self.id = id
		self.nombreCurso = nombreCurso
	}
	
	init() {}
}

extension Cursos: @unchecked Sendable {}
