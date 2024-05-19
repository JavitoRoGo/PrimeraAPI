//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Fluent
import Vapor

// La migración es lo que se lanza, una única vez, para crear toda la estructura de tablas coincidiendo con la definición que le hemos dado en el modelo
// También permite una precarga de datos, y no solo para crearla con nuestro modelo ya definido
// Tenemos que crear una migración por cada tabla, conformada a AsyncMigration con dos func: prepare para crear la tabla y revert para borrarla

// Y una vez que la migración está lista aquí, hay que ponerla en configure y lanzarla desde Terminal con swift run App migrate

struct PersonasMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		// esto siempre es igual: try await con el schema de la tabla, y luego añadir los campos en formato como si fuera programación funcional o interfaz fluida; y crear al final
		try await database.schema(Personas.schema)
			.id()
			.field("name", .string, .required)
			.field("email", .string, .required)
			.field("address", .string)
			.unique(on: "email")
			.create()
	}
	
	func revert(on database: any Database) async throws {
		// esta función debe borrar o deshacer lo que se haya creado en prepare
		try await database.schema(Personas.schema)
			.delete()
	}
}

// Este código es totalmente independiente del modelo. La migración lo que hace es crear la tabla con sus campos y sus nombres, para que luego el modelo pueda ir a leer en ellas

// OJO, podemos ahorrarnos las migraciones y crear directamente las tablas con sus campos dentro de la DB; pero son muy fáciles de trabajar con ellas y nos crean las tablas del tirón, así que es muy recomendable usarlas


// Esta otra migración es necesaria porque ya lanzamos la anterior, y tenemos que actualizar la tabla porque se añadieron los cursos
struct PersonasCursosMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema(Personas.schema)
			.field("curso", .int, .references(Cursos.schema, .id)) // aquí es .int porque tiene que ser el tipo del id de la tabla hijo
			.update()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema(Personas.schema)
			.deleteField("curso")
			.delete()
	}
}
