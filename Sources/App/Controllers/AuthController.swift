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
        guard let playerId = player.id else {
            throw Abort(.notFound, reason: "Player not found")
        }

        let newToken = try Token.generate(for: player)

        return Token
            .find(playerId, on: request)
            .flatMap({ (token) -> EventLoopFuture<Token> in
                return (token != nil) ? newToken.update(on: request) : newToken.create(on: request)
            }).convertToPublic()
    }
    
    static func logout(_ request: Request) throws -> Future<HTTPStatus> {
        let player = try request.requireAuthenticated(Player.self)
        
        return Token
            .query(on: request)
            .all()
            .map ({ (tokens) -> Token in
                guard let token = tokens.filter( { token in token.playerId == player.id } ).first else {
                    throw Abort(.notFound, reason: "Token for player with email \(player.email) not found.")
                }
                return token
                
            }).delete(on: request)
            .transform(to: .accepted)
    }

    static func recover(_ request: Request) throws -> Future<HTTPStatus> {
        guard let email = request.query[String.self, at: "email"] else {
            throw Abort(.badRequest, reason: "Missing email parameter.")
        }

        return try PlayerController
            .findPlayer(request, byEmail: email)
            .flatMap({ player -> EventLoopFuture<HTTPStatus> in
                return try EmailController.send(request, toPlayer: player)
            })
    }
}
