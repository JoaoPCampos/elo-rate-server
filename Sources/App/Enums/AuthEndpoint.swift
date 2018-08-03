//
//  AuthEndPoint.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

extension EloRankingURL {
    enum Auth: String {
        case login
        case logout

        var path: String {
            return baseURL + "auth/" + self.rawValue
        }
    }
}
