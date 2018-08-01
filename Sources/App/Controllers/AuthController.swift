//
//  AuthController.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto

final class AuthController {
  static func login(_ request: Request) throws -> Future<Token> {
    let player = try request.requireAuthenticated(Player.self)
    let newToken = try Token.generate(for: player)

    guard let email = player.email else { throw Abort(.unauthorized, reason: "Bad credentials") }

    return Token
      .find(email, on: request)
      .flatMap({ (token) -> EventLoopFuture<Token> in
        return (token != nil) ? newToken.save(on: request) : newToken.create(on: request)
      })
  }

  static func logout(_ request: Request) throws -> Future<HTTPStatus> {
    guard let tokenId = request.query[String.self, at: "tokenId"] else {
      throw Abort(.badRequest, reason: "Bad url path")
    }
    return Token
      .find(tokenId, on: request)
      .map({ token -> Token in
        guard let token = token else {
          throw Abort(.notFound, reason: "Token with id: \(tokenId) not found.")
        }
        return token
      })
      .delete(on: request)
      .transform(to: .ok)
  }
}
