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
    return try request
      .content
      .decode(Game.self)
      .create(on: request).convertToPublic()
  }
}
