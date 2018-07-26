//
//  CrudController.swift
//  App
//
//  Created by João Campos on 26/07/2018.
//

import Vapor

final class CrudController {
    static func create(_ request: Request) throws -> Future<Player> {
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

                let elo: Int = try request.content.syncGet(at: eloProperty)
                let newPlayer = Player(name: player.name, email: player.email, elo: elo)

                return newPlayer

            }).save(on: request)
    }

    static func list(_ request: Request) throws -> Future<[Player]> {
        return Player.query(on: request).all()
    }

    static func update(_ request: Request) throws -> Future<Player> {
        return try request.content.decode(Player.self).create(on: request)
    }

}
