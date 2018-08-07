//
//  Game.swift
//  App
//
//  Created by João Campos on 31/07/2018.
//

import Vapor
import Foundation
import FluentPostgreSQL

enum GameStatus: Int {
    case pending = 0
    case accepted
    case completed
    case aborted
}

final class Game: Codable {
    var id: Int?
    var challengerEmail: String
    let contenderEmail: String
    let name: String
    let challenger: String
    let contender: String
    let status: Int
    
    init(id: Int? = nil, name: String, challengerEmail: String, contenderEmail: String, challenger: String, contender: String, status: Int = GameStatus.pending.rawValue) {
        self.id = id
        self.name = name
        self.challengerEmail = challengerEmail
        self.contenderEmail = contenderEmail
        self.challenger = challenger
        self.contender = contender
        self.status = status
    }

    final class Create: Codable {
        let name: String

        init(name: String, contenderEmail: String) {
            self.name = name
        }
    }
    
    final class Public: Codable {
        let name: String
        let challenger: String
        let contender: String
        let status: Int
        
        init(name: String, challenger: String, contender: String, status: Int) {
            self.name = name
            self.challenger = challenger
            self.contender = contender
            self.status = status
        }
    }
}

extension Game: PostgreSQLModel {
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    public static var idKey: IDKey = \Game.id
}
extension Game: Content {}
extension Game: Parameter {}
extension Game: Migration {}

extension Game.Public: Content {}

extension Game {
    func convertToPublic() -> Game.Public {
        return Game.Public(name: name, challenger: challenger, contender: contender, status: status)
    }
}

extension Future where T: Game {
    func convertToPublic() -> Future<Game.Public> {
        return self.map(to: Game.Public.self) { game in
            return game.convertToPublic()
        }
    }
}
