//
//  Player.swift
//  App
//
//  Created by João Campos on 25/07/2018.
//

import Vapor
import FluentSQLite

struct Player: Codable {
    let name: String
    var email: String?
    let elo: Int

    init(name: String, email: String) {
        self.name = name
        self.email = email
        self.elo = 1300
    }
}

extension Player: Model {
    typealias Database = SQLiteDatabase
    typealias ID = String
    public static var idKey: IDKey = \Player.email //database key
}
extension Player: Content {}
extension Player: Migration {}
