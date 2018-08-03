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

        let headers: [HTTPHeaderName] = [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith
        ]

        return CORSMiddleware.Configuration.init(allowedOrigin: CORSMiddleware.AllowOriginSetting.all,
                                                 allowedMethods: [
                                                    .GET,
                                                    .POST,
                                                    .PUT,
                                                    .DELETE,
                                                    .PATCH,
                                                    .OPTIONS],
                                                 allowedHeaders: headers,
                                                 allowCredentials: true,
                                                 cacheExpiration: 600,
                                                 exposedHeaders: headers.map({ $0.description }))
    }()

    func middleware() -> CORSMiddleware {
        return CORSMiddleware(configuration: eloRankingConfiguration)
    }
}
