//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Fluent
import Vapor
import FluentSQL // solo para una prueba

// No olvidar registrar los controllers en routes.swift
struct PersonaController: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		let api = routes.grouped("persona")
		api.post("create", use: createPersona)
		api.get("query", use: queryPersonas)
		api.get("get", use: getPersonas)
		api.get("queryEmail", use: queryEmailPersona)
		api.get("query", ":id", use: queryPersonabyID)
		api.put("update", use: updatePersona)
		api.delete("delete", use: deletePersona)
		api.post("assignProject", use: assignProjectToPerson)
		api.delete("deassignProject", use: deassignProjectToPerson)
		api.get("getProject", use: getProjectFromPersona)
	}
	
	@Sendable func createPersona(req: Request) async throws -> HTTPStatus {
		let newPersona = try req.content.decode(Personas.self) // recupera del body y crea el registro en memoria
		try await newPersona.create(on: req.db) // creado el registro
		return .created
	}
	
	@Sendable func queryPersonas(req: Request) async throws -> [Personas] {
		try await Personas.query(on: req.db)
			.with(\.$curso) // con esto añadimos la subconsulta asociada a un valor padre
			.all()
	}
	
	// en este ejemplo el email nos viene en la url como query del tipo ?email=dato
	@Sendable func queryEmailPersona(req: Request) async throws -> Personas {
		guard let email = req.query[String.self, at: "email"] else {
			throw Abort(.notFound, reason: "No se ha indicado el valor de email a buscar.")
		}
		return try await QueryAsistant.shared.queryEmail(email: email, db: req.db)
	}
	
	@Sendable func queryPersonabyID(req: Request) async throws -> Personas {
		// si sabemos el id y nos viene en la llamada como parámetro, podemos hacer la búsqueda con find
		// el campo id es el único por el que podemos buscar de manera directa
		guard let id = req.parameters.get("id", as: UUID.self) else {
			throw Abort(.notFound, reason: "No se ha recibido un valor de tipo UUID.")
		}
		if let persona = try await Personas.find(id, on: req.db) {
			return persona
		} else {
			throw Abort(.notFound, reason: "No existe ese índice en la base de datos.")
		}
	}
	
	@Sendable func updatePersona(req: Request) async throws -> HTTPStatus {
		// tenemos que verificar que el dato existe y es correcto, usando un valor único
		// se hace recuperando un json con los datos a modificar, así que mejor nos hacemos un DTO para eso
		let query = try req.content.decode(PersonaUpdate.self)
		let persona = try await QueryAsistant.shared.queryEmail(email: query.email, db: req.db) // no tenemos que hacer if-let porque esta función que creamos para reutilizarla ya nos devuelve el error si no existe la persona en la DB
		if let address = query.address {
			persona.address = address
		}
		if let name = query.name {
			persona.name = name
		}
		
		try await persona.update(on: req.db)
		return .accepted
	}
	
	@Sendable func deletePersona(req: Request) async throws -> HTTPStatus {
		let query = try req.content.decode(PersonaUpdate.self)
		let persona = try await QueryAsistant.shared.queryEmail(email: query.email, db: req.db)
		if persona.name == query.name {
			try await persona.delete(on: req.db)
			return .accepted
		} else {
			throw Abort(.badRequest, reason: "No se ha podido borrar el dato.")
		}
	}
	
	@Sendable func getPersonas(req: Request) async throws -> [PersonasSolo] {
		try await Personas.query(on: req.db)
			.all()
			.map(\.toPersonaSolo)
	}
	
	@Sendable func assignProjectToPerson(req: Request) async throws -> HTTPStatus {
		let query = try req.content.decode(ProjectPersonasQuery.self)
		let project = try await QueryAsistant.shared.queryName(name: query.name, db: req.db)
		let persona = try await QueryAsistant.shared.queryEmail(email: query.email, db: req.db)
		try await persona.$projects.attach(project, method: .ifNotExists, on: req.db)
		return .accepted
	}
	
	@Sendable func deassignProjectToPerson(req: Request) async throws -> HTTPStatus {
		let query = try req.content.decode(ProjectPersonasQuery.self)
		let project = try await QueryAsistant.shared.queryName(name: query.name, db: req.db)
		let persona = try await QueryAsistant.shared.queryEmail(email: query.email, db: req.db)
		if try await persona.$projects.isAttached(to: project, on: req.db) {
			try await persona.$projects.detach(project, on: req.db)
			return .accepted
		} else {
			throw Abort(.notFound)
		}
	}
	
	@Sendable func getProjectFromPersona(req: Request) async throws -> [Projects] {
		guard let email = req.query[String.self, at: "email"] else {
			throw Abort(.notFound, reason: "No se ha indicado el valor de email a buscar.")
		}
		let persona = try await QueryAsistant.shared.queryEmail(email: email, db: req.db)
		return try await persona.$projects
			.query(on: req.db)
			.all()
	}
	
	
	
	
	// si queremos usar las consultas de SQL directamente a la base de datos también se puede, pero la gracia es que Fluent es un ORM y nos evita eso
	func getPersonasSQL(req: Request) async throws -> [Personas] {
		if let sql = req.db as? SQLDatabase {
			return try await sql.raw("SELECT * FROM PERSONAS").all(decodingFluent: Personas.self)
		} else {
			throw Abort(.badGateway)
		}
	}
}
