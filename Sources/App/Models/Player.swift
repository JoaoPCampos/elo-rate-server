//
//  Player.swift
//  App
//
//  Created by João Campos on 25/07/2018.
//

import Vapor
import Foundation
import Authentication
import FluentPostgreSQL
//import FluentPostgreSQL

final class Player: Codable {
    var id: UUID?
    var email: String
    var username: String
    var password: String

    /// Relation 1 Player for * PlayerStats
    var playerStats: Children<Player, PlayerStats> {
        return children(\PlayerStats.playerId)
    }

    /// Relation 1 Player for * matches as challenger
    var matchesAsChallenger: Children<Player, Match> {
        return children(\Match.challengerId)
    }

    /// Relation 1 Player for * matches as contender
    var matchesAsContender: Children<Player, Match> {
        return children(\Match.contenderId)
    }

    init(id: UUID? = nil, username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
        self.id = id
    }

    final class Public: Codable {
        var id: UUID?
        var username: String
        var email: String

        init(id: UUID? = nil, username: String, email: String) {
            self.username = username
            self.email = email
            self.id = id
        }
    }
}

extension Player: PostgreSQLUUIDModel {}
extension Player: Content {}
extension Player: Parameter {}
extension Player: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \Player.email)
            builder.unique(on: \Player.username)
        } }
}

extension Player.Public: Content {}
extension Player {
    func convertToPublic() -> Player.Public {
        return Player.Public(id: id, username: username, email: email)
    }
}

extension Future where T: Player {
    func convertToPublic() -> Future<Player.Public> {
        return self.map(to: Player.Public.self) { player in
            return player.convertToPublic()
        }
    }
}

extension Player: PropertyDescribable {
    typealias Object = Player
}

extension Player: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \Player.username
    static let passwordKey: PasswordKey = \Player.password
}

extension Player: TokenAuthenticatable {
    typealias TokenType = Token
}
