//
//  Token.swift
//  App
//
//  Created by João Campos on 30/07/2018.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class Token: Codable {
    var id: String?
    var token: String
    var email: Player.ID
    
    init(token: String, email: Player.ID) {
        self.token = token
        self.email = email
        self.id = email
    }

    final class Public: Codable {
        var token: String
        var email: Player.ID

        init(token: String, email: Player.ID) {
            self.token = token
            self.email = email
        }
    }
}

extension Token {
    static func generate(for user: Player) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        
        return try Token(
            token: random.base64EncodedString(),
            email: user.requireID())
    }
}

extension Token: Model {
    typealias Database = SQLiteDatabase
    typealias ID = String
    
    public static var idKey: IDKey = \Token.id
}

extension Token: Authentication.Token {
    typealias UserType = Player
    static let userIDKey: UserIDKey = \Token.email
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

extension Token: Migration {}
extension Token: Content {}
extension Token.Public: Content {}

extension Token {
    func convertToPublic() -> Token.Public {
        return Token.Public(token: token, email: email)
    }
}

extension Future where T: Token {
    func convertToPublic() -> Future<Token.Public> {
        return self.map(to: Token.Public.self) { token in
            return token.convertToPublic()
        }
    }
}
