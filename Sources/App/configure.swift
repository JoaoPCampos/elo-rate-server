import FluentSQLite
import Authentication
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    
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

    /// Mailgun
    let mailgun = Mailgun(apiKey: "c459f8b151b59b0946cee0dfb899be12-a5d1a068-38f46fe4", domain: "elo-ranking-development.vapor.cloud")
    services.register(mailgun, as: Mailgun.self)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Player.self, database: .sqlite)
    migrations.add(model: AdminPlayer.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Game.self, database: .sqlite)
    migrations.add(migration: Admin.self, database: .sqlite) //creates an admin at server start
    services.register(migrations)
    
}
