//
//  Game.swift
//  App
//
//  Created by João Campos on 07/08/2018.
//

import Vapor
import Foundation
import FluentSQLite
//import FluentPostgreSQL

enum MatchStatus: String {
    
    case pending
    case ongoing
    case completed
}

final class Match: Codable {
    
    var id: UUID?
    let status: MatchStatus.RawValue
    let winner: String
    let description: String

    /// Relation a Match belongs to only 1 challenger Player
    var challengerId: Player.ID
    
    var challenger: Parent<Match, Player> {
        
        return parent(\Match.challengerId)
    }

    /// Relation a Match belongs to only 1 contender Player
    var contenderId: Player.ID
    
    var contender: Parent<Match, Player> {
        
        return parent(\Match.contenderId)
    }

    /// Relation a Match belongs to only 1 Game
    var gameId: Game.ID
    
    var game: Parent<Match, Game> {
        
        return parent(\Match.gameId)
    }

    init(id: UUID? = nil,
         gameId: Game.ID,
         status: MatchStatus.RawValue = MatchStatus.pending.rawValue,
         winner: String = "",
         description: String = "",
         challengerId: Player.ID,
         contenderId: Player.ID) {
        
        self.id = id
        self.gameId = gameId
        self.challengerId = challengerId
        self.contenderId = contenderId
        self.status = status
        self.winner = winner
        self.description = description
    }
}

extension Match: PropertyDescribable {
    
    typealias Object = Match
}
extension Match: SQLiteUUIDModel {}
extension Match: Content {}
extension Match: Parameter {}
extension Match: Migration {
    
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            
            try addProperties(to: builder)
            
            builder.reference(from: \Match.challengerId, to: \Player.id)
            builder.reference(from: \Match.contenderId, to: \Player.id)
            builder.reference(from: \Match.gameId, to: \Game.id)
        } }
}
