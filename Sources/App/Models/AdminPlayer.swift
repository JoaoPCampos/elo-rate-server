//
//  AdminPlayer.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto
import Foundation
import FluentSQLite
import Authentication

final class AdminPlayer: Codable {
    var email: String?
    var username: String
    var password: String
    
    init(username: String, email: String?, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
    
    final class Public: Codable {
        var username: String
        var email: String?
        
        init(username: String, email: String?) {
            self.username = username
            self.email = email
        }
    }
}

extension AdminPlayer.Public: Content {}
extension AdminPlayer {
    func convertToPublic() -> AdminPlayer.Public {
        return AdminPlayer.Public(username: username, email: email)
    }
}

extension Future where T: AdminPlayer {
    func convertToPublic() -> Future<AdminPlayer.Public> {
        return self.map(to: AdminPlayer.Public.self) { admin in
            return admin.convertToPublic()
        }
    }
}

extension AdminPlayer: Model {
    typealias Database = SQLiteDatabase
    typealias ID = String
    public static var idKey: IDKey = \AdminPlayer.email
}

extension AdminPlayer: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \AdminPlayer.username
    static let passwordKey: PasswordKey = \AdminPlayer.password
}

extension AdminPlayer: Content {}
extension AdminPlayer: Parameter {}
extension AdminPlayer: Migration {}

//To create an admin player at server start
struct Admin: Migration {
    typealias Database = SQLiteDatabase
    
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        let password = try? BCrypt.hash("123j0cs")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let adminPlayer = AdminPlayer(username: "j0cs_Admin",
                                      email: "admin@email.com",
                                      password: hashedPassword)
        
        return adminPlayer.create(on: connection).transform(to: ())
    }
    
    static func revert(on connection: SQLiteConnection) -> Future<Void> {
        return .done(on: connection)
    }
}
