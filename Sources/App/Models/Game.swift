//
//  Game.swift
//  App
//
//  Created by João Campos on 31/07/2018.
//

import Vapor
import Foundation
import FluentPostgreSQL

final class Game: Codable {
    var id: UUID?
    let name: String

    var players: Siblings<Game, Player, PlayerGamePivot> {
        return siblings()
    }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Game: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \Game.name)
        } }
}

extension Game: PostgreSQLUUIDModel {}
extension Game: Content {}
extension Game: Parameter {}
