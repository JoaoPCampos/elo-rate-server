//
//  EloRankingCORS.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

import Foundation
import Vapor

final class EloRankingCORS {
    
    lazy private var eloRankingConfiguration: CORSMiddleware.Configuration = {
        let a = HTTPHeaderName(stringLiteral: "Accept")
        let b = HTTPHeaderName(stringLiteral: "Authorization")
        let c = HTTPHeaderName(stringLiteral: "Content-Type")
        let d = HTTPHeaderName(stringLiteral: "Origin")
        let e = HTTPHeaderName(stringLiteral: "X-Requested-With")

        return CORSMiddleware
            .Configuration
            .init(allowedOrigin:
                CORSMiddleware.AllowOriginSetting.all,

                  allowedMethods:
                [
                    .GET,
                    .POST,
                    .PUT,
                    .DELETE,
                    .PATCH,
                    .OPTIONS
                ],
                  allowedHeaders:
                [
                    a,
                    b,
                    c,
                    d,
                    e
                ],
                  allowCredentials: true,
                  cacheExpiration: 600,
                  exposedHeaders:
                [
                    "Accept",
                    "Authorization",
                    "Content-Type",
                    "Origin",
                    "X-Requested-With"
                ])
    }()

    func middleware() -> CORSMiddleware {
        return CORSMiddleware(configuration: eloRankingConfiguration)
    }
}
