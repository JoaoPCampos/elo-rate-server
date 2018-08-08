//
//  GameController.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto
import Foundation

final class GameController {

    static func create(_ request: Request) throws -> Future<Game> {
        return try request
            .content
            .decode(Game.self)
            .map({ game -> Game in
                let newGame = Game(id: game.id, name: game.name)
                return newGame
            }).create(on: request)
    }

    static func list(_ request: Request) throws -> Future<[Game]> {
        return Game.query(on: request).all()
    }

    static func register(_ request: Request) throws -> Future<HTTPStatus> {
        let player = try request.requireAuthenticated(Player.self)

        return try request
            .parameters
            .next(Game.self)
            .map({ game -> PlayerStats in
                guard let playerId = player.id, let gameId = game.id else {
                    throw Abort(.notFound, reason: "Either player or game id not found.)")
                }
                return PlayerStats(playerId: playerId, gameId: gameId)
            })
            .create(on: request)
            .transform(to: .ok)
    }

    static func challenge(_ request: Request) throws -> Future<Match> {
        let challenger = try request.requireAuthenticated(Player.self)

        return try flatMap(to: Match.self,
                       request.parameters.next(Game.self),
                       request.parameters.next(Player.self)) { game, contender in
                        guard let challengerId = challenger.id,
                            let contenderId = contender.id,
                            let gameId = game.id else {
                            throw Abort(.notFound, reason: "Either challenger player id, contender player id and or game id, not found.")
                        }

                        return try existsPlayer(withId: challengerId, inGame: game, request)
                            .flatMap({ (exists) -> Future<Bool> in
                                return try existsPlayer(withId: contenderId, inGame: game, request)
                            })
                            .flatMap({ (exists) -> Future<Match> in
                                guard challengerId != contenderId else {
                                    throw Abort(.conflict, reason: "Challenger id must be different from Contender id.")
                                }
                                let match = Match(gameId: gameId,
                                                  challengerId: challengerId,
                                                  contenderId: contenderId)
                                return match.create(on: request)
                            })
        }
    }

    static func accept(_ request: Request) throws -> Future<Match> {
        return try updateMatch(request, status: MatchStatus.pending, winner: false)
    }

    static func winner(_ request: Request) throws -> Future<Match> {
        return try updateMatch(request, status: MatchStatus.ongoing, winner: true)
    }

    static func loser(_ request: Request) throws -> Future<Match> {
        return try updateMatch(request, status: MatchStatus.ongoing, winner: false)
    }
}

extension GameController {

    static private func existsPlayer(withId playerId: UUID, inGame game: Game, _ request: Request) throws -> Future<Bool> {
        return try game
            .playerStats
            .query(on: request)
            .all()
            .map({ playerStats -> Bool in
                guard let _ = playerStats.first(where: { $0.playerId == playerId } ) else {
                    throw Abort(.notFound, reason: "Player with id \(playerId) not registered in Game \(game.name)")
                }
                return true
            })
    }

    static private func updateMatch(forMatch match: Match,
                                    inGame game: Game,
                                    withStatus status: MatchStatus,
                                    winner: Bool,
                                    _ request: Request) throws -> Match {
        switch status {
        case .pending:
            return Match(id: match.id,
                         gameId: match.gameId,
                         status: MatchStatus.ongoing.rawValue,
                         challengerId: match.challengerId,
                         contenderId: match.contenderId)

        case .ongoing:

            /// Check if description property came in the request body to update Match with
            let description = try Match.describe(withKeyPath: \Match.description, for: request)
            
            /// Update elos according to match outcome
            _ = try updateElos(forMatch: match, inGame: game, asWinner: winner, request)

            return Match(id: match.id,
                         gameId: match.gameId,
                         status: MatchStatus.completed.rawValue,
                         winner: winner ? match.contenderId.uuidString : match.challengerId.uuidString,
                         description: description ?? "",
                         challengerId: match.challengerId,
                         contenderId: match.contenderId)

        case .completed:
            return match //do nothing
        }
    }

    static private func updateElos(forMatch match: Match, inGame game: Game, asWinner winner: Bool, _ request: Request) throws -> Future<HTTPStatus> {
        return try game.playerStats
            .query(on: request)
            .all()
            .flatMap({ playerStats -> EventLoopFuture<HTTPStatus> in
                let bothPlayers = playerStats.filter({ return $0.playerId == match.challengerId || $0.playerId == match.contenderId })

                guard let challengerStats = bothPlayers.filter({ return $0.playerId == match.challengerId }).first,
                    let contenderStats = bothPlayers.filter({ return $0.playerId == match.contenderId }).first else {
                        throw Abort(.notFound, reason:"Could not find either challenger player id or contender player id for game \(game.name)")
                }

                let challengerRating = Rating(currentElo: CGFloat(challengerStats.elo), winner: !winner)
                let contenderRating = Rating(currentElo: CGFloat(contenderStats.elo), winner: winner)

                let newChallengerElo = challengerRating.calculate(versus: contenderRating)
                let newContenderElo = contenderRating.calculate(versus: challengerRating)

                return challengerStats
                    .update(newChallengerElo, winner: !winner)
                    .update(on: request).flatMap({ _ -> EventLoopFuture<HTTPStatus> in
                        return contenderStats
                            .update(newContenderElo, winner: winner)
                            .update(on: request).transform(to: .ok)
                    })
            })
    }

    static private func updateMatch(_ request: Request, status: MatchStatus, winner: Bool) throws -> Future<Match> {
        let player = try request.requireAuthenticated(Player.self)
        return try flatMap(to: Match.self,
                           request.parameters.next(Game.self),
                           request.parameters.next(Match.self)) { game, match in

                            guard let playerId = player.id else {
                                throw Abort(.notFound, reason: "Player id not found")
                            }

                            guard playerId == match.contenderId else {
                                throw Abort(.forbidden, reason: "Only contender is able to update match.")
                            }

                            guard match.status == status.rawValue else {
                                throw Abort(.forbidden, reason: "Match status should be \(status.rawValue) but it is \(match.status) ")
                            }

                            return try updateMatch(forMatch: match,
                                               inGame: game,
                                               withStatus: status,
                                               winner: winner,
                                               request)
                                .update(on: request)
        }
    }
}
