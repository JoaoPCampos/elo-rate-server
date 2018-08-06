//
//  EmailController.swift
//  App
//
//  Created by João Campos on 05/08/2018.
//

import Vapor
import Crypto

final class EmailController {
    static func send(_ request: Request, toPlayer player: Player) throws -> Future<HTTPStatus> {
        guard let email = player.email else { return request.next().future().transform(to: .notFound) }

        let newPassword = try CryptoRandom().generateData(count: 16).base64EncodedString()

        let hashedPassword = try BCrypt.hash(newPassword)
        let updatePlayer = Player(username: player.username,
                                  email: player.email,
                                  password: hashedPassword,
                                  elo: player.elo,
                                  wins: player.wins,
                                  losses: player.losses)

        return try EloRankingMail.send(request,
                                       to: email,
                                       subject: "Recover Password",
                                       username: player.username,
                                       password: newPassword)
            .flatMap({ (status) -> EventLoopFuture<HTTPStatus> in
                return updatePlayer.update(on: request).transform(to: status)
            })
    }
}
