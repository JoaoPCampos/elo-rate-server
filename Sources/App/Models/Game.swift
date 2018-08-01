//
//  Game.swift
//  App
//
//  Created by João Campos on 31/07/2018.
//

import Vapor
import Foundation
import FluentSQLite
import Authentication

final class Game: Codable {
    var id: Int?
    var challengerId: String
    let contenderId: String
    let name: String
    let challenger: String
    let contender: String

    init(name: String, challengerId: String, contenderId: String, challenger: String, contender: String) {
        self.name = name
        self.challengerId = challengerId
        self.contenderId = contenderId
        self.challenger = challenger
        self.contender = contender
    }

    final class Public: Codable {

        let name: String
        let challenger: String
        let contender: String

        init(name: String, challenger: String, contender: String) {
            self.name = name
            self.challenger = challenger
            self.contender = contender
        }
    }
}

extension Game: Model {
    typealias Database = SQLiteDatabase
    typealias ID = Int
    public static var idKey: IDKey = \Game.id
}
extension Game: Content {}
extension Game: Parameter {}
extension Game: Migration {}

extension Game.Public: Content {}

extension Game {
    func convertToPublic() -> Game.Public {
        return Game.Public(name: name, challenger: challenger, contender: contender)
    }
}

extension Future where T: Game {
    func convertToPublic() -> Future<Game.Public> {
        return self.map(to: Game.Public.self) { game in
            return game.convertToPublic()
        }
    }
}
