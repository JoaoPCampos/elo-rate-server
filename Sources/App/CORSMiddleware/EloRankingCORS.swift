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
                    HTTPMethod.GET,
                    HTTPMethod.POST,
                    HTTPMethod.PUT,
                    HTTPMethod.DELETE,
                    HTTPMethod.PATCH,
                    HTTPMethod.OPTIONS
                ],
                  allowedHeaders:
                [
                    HTTPHeaderName.accept,
                    HTTPHeaderName.authorization,
                    HTTPHeaderName.contentType,
                    HTTPHeaderName.origin,
                    HTTPHeaderName.xRequestedWith
                ],
                  allowCredentials: true,
                  cacheExpiration: 600)
    }()

    func middleware() -> CORSMiddleware {
        return CORSMiddleware(configuration: eloRankingConfiguration)
    }
}
