import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
	// uncomment to serve files from /Public folder
	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	
	app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
	
	// ojo que el orden de las migraciones importa, porque no podríamos crear PersonasCursos antes de crear Cursos
	app.migrations.add(PersonasMigration()) // esto solo se lanza una vez
	app.migrations.add(CursosMigration())
	app.migrations.add(PersonasCursosMigration())
	app.migrations.add(CreateProjects())
	app.migrations.add(PersonasProjectMigration())
	
	try routes(app)
}
