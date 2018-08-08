//
//  PlayerController.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto
import Foundation

final class PlayerController {

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

    static func list(_ request: Request) throws -> Future<[Player.Public]> {
        return Player.query(on: request).all().map({ players -> [Player.Public] in
            return players.map { $0.convertToPublic() }
        })
    }

    static func find(_ request: Request) throws -> Future<Player.Public> {
        return try request.parameters.next(Player.self).convertToPublic()
    }

    static func update(_ request: Request) throws -> Future<Player.Public> {
        let oldPlayer = try request.requireAuthenticated(Player.self)
        return try request
            .content
            .decode(Player.self)
            .map({ player -> Player in

                let encriptedPassword = try BCrypt.hash(player.password)

                /// Updates only username and or password
                return Player(id: oldPlayer.id,
                              username: oldPlayer.username,
                              email: player.email, //new email
                              password: encriptedPassword) //new password
            })
            .update(on: request)
            .convertToPublic()
    }

    /// Pivot relation between Player and Game
    static func addGame(_ request: Request) throws -> Future<HTTPStatus> {

        let eventLoopCallback: (Player, Game) throws -> Future<HTTPStatus> = { player, game in
            let pivot = try PlayerGamePivot(player.requireID(),game.requireID())
            return pivot.save(on: request).transform(to: .created)
        }

        return try flatMap(to: HTTPStatus.self,
                           request.parameters.next(Player.self),
                           request.parameters.next(Game.self),
                           eventLoopCallback)
    }

    static func listGames(_ request: Request) throws -> Future<[Game]> {
        return try request
            .parameters
            .next(Player.self)
            .flatMap(to: [Game].self) { player in
                try player.games.query(on: request).all()
        }
    }
}

extension PlayerController {

    static func findPlayer( _ request: Request, byId playerId: UUID) throws -> Future<Player> {
        return Player
            .find(playerId, on: request)
            .map({ player -> Player in
                guard let player = player else {
                    throw Abort(.notFound, reason: "Player not found.")
                }
                return player
            })
    }

    static func findPlayer( _ request: Request, byEmail email: String) throws -> Future<Player> {
        return Player
            .query(on: request)
            .all()
            .map({ players -> Player in
                guard let player = players.filter({ $0.email == email }).first else {
                    throw Abort(.notFound, reason: "Player with email \(email) not found.")
                }

                return player
        })
    }
}
