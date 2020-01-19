//
//  PlayerEndpoint.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//

extension EloRankingURL {
    
    enum Player {
        
        case create
        case list
        case find
        case update
        case stats
        case matches

        var path: String {
            
            switch self {
            
            case .create, .find:
                return baseURL + "player/"
                
            case .list:
                return baseURL + "players/"

            case .update:
                return baseURL + "player/update/"

            case .stats:
                return baseURL + "player/stats/"

            case .matches:
                return baseURL + "player/matches/"
            }
        }
    }
}
