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
    var username: String
    var email: String?
    var password: String
    var elo: Int

    init(username: String, email: String?, password: String, elo: Int = 1300) {
        self.username = username
        self.email = email
        self.password = password
        self.elo = elo
    }

    final class Public: Codable {
        var username: String
        var email: String?
        let elo: Int

        init(username: String, email: String?, elo: Int) {
            self.username = username
            self.email = email
            self.elo = elo
        }
    }
}

extension Player.Public: Content {}
extension Player {
    func convertToPublic() -> Player.Public {
        return Player.Public(username: username, email: email, elo: elo)
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
    public static var idKey: IDKey = \Player.email //database key
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
