//
//  File.swift
//  
//
//  Created by Javier Rodríguez Gómez on 17/5/24.
//

import Fluent
import Vapor

// Los modelos son diferentes de los DTO, y son las estructuras para las bases de datos y la persistencia
// Se conforman al protocolo Model, que incluye todo lo necesario para incorporar la representación de los datos en tablas en la DB
// Requiere una propiedad llamada schema que es el nombre que tendrá la tabla en la DB (en snake_case). Y también un ID
// Los campos de las tablas se crean con propertywrappers

// También conformamos a Content para usarlo como json para enviar y devolver los datos en las peticiones a la DB

final class Personas: Model, Content {
	static let schema: String = "personas" // este es el nombre de la tabla en la DB
	
	// el id por defecto es key del tipo UUID, pero lo podemos personalizar con custom
	// en Vapor, TODOS LOS ID SON OPCIONALES, porque se cargan en la DB antes de escribirse
	// Vapor crea el id como nil y lo envía a la DB, y entonces Fluent lo recibe y le da el valor que corresponda
	@ID(key: .id) var id: UUID?
	
	// ahora van los campos
	// el valor de key es el del campo en la DB, y el nombre de var es el que usaremos en Swift
	@Field(key: "name") var name: String
	@Field(key: "email") var email: String
	@Field(key: "address") var address: String? // opcional para reflejar que no siempre hay que ponerlo; si no es opcional es obligatorio
	
	// Una vez creados los cursos, vamos a hacer una relación de 1 a N: una persona por curso, pero los cursos tienen varias personas
	// En 1-N, el 1 se considera el padre
//	@Parent(key: "curso") var curso: Cursos // el tipo es el de la otra tabla
	@OptionalParent(key: "curso") var curso: Cursos? // esta línea la usamos si el curso es opcional, es decir, que no es obligatorio que tenga un curso. En este caso lo hacemos opcional porque ya tenemos datos en la DB, y si hacemos que sea obligatorio peta, porque no estarían esos valores en la DB para cada Persona
	
	// hay que crear el constructor por defecto de la tabla, pero al añadir este desaparece el constructor sintetizado por defecto, por lo que hay que añadirlo para que vuelva a conformar al protocolo: añadir el init vacío
	init(id: UUID? = nil, name: String, email: String, address: String? = nil) {
		self.id = id
		self.name = name
		self.email = email
		self.address = address
	}
	
	init() {}
}

extension Personas: @unchecked Sendable {
	// sale un warning en ID pero no hay que hacerle caso, porque es algo que Vapor tiene que adaptar. Pero desaparece si conformamos la clase a @unchecked Sendable
	// este warning será un error de compilación en Swift 6, donde habrá que definir la posibilidad o estado de Sendable para todo
	// todos los tipos por valor, TODOS, son Sendable. Ver la documentación de Sendable para ver otros tipos que son Sendable, por ejemplo, tipos por referencia (clases) que solo tengan let; referencias con control interno de estado (actores)
	// Sendable es A type whose values can safely be passed across concurrency domains by copying.
}

// Para DB el primer paso es crear el modelo, y luego viene la migración, que es como crear la tabla. Una vez que ejecutemos la migración en Terminal la tabla estará creada
// Y si más adelante la modificamos añadiendo o quitando campos, hay que hacer y ejecutar una nueva migración con esos cambios
