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
