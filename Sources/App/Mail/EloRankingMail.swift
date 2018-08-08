//
//  EloRankingMail.swift
//  App
//
//  Created by João Campos on 06/08/2018.
//

import Vapor
import SwiftSMTP
import HTTP

final class EloRankingMail {
    static func send(_ request: Request, to email: String, subject: String, username: String, password newPassword: String) throws -> Future<HTTPStatus> {
        guard let emailPassword = Environment.get("EMAIL_PASSWORD") else {
            throw Abort(.notFound, reason: "Password for sender email not found.")
        }

        let dir = try request.make(DirectoryConfig.self)
        let path =  dir.workDir + "Resources/Templates/recover_password.html"
        guard let data = FileManager.default.contents(atPath: path), var htmlStr = String(data: data, encoding: .utf8) else {
            throw Abort(.notFound, reason: "Email template file not found.")
        }

        let smtp = SMTP(
            hostname: "smtp.gmail.com",                  // SMTP server address
            email: "jocs.elo.ranking@gmail.com",         // username to login
            password: emailPassword                           // password to login
        )

        let sender = Mail.User(name: "Elo Ranking Team", email: "jocs.elo.ranking@gmail.com")
        let recipients = [Mail.User(name: username, email: email)]

        htmlStr = htmlStr.replacingOccurrences(of: "{Username}", with: username)
        htmlStr = htmlStr.replacingOccurrences(of: "{username:password}", with: "username : \(username) | password: \(newPassword)")

        let htmlAttachment = Attachment(
            htmlContent: htmlStr
        )

        let mail = Mail(from: sender,
                        to: recipients,
                        subject: subject,
                        attachments: [htmlAttachment])

        smtp.send(mail)

        return request.next().future().map({ _ -> HTTPStatus in
            return .ok
        })
    }
}
