//
//  Player.swift
//  App
//
//  Created by João Campos on 25/07/2018.
//

import Vapor
import FluentSQLite

protocol PropertyDescribable: Reflectable {
    associatedtype Object: Reflectable
}

extension PropertyDescribable {
    static func describe<T>(withKeyPath keyPath: KeyPath<Object, T>) throws -> String? {
        guard let property = try Object.reflectProperty(forKey: keyPath)?.description.split(separator: ":")[0] else {
            return nil
        }
        return String(property)
    }
}

struct Player: Codable {
    let name: String
    var email: String?
    let elo: Int

    init(name: String, email: String?, elo: Int = 1300) {
        self.name = name
        self.email = email
        self.elo = elo
    }
}

extension Player: Model {
    typealias Database = SQLiteDatabase
    typealias ID = String
    public static var idKey: IDKey = \Player.email //database key
}
extension Player: Content {}
extension Player: Parameter {}
extension Player: Migration {}
extension Player: PropertyDescribable {
    typealias Object = Player
}
