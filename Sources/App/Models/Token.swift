//
//  Token.swift
//  App
//
//  Created by João Campos on 30/07/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String
    var playerId: Player.ID
    
    init(token: String, playerId: Player.ID) {
        self.token = token
        self.playerId = playerId
    }

    final class Public: Codable {
        var token: String

        init(token: String) {
            self.token = token
        }
    }
}

extension Token {
    static func generate(for user: Player) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        
        return try Token(
            token: random.base64EncodedString(),
            playerId: user.requireID())
    }
}

extension Token: PostgreSQLUUIDModel {}

extension Token: Authentication.Token {
    typealias UserType = Player
    static let userIDKey: UserIDKey = \Token.playerId
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

extension Token: Migration {}
extension Token: Content {}
extension Token.Public: Content {}

extension Token {
    func convertToPublic() -> Token.Public {
        return Token.Public(token: token)
    }
}

extension Future where T: Token {
    func convertToPublic() -> Future<Token.Public> {
        return self.map(to: Token.Public.self) { token in
            return token.convertToPublic()
        }
    }
}
