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
        guard let playerId = try request.requireAuthenticated(Player.self).id else {
            throw Abort(.notFound, reason: "Player needs to be authenticated or doesn´t exist.")
        }

        return try request
            .content
            .decode(Game.self)
            .map({ game -> Game in
                let newGame = Game(id: game.id, name: game.name)
                return newGame
            }).create(on: request)
    }

    static func register(_ request: Request) throws -> Future<Game> {
        guard let playerId = try request.requireAuthenticated(Player.self).id else {
            throw Abort(.notFound, reason: "Player needs to be authenticated or doesn´t exist.")
        }
        guard let gameId = request.query[UUID.self, at: "gameId"] else {
            throw Abort(.badRequest, reason: "Missing game id parameter.")
        }

        return Game
            .find(gameId, on: request)
            .map({ game -> Game in
                guard let game = game else {
                    throw Abort(.notFound, reason: "Game with id \(gameId) not found.")
                }
                let updateGame = Game(id: game.id, name: game.name)
                return updateGame
            }).create(on: request)

//        return try request
//            .content
//            .decode(Game.Public.self)
//            .map({ game -> Game in
//                var players = game.players
//                players?.append(player.convertToPublic())
//                let updateGame = Game(id: game.id, name: game.name, players: players)
//                return newGame
//            }).create(on: request).convertToPublic()
    }

//    static func accept(_ request: Request) throws -> Future<Game.Public> {
//        let player = try request.requireAuthenticated(Player.self)
//
//        return Game
//            .query(on: request)
//            .all()
//            .map({ games -> Game in
//                guard let game = games.filter({ $0.contender.id == player.id }).first else {
//                    throw Abort(.unauthorized, reason: "\(player.username) is not able to accept challenge")
//                }
//
//
//                let acceptedGame = Game(id: game.id,
//                                        name: game.name,
//                                        challenger: game.challenger,
//                                        contender: game.contender,
//                                        status: GameStatus.accepted.rawValue)
//                return acceptedGame
//            })
//            .update(on: request).convertToPublic()
//    }

//    static func list(_ request: Request) throws -> Future<[Game]> {
//        let player = try request.requireAuthenticated(Player.self)
//
//        return try player.games.query(on: request).all()
//    }

//    static func winner(_ request: Request) throws -> Future<HTTPStatus> {
//        return try update(request, isWinner: true)
//    }
//
//    static func loser(_ request: Request) throws -> Future<HTTPStatus> {
//        return try update(request, isWinner: false)
//    }
}

extension GameController {

//    private static func create(game: Game.Create, versus contenderId: UUID, _ request: Request) throws -> Future<Game> {
//        let player = try request.requireAuthenticated(Player.self)
//
//        guard player.id != contenderId else {
//            throw Abort(.conflict, reason: "Challenger \(player.username) must be different from contender.")
//        }
//
//        return try PlayerController
//            .findPlayer(request, byId: contenderId)
//            .map({ contender -> Game in
//                return Game(name: game.name,
//                            challenger: player.convertToPublic(),
//                            contender: contender.convertToPublic())
//            }).create(on: request)
//    }

//    private static func update(_ request: Request, isWinner: Bool) throws -> Future<HTTPStatus> {
//        let player = try request.requireAuthenticated(Player.self)
//
//        return Game
//            .query(on: request)
//            .all()
//            .map({ games -> Game in
//                guard let game = games.filter({ $0.challenger.id == player.id }).first else {
//                    throw Abort(.unauthorized, reason: "\(player.username) is not able to update challenge")
//                }
//
//                let updatedGame = Game(id: game.id,
//                                       name: game.name,
//                                       challenger: game.challenger,
//                                       contender: game.contender,
//                                       status: GameStatus.completed.rawValue)
//
//                return updatedGame
//            })
//            .update(on: request)
//            .flatMap({ game -> EventLoopFuture<HTTPStatus> in
//                return try updateElo(request, game: game, isWinner: isWinner)
//            })
//    }

//    static func updateElo(_ request: Request, game: Game, isWinner: Bool) throws -> Future<HTTPStatus> {
//        let player = try request.requireAuthenticated(Player.self)
//        guard let contenderId = game.contender.id else {
//            throw Abort(.notFound, reason: "Contender id not found on game.")
//        }
//
//        return try PlayerController
//            .findPlayer(request, byId: contenderId)
//            .flatMap({ (contender) -> EventLoopFuture<Player> in
//                let contenderRating = Rating(currentElo: CGFloat(contender.elo), winner: !isWinner)
//
//                let updatedContender = Player(id: contender.id,
//                                              username: contender.username,
//                                              email: contender.email,
//                                              password: contender.password,
//                                              elo: contenderRating.calculate(versusElo: player.elo),
//                                              wins: contender.wins,
//                                              losses: contender.losses)
//                return updatedContender.update(on: request)
//                    .flatMap({ newContender -> EventLoopFuture<Player> in
//
//                        let meRating = Rating(currentElo: CGFloat(player.elo), winner: isWinner)
//
//                        let updatedMe = Player(id: player.id,
//                                               username: player.username,
//                                               email: player.email,
//                                               password: player.password,
//                                               elo: meRating.calculate(versusElo: contender.elo),
//                                               wins: player.wins,
//                                               losses: player.losses)
//                        return updatedMe.update(on: request)
//                    })
//            }).transform(to: .ok)
//    }
}
