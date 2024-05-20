//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

struct CursosController: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		let app = routes.grouped("cursos")
		app.get("get", use: getCursos)
		app.get("getSolo", use: getCursosSolo)
		app.post("create", use: createCurso)
		app.put("updatePersona", use: updatePersona)
		app.get("personasCurso", use: personasCurso)
		app.get("personasCursoPersona", use: personasCursoPersona)
		app.get("personasCursoOK", use: personasCursoOK)
		app.get("personasCursoOK2", use: personasCursoOK2)
	}
	
	@Sendable func getCursos(req: Request) async throws -> [Cursos] {
		try await Cursos.query(on: req.db)
			.with(\.$personas) // con esto añadimos a la consulta la subconsulta de los hijos
			.all()
	}
	
	// esto es un ejemplo para obtener un resultado personalizado usando un DTO, no el modelo tal cual
	@Sendable func getCursosSolo(req: Request) async throws -> [CursosSolo] {
		try await Cursos.query(on: req.db)
			.with(\.$personas) // si quitamos esta línea no podemos acceder a personas dentro del map, y peta la app: NO olvidarse
			.all()
			.map { curso in
				let personas = curso.personas.map(\.toPersonaSolo)
				return CursosSolo(name: curso.nombreCurso, personas: personas)
			}
	}
	
	@Sendable func createCurso(req: Request) async throws -> HTTPStatus {
		let newCurso = try req.content.decode(Cursos.self)
		try await newCurso.create(on: req.db)
		return .created
	}
	
	@Sendable func updatePersona(req: Request) async throws -> HTTPStatus {
		guard let id = req.query[Int.self, at: "id"],
			  let email = req.query[String.self, at: "email"] else {
			return .notFound
		}
		let persona = try await QueryAsistant.shared.queryEmail(email: email, req: req)
		persona.$curso.id = id // para actualizar el curso de la persona se hace asignando el id
		try await persona.update(on: req.db)
		return .accepted
	}
	
	// vamos a recuperar todas las personas que hay en 1 curso
	@Sendable func personasCurso(req: Request) async throws -> [PersonasSolo] {
		guard let id = req.query[Int.self, at: "curso"] else { throw Abort(.notFound) }
		if let curso = try await Cursos.find(id, on: req.db) {
			try await curso.$personas.load(on: req.db) // para cargar la relación padre-hijo, porque con find solo recuperamos Cursos; esto es como la subconsulta con .with, que con find no funciona el with
			return curso.personas.map(\.toPersonaSolo)
		} else {
			throw Abort(.notFound)
		}
	}
	
	// misma consulta de antes pero a través de la tabla de Personas, que es más complejo porque hay que dar más vueltas ya que estamos suponiendo que no hay relación entre las tablas, pero devuelve lo mismo
	@Sendable func personasCursoPersona(req: Request) async throws -> [PersonasSolo] {
		guard let id = req.query[Int.self, at: "curso"] else { throw Abort(.notFound) }
		return try await Personas
			.query(on: req.db)
		// si no tuviéramos un valor asociado entre las tablas podemos "unirlas"
		// lo que recuperamos es una consulta mixta de las dos tablas: unimos al resultado de Personas la consulta de Cursos igualando los id
			.join(Cursos.self, on: \Personas.$curso.$id == \Cursos.$id, method: .left)
			.filter(Cursos.self, \.$id == id)
			.with(\.$curso)
			.all()
			.map(\.toPersonaSolo)
	}
	
	// si tenemos una relación entre tablas, lo anterior se resuelve de forma mucho más eficiente y fácil
	@Sendable func personasCursoOK(req: Request) async throws -> [PersonasSolo] {
		guard let id = req.query[Int.self, at: "curso"] else { throw Abort(.notFound) }
		return try await Personas
			.query(on: req.db)
			.with(\.$curso)
			.filter(\.$curso.$id == id)
			.all()
			.map(\.toPersonaSolo)
	}
	
	// otra forma más de hacer la misma consulta, porque hay varias formas de hacer lo mismo
	@Sendable func personasCursoOK2(req: Request) async throws -> [PersonasSolo] {
		guard let id = req.query[Int.self, at: "curso"],
			let curso = try await Cursos.find(id, on: req.db) else { throw Abort(.notFound) }
		return try await curso.$personas.get(on: req.db).map(\.toPersonaSolo)
	}
}
