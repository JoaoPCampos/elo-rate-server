import Vapor
import Fluent
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let basicAuthMiddleware = Player.basicAuthMiddleware(using: BCryptDigest())
    let guardAuthMiddleware = Player.guardAuthMiddleware()
    let tokenAuthMiddleware = Player.tokenAuthMiddleware()

    router
        .grouped(basicAuthMiddleware, guardAuthMiddleware)
        .post("rankingAPI", "v1", "login", use: CrudController.login)

    router
//        .grouped(basicAuthMiddleware, guardAuthMiddleware)
        .post("rankingAPI", "v1", "player", use: CrudController.create)

    router
        .grouped(tokenAuthMiddleware, guardAuthMiddleware)
        .get("rankingAPI", "v1", "players", use: CrudController.list)

    router
        .grouped(tokenAuthMiddleware, guardAuthMiddleware)
        .put("rankingAPI", "v1", "player", use: CrudController.update)

    router
        .grouped(tokenAuthMiddleware, guardAuthMiddleware)
        .post("rankingAPI", "v1", "game", use: CrudController.createGame)


//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
