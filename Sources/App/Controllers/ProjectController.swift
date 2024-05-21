//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 20/5/24.
//

import Fluent
import Vapor

struct ProjectController: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		let app = routes.grouped("project")
		app.post("create", use: createProject)
		app.get("getAll", use: getProjects)
		app.get("get", ":id", use: getProject)
		app.get("getName", ":name", use: getProjectName)
		app.post("assignPersona", use: assignPersona)
		app.delete("deassignPersona", use: deassignPersona)
		app.get("personasAtProject", ":id", use: getPersonasByProject)
	}
	
	@Sendable func createProject(req: Request) async throws -> HTTPStatus {
		let project = try req.content.decode(Projects.self)
		try await project.create(on: req.db)
		return .created
	}
	
	@Sendable func getProjects(req: Request) async throws -> [Projects] {
		try await Projects
			.query(on: req.db)
			.all()
	}
	
	@Sendable func getProject(req: Request) async throws -> Projects {
		guard let id = req.parameters.get("id", as: UUID.self),
			  let project = try await Projects.find(id, on: req.db) else { throw Abort(.notFound) }
		return project
	}
	
	@Sendable func getProjectName(req: Request) async throws -> Projects {
		guard let name = req.parameters.get("name") else { throw Abort(.notFound) }
		if let project = try await Projects
			.query(on: req.db)
			.filter(\.$name == name)
			.first() {
				return project
		} else {
			throw Abort(.notFound)
		}
	}
	
	// ahora viene lo bueno: necesitamos un registro específico dentro de la tabla PersonasProjects
	// está TOTALMENTE PROHIBIDO escribir o borrar en la tabla pivot, para eso usamos los métodos attach y detach
	@Sendable func assignPersona(req: Request) async throws -> HTTPStatus {
		// rescatamos el dato a actualizar que nos pasan, que es un registro de la tabla pivot
		// esta es la forma más directa de hacerlo, que no la mejor
		let relation = try req.content.decode(PersonasProject.self)
		// por cada id tenemos que recuperar el elemento de Persona y de Project
		if let project = try await Projects.find(relation.$project.id, on: req.db),
		   let persona = try await Personas.find(relation.$persona.id, on: req.db) {
			try await project.$personas.attach(persona, method: .ifNotExists, on: req.db)
			
			return .accepted
		} else {
			throw Abort(.notFound)
		}
	}
	
	@Sendable func deassignPersona(req: Request) async throws -> HTTPStatus {
		let relation = try req.content.decode(PersonasProject.self)
		if let project = try await Projects.find(relation.$project.id, on: req.db),
		   let persona = try await Personas.find(relation.$persona.id, on: req.db),
		   try await project.$personas.isAttached(to: persona, on: req.db) {
			// para desasociar un registro es igual que asociarlo, salvo que primero tenemos que comprobar que está asociado
			try await project.$personas.detach(persona, on: req.db)
			
			return .accepted
		} else {
			throw Abort(.notFound)
		}
	}
	
	@Sendable func getPersonasByProject(req: Request) async throws -> [PersonasSolo] {
		guard let id = req.parameters.get("id", as: UUID.self),
			  let project = try await Projects.find(id, on: req.db) else { throw Abort(.notFound) }
		return try await project.$personas // pasamos a través del sibling como una sub-query
			.query(on: req.db)
//			.with(\.$projects) // podríamos añadir los detalles de subconsultas al resultado
			.all()
			.map(\.toPersonaSolo)
	}
	
	// ejemplo de transacciones para hacer varias operaciones todas a la vez y no una detrás de otra
	func testCursoBatch(req: Request) async throws -> HTTPStatus {
		let personas = try await Personas
			.query(on: req.db)
			.all()
		guard let curso = try await Cursos
			.query(on: req.db)
			.filter(\.$nombreCurso == "Vision Dev Program")
			.first() else { throw Abort(.notFound) }
		try await req.db.transaction { db in
			// las operaciones indicadas dentro de este closure se realizan todas a la vez
			// lo malo de este ejemplo sería que si falla alguna de las operaciones se cancela toda la transacción y no se guarda nada
			for persona in personas {
				persona.$curso.id = curso.id
				try await persona.update(on: req.db)
			}
		}
		return .accepted
	}
}
