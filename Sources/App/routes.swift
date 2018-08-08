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

    router
        .grouped(APIMiddleware.simple)
        .post(EloRankingURL.Auth.recover.path, use: AuthController.recover)
}

private func playerRoutes(_ router: Router) {
    router
        .grouped(APIMiddleware.simple)
        .post(EloRankingURL.Player.create.path, use: PlayerController.create)

    router
        .grouped(APIMiddleware.simple)
        .get(EloRankingURL.Player.list.path, use: PlayerController.list)

    router
        .grouped(APIMiddleware.simple)
        .get(EloRankingURL.baseURL,
             "/player/", Player.parameter,
             use: PlayerController.find)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .get(EloRankingURL.Player.stats.path, use: PlayerController.stats)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .get(EloRankingURL.Player.matches.path, use: PlayerController.matches)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .put(EloRankingURL.Player.update.path, use: PlayerController.update)
}

private func gameRoutes(_ router: Router) {
    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.Game.create.path, use: GameController.create)

    router
        .get(EloRankingURL.Game.list.path, use: GameController.list)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.baseURL,
              "/game/", Game.parameter,
              "/register/",
              use: GameController.register)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.baseURL,
              "/game/", Game.parameter,
              "/challenge/", Player.parameter,
              use: GameController.challenge)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.baseURL,
              "/game/", Game.parameter,
              "/match/", Match.parameter,
              "/accept/",
              use: GameController.accept)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.baseURL,
              "/game/", Game.parameter,
              "/match/", Match.parameter,
              "/winner/",
              use: GameController.winner)

    router
        .grouped(APIMiddleware.playerTokenAuth)
        .post(EloRankingURL.baseURL,
              "/game/", Game.parameter,
              "/match/", Match.parameter,
              "/loser/",
              use: GameController.loser)
}
