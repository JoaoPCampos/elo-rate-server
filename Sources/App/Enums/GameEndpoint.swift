//
//  GameEndpoint.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

extension EloRankingURL {
    enum Game: String {
        case create
        case register
//        case accept
        case list
//        case winner
//        case loser

        var path: String {
            switch self {
            case .create:
                return EloRankingURL.baseURL + "game"

            case .register:
                return EloRankingURL.baseURL + "game/" + self.rawValue

            case .list:
                return EloRankingURL.baseURL + "games"
//
//            case .accept,
//                 .loser,
//                 .winner:
//                return EloRankingURL.baseURL + "game/" + self.rawValue
            }
        }
    }
}
