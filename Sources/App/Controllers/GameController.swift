//
//  GameController.swift
//  App
//
//  Created by João Campos on 01/08/2018.
//

import Vapor
import Crypto

final class GameController {

    static func create(_ request: Request) throws -> Future<Game.Public> {

        guard let contenderId = request.query[String.self, at: "contenderId"] else {
            throw Abort(.badRequest, reason: "Missing contender id")
        }

        return try request
            .content
            .decode(Game.Create.self)
            .map({ game -> Future<Game> in
                return try create(game: game, versus: contenderId, request)
            }).flatMap({ (newGame) -> EventLoopFuture<Game.Public> in
                return newGame.convertToPublic()
            })
    }

    static func accept(_ request: Request) throws -> Future<Game.Public> {
        let player = try request.requireAuthenticated(Player.self)
        guard let email = player.email else { throw Abort(.unauthorized, reason: "unauthorized Player") }

        return Game
            .query(on: request)
            .all()
            .map({ games -> Game in
                guard let game = games.filter({ $0.contenderId == email }).first else {
                    throw Abort(.unauthorized, reason: "\(player.username) is not able to accept challenge")
                }

                let acceptedGame = Game(name: game.name,
                                        challengerId: game.challengerId,
                                        contenderId: game.contenderId,
                                        challenger: game.challenger,
                                        contender: game.contender,
                                        status: GameStatus.accepted.rawValue)

                return acceptedGame
            })
            .save(on: request).convertToPublic()
    }

    static func list(_ request: Request) throws -> Future<[Game.Public]> {
        let player = try request.requireAuthenticated(Player.self)
        guard let email = player.email else { throw Abort(.unauthorized, reason: "unauthorized Player") }

        return Game
            .query(on: request)
            .all()
            .map({ games -> [Game.Public] in
                return games
                    .filter({ $0.challengerId == email || $0.contenderId == email})
                    .map({ return $0.convertToPublic() })
            })
    }

    static func winner(_ request: Request) throws -> Future<HTTPStatus> {
        return try update(request, isWinner: true)
    }

    static func loser(_ request: Request) throws -> Future<HTTPStatus> {
        return try update(request, isWinner: false)
    }
}

extension GameController {

    private static func create(game: Game.Create, versus contenderId: String, _ request: Request) throws -> Future<Game> {
        let player = try request.requireAuthenticated(Player.self)
        guard let email = player.email else { throw Abort(.unauthorized, reason: "unauthorized Player") }

        guard player.email != contenderId else {
            throw Abort(.conflict, reason: "Challenger \(player.username) must be different from contender.")
        }

        return try PlayerController
            .getPlayer(byId: contenderId, request)
            .map({ contender -> Game in
                return Game(name: game.name,
                            challengerId: email,
                            contenderId: contenderId,
                            challenger: player.username,
                            contender: contender.username)
            }).create(on: request)
    }

    private static func update(_ request: Request, isWinner: Bool) throws -> Future<HTTPStatus> {
        let player = try request.requireAuthenticated(Player.self)

        guard let email = player.email else { throw Abort(.unauthorized, reason: "unauthorized Player") }

        return Game
            .query(on: request)
            .all()
            .map({ games -> Game in
                guard let game = games.filter({ $0.challengerId == email }).first else {
                    throw Abort(.unauthorized, reason: "\(player.username) is not able to update challenge")
                }

                let updatedGame = Game(name: game.name,
                                       challengerId: game.challengerId,
                                       contenderId: game.contenderId,
                                       challenger: game.challenger,
                                       contender: game.contender,
                                       status: GameStatus.completed.rawValue)

                return updatedGame
            })
            .save(on: request)
            .flatMap({ game -> EventLoopFuture<HTTPStatus> in
                return try updateElo(request, game: game, isWinner: isWinner)
            })
    }

    static func updateElo(_ request: Request, game: Game, isWinner: Bool) throws -> Future<HTTPStatus> {
        let player = try request.requireAuthenticated(Player.self)

        return try PlayerController
            .getPlayer(byId: game.contenderId, request)
            .flatMap({ (contender) -> EventLoopFuture<Player> in
                let contenderRating = Rating(currentElo: CGFloat(contender.elo), winner: !isWinner)

                let updatedContender = Player(username: contender.username,
                                              email: contender.email,
                                              password: contender.password,
                                              elo: contenderRating.calculate(versusElo: player.elo),
                                              wins: contender.wins,
                                              losses: contender.losses)
                return updatedContender.save(on: request)
                    .flatMap({ newContender -> EventLoopFuture<Player> in

                        let meRating = Rating(currentElo: CGFloat(player.elo), winner: isWinner)

                        let updatedMe = Player(username: player.username,
                                               email: player.email,
                                               password: player.password,
                                               elo: meRating.calculate(versusElo: contender.elo),
                                               wins: player.wins,
                                               losses: player.losses)
                        return updatedMe.save(on: request)
                    })
            }).transform(to: .ok)
    }
}
