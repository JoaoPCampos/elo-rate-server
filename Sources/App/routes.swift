import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    router.post("rankingAPI", "v1", "player", use: CrudController.update)

    router.get("rankingAPI", "v1", "players", use: CrudController.list)

    router.put("rankingAPI", "v1", "player", use: CrudController.create)

//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
