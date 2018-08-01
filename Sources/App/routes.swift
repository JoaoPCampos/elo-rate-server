import Vapor
import Fluent
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    authRoutes(router)
    playerRoutes(router)
    gameRoutes(router)
}

private func authRoutes(_ router: Router) {
    router
        .grouped(Middlewares.playerBasicAuth)
        .post("ranking", "api", "v1.0", "auth", "login", use: AuthController.login)

    router
        .grouped(Middlewares.playerTokenAuth)
        .delete("ranking", "api", "v1.0", "auth", "logout", use: AuthController.logout)
}

private func playerRoutes(_ router: Router) {
    router
        .grouped(Middlewares.adminBasicAuth)
        .post("ranking", "api", "v1.0", "player", use: PlayerController.create)

    router
        .grouped(Middlewares.playerTokenAuth)
        .get("ranking", "api", "v1.0", "players", use: PlayerController.list)

    router
        .grouped(Middlewares.playerTokenAuth)
        .put("ranking", "api", "v1.0", "player", use: PlayerController.update)
}

private func gameRoutes(_ router: Router) {
    router
        .grouped(Middlewares.playerTokenAuth)
        .post("ranking", "api", "v1.0", "game", use: GameController.create)
}
