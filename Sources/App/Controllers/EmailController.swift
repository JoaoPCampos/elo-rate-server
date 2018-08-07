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

        let newPassword = try CryptoRandom().generateData(count: 16).base64EncodedString()

        let hashedPassword = try BCrypt.hash(newPassword)
        let updatePlayer = Player(id: player.id,
                                  username: player.username,
                                  email: player.email,
                                  password: hashedPassword)

        return try EloRankingMail.send(request,
                                       to: player.email,
                                       subject: "Recover Password",
                                       username: player.username,
                                       password: newPassword)
            .flatMap({ (status) -> EventLoopFuture<HTTPStatus> in
                return updatePlayer.update(on: request).transform(to: status)
            })
    }
}
