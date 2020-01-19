//
//  Token.swift
//  App
//
//  Created by João Campos on 30/07/2018.
//

import Foundation
import Vapor
import Authentication
import FluentPostgreSQL

final class Token: Codable {
    
    var id: UUID?
    var token: String
    var playerId: Player.ID
    
    init(id: UUID? = nil, token: String, playerId: Player.ID) {
        
        self.id = id
        self.token = token
        self.playerId = playerId
    }

    func refresh() throws -> Token {
        
        self.token = try CryptoRandom().generateData(count: 16).base64EncodedString()
        
        return self
    }

    final class Public: Codable {
        
        let token: String
        var playerId: Player.ID

        init(token: String, playerId: Player.ID) {
            
            self.token = token
            self.playerId = playerId
        }
    }
}

extension Token {
    static func new(for user: Player) throws -> Token {
        
        let random = try CryptoRandom().generateData(count: 16)

        return try Token(token: random.base64EncodedString(),
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
        
        return Token.Public(token: token, playerId: playerId)
    }
}

extension Future where T: Token {
    
    func convertToPublic() -> Future<Token.Public> {
        
        return self.map(to: Token.Public.self) { token in
            
            return token.convertToPublic()
        }
    }
}
