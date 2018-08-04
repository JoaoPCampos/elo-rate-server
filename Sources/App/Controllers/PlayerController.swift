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

    static func find(_ request: Request) throws -> Future<Player.Public> {
        guard let email = request.query[String.self, at: "email"] else {
            throw Abort(.badRequest, reason: "Missing parameter email.")
        }

        return try getPlayer(request, byEmail: email).convertToPublic()

    }
}

extension PlayerController {

    static func getPlayer( _ request: Request, byEmail email: String) throws -> Future<Player> {
        return Player
            .find(email, on: request)
            .map({ player -> Player in
                guard let player = player else {
                    throw Abort(.notFound, reason: "Player not found.")
                }

                return player
            })
    }
}
