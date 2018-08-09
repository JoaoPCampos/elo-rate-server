//
//  PlayerStats.swift
//  App
//
//  Created by João Campos on 07/08/2018.
//

import Vapor
import Foundation
import FluentPostgreSQL

final class PlayerStats: Codable {
    var id: UUID?
    let elo: Int
    let wins: Int
    let losses: Int

    /// Relation a PlayerStats belongs only to 1 Player
    var playerId: Player.ID
    var player: Parent<PlayerStats, Player> {
        return parent(\PlayerStats.playerId)
    }

    /// Relation a PlayerStats belongs only to 1 Game
    var gameId: Game.ID
    var game: Parent<PlayerStats, Game> {
        return parent(\PlayerStats.gameId)
    }

    init(id: UUID? = nil, elo: Int = 1200, wins: Int = 0, losses: Int = 0, playerId: Player.ID, gameId: Game.ID) {
        self.id = id
        self.elo = elo
        self.wins = wins
        self.losses = losses
        self.playerId = playerId
        self.gameId = gameId
    }

    public func update(_ newElo: Int, winner: Bool) -> PlayerStats {
        let updatedWins = winner ? self.wins + 1 : self.wins
        let updatedLosses = winner ? self.losses : self.losses + 1
        
        return PlayerStats(id: self.id,
                           elo: newElo,
                           wins: updatedWins,
                           losses: updatedLosses,
                           playerId: self.playerId,
                           gameId: self.gameId)
    }
}

extension PlayerStats: PostgreSQLUUIDModel {}
extension PlayerStats: Content {}
extension PlayerStats: Parameter {}
extension PlayerStats: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \PlayerStats.playerId, to: \Player.id)
            builder.reference(from: \PlayerStats.gameId, to: \Game.id)
            builder.unique(on: \PlayerStats.playerId, \PlayerStats.gameId)
        } }
}
