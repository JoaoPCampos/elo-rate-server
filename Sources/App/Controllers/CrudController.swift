//
//  CrudController.swift
//  App
//
//  Created by João Campos on 26/07/2018.
//

import Vapor
import Crypto

final class CrudController {

    static func login(_ request: Request) throws -> Future<Token> {
        let player = try request.requireAuthenticated(Player.self)
        let newToken = try Token.generate(for: player)

        guard let email = player.email else { throw Abort(.unauthorized, reason: "Bad credentials") }

        return Token
            .find(email, on: request)
            .flatMap({ (token) -> EventLoopFuture<Token> in
                return (token != nil) ? newToken.save(on: request) : newToken.create(on: request)
            })
    }

    static func update(_ request: Request) throws -> Future<Player.Public> {
        // get player email from query param
        guard let userEmail = request.query[String.self, at: "email"] else {
            throw Abort(.badRequest, reason: "Bad url path")
        }
        // find user by given email
        return Player
            .find(userEmail, on: request)
            .map({ player -> Player in
                guard let player = player else {
                    throw Abort(.notFound, reason: "Player with email: \(userEmail) not found.")
                }
                guard let eloProperty = try Player.describe(withKeyPath: \Player.elo) else {
                    throw Abort(.preconditionFailed, reason: "Property \(\Player.elo) not found at object \(type(of: Player.self))")
                }

                let newElo: Int = try request.content.syncGet(at: eloProperty)
                let newPlayer = Player(username: player.username,
                                       email: player.email,
                                       password: player.password,
                                       elo: newElo)

                return newPlayer

            }).save(on: request).convertToPublic()
    }

    static func list(_ request: Request) throws -> Future<[Player.Public]> {
        let _ = try request.requireAuthenticated(Player.self).requireID()

        return Player.query(on: request).all().map({ players -> [Player.Public] in
            return players.map { $0.convertToPublic() }
        })
    }

    static func create(_ request: Request) throws -> Future<Player.Public> {
        return try request
            .content
            .decode(Player.self)
            .map({ player -> Player in

                let encriptedPassword = try BCrypt.hash(player.password)

                return Player(username: player.username,
                              email: player.email,
                              password: encriptedPassword)

            }).create(on: request).convertToPublic()
    }

}
