//
//  Player.swift
//  App
//
//  Created by João Campos on 25/07/2018.
//

import Vapor
import Foundation
import FluentSQLite
import Authentication

final class Player: Codable {
    var email: String?
    var username: String
    var password: String

    let elo: Int
    let wins: Int
    let losses: Int

    init(username: String, email: String?, password: String, elo: Int = 1300, wins: Int = 0, losses: Int = 0) {
        self.username = username
        self.email = email
        self.password = password
        self.elo = elo
        self.wins = wins
        self.losses = losses
    }

    final class Public: Codable {
        var username: String
        var email: String?

        let elo: Int
        let wins: Int
        let losses: Int

        init(username: String, email: String?, elo: Int, wins: Int, losses: Int) {
            self.username = username
            self.email = email
            self.elo = elo
            self.wins = wins
            self.losses = losses
        }
    }
}

extension Player.Public: Content {}
extension Player {
    func convertToPublic() -> Player.Public {
        return Player.Public(username: username, email: email, elo: elo, wins: wins, losses: losses)
    }
}

extension Future where T: Player {
    func convertToPublic() -> Future<Player.Public> {
        return self.map(to: Player.Public.self) { player in
            return player.convertToPublic()
        }
    }
}

extension Player: Model {
    typealias Database = SQLiteDatabase
    typealias ID = String
    public static var idKey: IDKey = \Player.email
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

extension Player: Content {}
extension Player: Parameter {}
extension Player: Migration {}
