import Vapor
//
///// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Player]> {
        return Player.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ request: Request) throws -> Future<Player> {
        return try request.content.decode(Player.self).flatMap { player in
            return player.save(on: request)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Player.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
