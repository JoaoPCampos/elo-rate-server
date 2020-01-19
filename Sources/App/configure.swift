import FluentPostgreSQL
import Authentication
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
//    try services.register(FluentPostgreSQLProvider())
    try services.register(FluentPostgreSQLProvider())

    /// Register authentication
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    var middlewares = MiddlewareConfig() // Create _empty_ middleware config

    /// Middleware for CORS
    middlewares.use(EloRankingCORS().middleware())
    services.register(middlewares)

    /// Middleware for errors
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Register Middleware
    services.register(middlewares)

    // Configure a PostgreSQL database
    var databases = DatabasesConfig()

    guard let url = Environment.get("DATABASE_URL"),
        let databaseConfig = PostgreSQLDatabaseConfig(url: url) else {

        assertionFailure("Unable to get Postgre SQL database configuration")
        return
    }

    let database = PostgreSQLDatabase(config: databaseConfig)
    
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    
    migrations.add(model: Player.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: Game.self, database: .psql)
    migrations.add(model: Match.self, database: .psql)
    migrations.add(model: PlayerStats.self, database: .psql)
    
    services.register(migrations)
}
