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
        .grouped(APIMiddleware.playerBasicAuth)
        .post(EloRankingURL.Auth.login.path, use: AuthController.login)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .delete(EloRankingURL.Auth.logout.path, use: AuthController.logout)
}

private func playerRoutes(_ router: Router) {
    router
        .post(EloRankingURL.Player.create.path, use: PlayerController.create)

    router
        .get(EloRankingURL.Player.list.path, use: PlayerController.list)

    router
        .get(EloRankingURL.Player.find.path, use: PlayerController.find)
}

private func gameRoutes(_ router: Router) {
    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.Game.create.path, use: GameController.create)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.Game.accept.path, use: GameController.accept)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .get(EloRankingURL.Game.list.path, use: GameController.list)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .put(EloRankingURL.Game.winner.path, use: GameController.winner)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .put(EloRankingURL.Game.loser.path, use: GameController.loser)
}
