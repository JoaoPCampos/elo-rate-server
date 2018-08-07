//
//  Game.swift
//  App
//
//  Created by João Campos on 07/08/2018.
//

import Vapor
import Foundation
import FluentPostgreSQL

enum MatchStatus: String {
    case pending
    case ongoing
    case completed
    case aborted
}

final class Match: Codable {
    var id: UUID?
    let status: MatchStatus.RawValue
    var challenger: Player.ID
    var contender: Player.ID

    init(id: UUID? = nil, challenger: Player.ID, contender: Player.ID, status: MatchStatus.RawValue) {
        self.id = id
        self.challenger = challenger
        self.contender = contender
        self.status = status
    }
}

extension Match: PostgreSQLUUIDModel {}
extension Match: Content {}
extension Match: Parameter {}
extension Match: Migration {}
