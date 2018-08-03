//
//  EloRankingCORS.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

import Foundation
import Vapor

final class EloRankingCORS {
    
    static let middleware: CORSMiddleware = CORSMiddleware.init(configuration: configurationCORS())

    static private func configurationCORS() -> CORSMiddleware.Configuration {
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
                ])
    }
}
