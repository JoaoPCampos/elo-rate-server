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

    static func stats(_ request: Request) throws -> Future<[PlayerStats]> {
        let player = try request.requireAuthenticated(Player.self)

        return try player
            .playerStats
            .query(on: request)
            .all()
    }

    static func matches(_ request: Request) throws -> Future<[Match]> {
        let player = try request.requireAuthenticated(Player.self)

        return try player
            .matchesAsChallenger
            .query(on: request)
            .all()
            .flatMap({ challengerMatches -> EventLoopFuture<[Match]> in
                return try player
                    .matchesAsContender
                    .query(on: request)
                    .all().map({ (contenderMatches) -> [Match] in
                        var allMatches = challengerMatches
                        allMatches.append(contentsOf: contenderMatches)
                        return allMatches
                    })
            })
    }

    static func find(_ request: Request) throws -> Future<Player.Public> {
        return try request.parameters.next(Player.self).convertToPublic()
    }

    static func update(_ request: Request) throws -> Future<Player.Public> {
        return try createUpdatedPlayer(from: request)
            .update(on: request)
            .convertToPublic()
    }
}

extension PlayerController {
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

    static private func createUpdatedPlayer(from request: Request) throws -> Player {
        let oldPlayer = try request.requireAuthenticated(Player.self)

        /// Check which properties came in the request body to update Player with
        let username: String? = try Player.describe(withKeyPath: \Player.username, for: request)
        let email: String? = try Player.describe(withKeyPath: \Player.email, for: request)
        let password: String? = try Player.describe(withKeyPath: \Player.password, for: request)

        var encriptedpassword = oldPlayer.password
        if let password = password {
            encriptedpassword = try BCrypt.hash(password)
        }

        return Player(id: oldPlayer.id,
                      username: username ?? oldPlayer.username,
                      email: email ?? oldPlayer.email,
                      password: encriptedpassword)
    }
}
