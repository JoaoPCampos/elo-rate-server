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
                    .accept,
                    .authorization,
                    .contentType,
                    .origin,
                    .xRequestedWith
                ],
                  allowCredentials: true,
                  cacheExpiration: 600,
                  exposedHeaders:
                [
                    "accept",
                    "authorization",
                    "content-type",
                    "origin",
                    "x-requested-with"
                ])
    }()

    func middleware() -> CORSMiddleware {
        return CORSMiddleware(configuration: eloRankingConfiguration)
    }
}
