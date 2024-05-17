import Fluent
import Vapor

func routes(_ app: Application) throws {
	// aquí van los endpoints
	// el get solo es el directorio raíz localhost
	app.get { req async in
		"It works!"
	}
	
	// esto viene del controlador:
	try app.routes.register(collection: DemoController())
	
	// este endpoint es localhost/hello
	// si queremos captar o pedir un valor, que en la url sería localhost/hello?name=Julio, se hace así
	// está comentada para usarla como ejemplo en DemoController
//	app.get("hello") { req async -> String in
//		// la request es lo que se recupera y contiene todo tipo de información
//		// podemos recuperar el valor introducido en la url, con if-let si no es obligatorio ese parámetro
//		if let name = req.query[String.self, at: "name"] {
//			"Hello, \(name)!"
//		} else {
//			"Hello"
//		}
//	}
	
	// nuevo endpoint que lanza errores. Los errores son instancias de la clase Abort
	app.get("goodbye") { req async throws -> String in
		guard let name = req.query[String.self, at: "name"] else {
			// si en la url no viene el parámetro name que no haga nada
			throw Abort(.notFound, reason: "Se necesita la inclusión del parámetro name.")
			// los errores se devuelven como json
		}
		return "Goodbye \(name)"
	}
	
	// Entrada de parámetros variables en línea, en la propia url: whatsup/pepe
	// Podemos poner todos los que queramos
	app.get("whatsup", ":name") { req async throws -> String in
		guard let name = req.parameters.get("name") else {
			throw Abort(.notFound, reason: "Se necesita la inclusión del parámetro name.")
		}
		return "What's Up \(name)"
	}
	
	
	// Envío de datos o cosas con POST, para lo que necesitamos una estructura conformada a Content que lo recupere
	// Como vamos a enviar cosas en el body ya no nos sirve Safari para probar, necesitamos Postman
	app.post("nameQuery") { req async throws -> String in
		// req.content contiene el body de la petición, que a su vez tiene el json que quiero enviar/recuperar
		let test = try req.content.decode(TestData.self)
		return "Eres \(test.name) con el email \(test.email)."
	}
	
	// También podemos recuperar la estructura TestData porque es de tipo Content
	app.get("getCard") { req async throws -> TestData in
		guard let name = req.query[String.self, at: "name"],
		let email = req.query[String.self, at: "email"] else {
			throw Abort(.notFound, reason: "Se necesita la inclusión del parámetro name e email.")
		}
		return TestData(name: name, email: email)
	}
	
	// El trabajo con endpoints no tiene más: get y post, con parámetros en línea o sin ellos, y con estructuras tipo Content
}
