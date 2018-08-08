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

    var playerId: Player.ID
    var player: Parent<PlayerStats, Player> {
        return parent(\PlayerStats.playerId)
    }

    init(id: UUID? = nil, elo: Int = 1300, wins: Int = 0, losses: Int = 0, playerId: Player.ID) {
        self.id = id
        self.elo = elo
        self.wins = wins
        self.losses = losses
        self.playerId = playerId
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
        } }
}
