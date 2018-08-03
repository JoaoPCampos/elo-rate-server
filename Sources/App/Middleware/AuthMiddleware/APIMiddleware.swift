//
//  APIMiddleware.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

import Vapor
import Crypto
import HTTP

final class APIMiddleware {

    private enum AuthType {
        case basic
        case token
    }

    private let authType: AuthType

    private init(authType: AuthType) {
        self.authType = authType
    }

    static let playerBasicAuth: [Middleware] = [
        APIMiddleware(authType: .basic),
        Player.basicAuthMiddleware(using: BCryptDigest()),
        Player.guardAuthMiddleware()]

    static let playerTokenAuth: [Middleware] = [
        APIMiddleware(authType: .token),
        Player.tokenAuthMiddleware(),
        Player.guardAuthMiddleware()]

    static let adminBasicAuth: [Middleware] = [
        APIMiddleware(authType: .basic),
        AdminPlayer.basicAuthMiddleware(using: BCryptDigest()),
        AdminPlayer.guardAuthMiddleware()]
}

extension APIMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        switch authType {
        case .basic:

            break

        case .token:

            break
        }
        return try next.respond(to: request)
    }
}
