//
//  Rating.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Foundation

fileprivate enum KFactor: CGFloat {
    
    case high = 2400
    case medium = 2100
    case low = 0
}

struct Rating {
    
    let elo: CGFloat
    let kFactor: CGFloat
    let winnerFactor: CGFloat
    
    init(currentElo: CGFloat, winner: Bool) {
        
        self.elo = currentElo
        self.kFactor = Rating.kFactor(forElo: elo)
        self.winnerFactor = winner ? 1 : 0
    }
    
    static func kFactor(forElo elo: CGFloat) -> CGFloat {
        
        if elo > KFactor.high.rawValue {
            
            return 16
            
        } else if elo > KFactor.medium.rawValue {
            
            return 24
            
        } else {
            
            return 32
        }
    }
    
    func calculate(versus challengerRating: Rating) -> Int {
        
        let exh_elo = pow(10.0, self.elo/400.0)
        let exh_challengerElo = pow(10.0, challengerRating.elo/400.0)
        let expectedOutcome = exh_elo / (exh_elo + exh_challengerElo)
        
        let newElo = self.elo + (self.kFactor * (self.winnerFactor - expectedOutcome))
        
        return Int(newElo)
    }
}
