//
//  MiddleWares.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Crypto
import Authentication

final class Middlewares {
    static private let playerBasicAuthMiddleware = Player.basicAuthMiddleware(using: BCryptDigest())
    static private let playerGuardAuthMiddleware = Player.guardAuthMiddleware()
    static private let tokenAuthMiddleware = Player.tokenAuthMiddleware()
    static private let adminBasicAuthMiddleware = AdminPlayer.basicAuthMiddleware(using: BCryptDigest())
    static private let adminGuardAuthMiddleware = AdminPlayer.guardAuthMiddleware()
    
    static let playerBasicAuth: [Middleware] = [playerBasicAuthMiddleware, playerGuardAuthMiddleware]
    static let playerTokenAuth: [Middleware] = [tokenAuthMiddleware, playerGuardAuthMiddleware]
    static let adminBasicAuth: [Middleware] = [adminBasicAuthMiddleware, adminGuardAuthMiddleware]
}
