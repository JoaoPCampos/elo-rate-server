import Vapor
import Fluent
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let basicAuthMiddleware = Player.basicAuthMiddleware(using: BCryptDigest())
    let guardAuthMiddleware = Player.guardAuthMiddleware()

    router
//        .grouped(basicAuthMiddleware, guardAuthMiddleware)
        .post("rankingAPI", "v1", "player", use: CrudController.create)

    router
        .grouped(basicAuthMiddleware, guardAuthMiddleware)
        .get("rankingAPI", "v1", "players", use: CrudController.list)

    router
        .grouped(basicAuthMiddleware, guardAuthMiddleware)
        .put("rankingAPI", "v1", "player", use: CrudController.update)


//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
