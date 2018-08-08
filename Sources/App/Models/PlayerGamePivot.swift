//
//  PlayerGamePivot.swift
//  App
//
//  Created by João Campos on 08/08/2018.
//

import FluentPostgreSQL
import Foundation

final class PlayerGamePivot: PostgreSQLUUIDPivot {

    var id: UUID?

    var playerId: Player.ID
    var gameId: Game.ID

    typealias Left = Player
    typealias Right = Game

    static let leftIDKey: LeftIDKey = \.playerId
    static let rightIDKey: RightIDKey = \.gameId

    init(_ playerId: Player.ID, _ gameId: Game.ID) {
        self.playerId = playerId
        self.gameId = gameId
    }
}

extension PlayerGamePivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.playerId, to: \Player.id)
            builder.reference(from: \.gameId, to: \Game.id)
        } }
}
