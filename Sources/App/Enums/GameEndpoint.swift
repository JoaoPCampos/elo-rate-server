//
//  GameEndpoint.swift
//  App
//
//  Created by João Campos on 03/08/2018.
//
import Vapor

extension EloRankingURL {
    
    enum Game {
        
        case create
        case list

        var path: String {
            
            switch self {
            
            case .create:
                return baseURL + "game/"

            case .list:
                return baseURL + "games/"
            }
        }
    }
}
