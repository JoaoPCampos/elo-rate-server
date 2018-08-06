//
//  EmailController.swift
//  App
//
//  Created by João Campos on 05/08/2018.
//

import Vapor
import Crypto

final class EmailController {
    static func send(_ request: Request, toPlayer player: Player) throws -> Future<Void> {
        guard let email = player.email else { return request.next().future() }
        let newPassword = try CryptoRandom().generateData(count: 16).base64EncodedString()
        let hashedPassword = try BCrypt.hash(newPassword)
        let updatePlayer = Player(username: player.username,
                                  email: player.email,
                                  password: hashedPassword,
                                  elo: player.elo,
                                  wins: player.wins,
                                  losses: player.losses)

        return updatePlayer
            .save(on: request)
            .flatMap({ player -> EventLoopFuture<Response> in

                let message = Mailgun.Message(
                    from: "noreply@elo.ranking.com",
                    to: email,
                    subject: "Recover password",
                    text: "New Credencials",
                    html: "<body><dl><dt><b>Username: </b>\(player.username)</dt><dt><b>Password: </b>\(newPassword)</dt></dl></body>"
                )

                return try request.make(Mailgun.self)
                    .send(message, on: request)
            })
            .map({ _ -> Void in })
    }
}
