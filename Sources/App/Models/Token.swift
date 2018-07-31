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
    var playerId: Player.ID
    init(token: String, playerId: Player.ID) {
        self.token = token
        self.playerId = playerId
        self.id = playerId
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

extension Token: Model {
    typealias Database = SQLiteDatabase
    typealias ID = String

    public static var idKey: IDKey = \Token.id //database key
}

extension Token: Authentication.Token {
    static let userIDKey: UserIDKey = \Token.playerId
    typealias UserType = Player
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

extension Token: Migration {}
extension Token: Content {}
