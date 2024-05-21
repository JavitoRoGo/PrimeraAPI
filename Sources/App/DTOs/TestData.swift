//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Vapor

// Los DTO son estructuras en memoria que no tienen persistencia y se usan para el trabajo con endpoints

struct TestData: Content {
	let name: String
	let email: String
}


struct PersonaUpdate: Content {
	let email: String
	let name: String?
	let address: String?
}

struct PersonasSolo: Content {
	// para obtener una consulta con el formato que queramos, un resultado personalizado y no el del model Personas
	let name: String
	let email: String
	let address: String?
}

struct CursosSolo: Content {
	let name: String
	let personas: [PersonasSolo]
}

// para asignar un proyecto a una persona de forma más fácil
struct ProjectPersonasQuery: Content {
	let email: String
	let name: String
}
