//
//  AuthEndPoint.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

extension EloRankingURL {
    enum Auth {
        case login
        case logout
        case recover

        var path: String {
            switch self {
            case .login:
                return baseURL + "auth/login/"

            case .logout:
                return baseURL + "auth/logout/"

            case .recover:
                return baseURL + "auth/recover/"
            }
        }
    }
}
