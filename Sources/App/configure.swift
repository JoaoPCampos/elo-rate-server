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
    
    /// Register middleware for CORS
    let eloRankingCORS = EloRankingCORS()
    var middlewareConfig = MiddlewareConfig()
    middlewareConfig.use(eloRankingCORS.middleware())
    services.register(middlewareConfig)
    
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
