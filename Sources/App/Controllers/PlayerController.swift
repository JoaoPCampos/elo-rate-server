//
//  PlayerController.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto

final class PlayerController {

    static func create(_ request: Request) throws -> Future<Player.Public> {
        return try request
            .content
            .decode(Player.Create.self)
            .map({ player -> Player in

                let encriptedPassword = try BCrypt.hash(player.password)

                return Player(username: player.username,
                              email: player.email,
                              password: encriptedPassword)

            }).create(on: request).convertToPublic()
    }

    static func list(_ request: Request) throws -> Future<[Player.Public]> {
        return Player.query(on: request).all().map({ players -> [Player.Public] in
            return players.map { $0.convertToPublic() }
        })
    }

    static func get(_ request: Request) throws -> Future<Player.Public> {
        guard let playerId = request.query[String.self, at: "playerId"] else {
            throw Abort(.badRequest, reason: "Missing parameter playerId.")
        }

        return try getPlayer(byId: playerId, request).convertToPublic()

    }
}

extension PlayerController {

    static func getPlayer(byId playerId: String, _ request: Request) throws -> Future<Player> {
        return Player
            .find(playerId, on: request)
            .map({ player -> Player in
                guard let player = player else {
                    throw Abort(.notFound, reason: "Player not found.")
                }

                return player
            })
    }
}
