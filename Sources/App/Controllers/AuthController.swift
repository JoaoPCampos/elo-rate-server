//
//  AuthController.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto

final class AuthController {
    
    static func login(_ request: Request) throws -> Future<Token.Public> {
        let player = try request.requireAuthenticated(Player.self)
        let newToken = try Token.generate(for: player)
        
        guard let email = player.email else { throw Abort(.unauthorized, reason: "unauthorized Player") }
        
        return Token
            .find(email, on: request)
            .flatMap({ (token) -> EventLoopFuture<Token> in
                return (token != nil) ? newToken.update(on: request) : newToken.create(on: request)
            }).convertToPublic()
    }
    
    static func logout(_ request: Request) throws -> Future<HTTPStatus> {
        guard let email = try request.requireAuthenticated(Player.self).email else {
            throw Abort(.unauthorized, reason: "unauthorized Player")
        }
        
        return Token
            .query(on: request)
            .all()
            .map ({ (tokens) -> Token in
                guard let token = tokens.filter( { token in token.email == email } ).first else {
                    throw Abort(.notFound, reason: "Token for player with email \(email) not found.")
                }
                return token
                
            }).delete(on: request)
            .transform(to: .ok)
    }

    static func recover(_ request: Request) throws -> Future<HTTPStatus> {
        guard let email = request.query[String.self, at: "email"] else {
            throw Abort(.badRequest, reason: "Missing email parameter.")
        }

        return Player
            .find(email, on: request)
            .flatMap({ player -> Future<Void> in
                guard let player = player else { return request.next().future() }
                return try EmailController.send(request, toPlayer: player)
            }).transform(to: .ok)
    }


}
