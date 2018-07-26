import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.post("api", "v1", "player") { req -> Future<Player> in
        return try req.content.decode(Player.self).create(on: req)
    }

    router.get("api", "v1", "players") { req -> Future<[Player]> in
        return Player.query(on: req).all()
    }

//    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
