//
//  PlayerEndpoint.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

extension EloRankingURL {
    enum Player: String {
        case create
        case list
        case find
        case update

        var path: String {
            switch self {
            case .create,
                 .find:
                return baseURL + "player"
                
            case .list:
                return baseURL + "players"

            case .update:
                return baseURL + self.rawValue
            }
        }
    }
}
