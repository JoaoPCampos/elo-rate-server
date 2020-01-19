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
        case none
    }
    
    private let authType: AuthType
    
    private init(authType: AuthType) {
        
        self.authType = authType
    }

    static let simple: [Middleware] = [APIMiddleware(authType: .none)]
    
    static let playerBasicAuth: [Middleware] = [APIMiddleware(authType: .basic),
                                                Player.basicAuthMiddleware(using: BCryptDigest()),
                                                Player.guardAuthMiddleware()]
    
    static let playerTokenAuth: [Middleware] = [APIMiddleware(authType: .token),
                                                Player.tokenAuthMiddleware(),
                                                Player.guardAuthMiddleware()]
}

extension APIMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        switch authType {
            
        case .basic:
            
            guard let basicAuth = request.http.headers.basicAuthorization else {
                
                throw Abort(.notFound, reason: "Authorization header missing")
            }
            
            return Player.query(on: request).all().flatMap { players -> EventLoopFuture<Response> in
                
                guard !players.isEmpty else { throw Abort(.notFound, reason: "There are no players registered")}
                
                guard !players.filter({ $0.username == basicAuth.username }).isEmpty else {
                    
                    throw Abort(.expectationFailed, reason: "Wrong username or password")
                }
                
                return try next.respond(to: request)
            }
            
        case .token:
            
            guard let bearerHeader = request.http.headers.bearerAuthorization else {
                
                throw Abort(.notFound, reason: "Authorization header missing")
            }
            
            return Token.query(on: request).all().flatMap({ tokens -> EventLoopFuture<Response> in
                
                guard !tokens.filter({ $0.token == bearerHeader.token }).isEmpty else {
                    
                    throw Abort(.unauthorized, reason: "Token is invalid, please login to request a new one.")
                }
                
                return try next.respond(to: request)
            })

        case .none:
            
            return try next.respond(to: request).catchFlatMap({ error -> (EventLoopFuture<Response>) in
                
                throw Abort(.notFound, reason: error.localizedDescription)
            })
        }
    }
}
