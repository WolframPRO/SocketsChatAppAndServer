//
//  File.swift
//  
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation
import Vapor

final class UserClient: WebSocketClient {

  struct Status: Codable {
    var id: UUID!
    var name: String
    var color: String
  }

  var status: Status
  var isTyping: Bool = false


  public init(id: UUID, socket: WebSocket, status: Status) {
    self.status = status
    self.status.id = id

    super.init(id: id, socket: socket)
  }

  func update(_ input: Input) {
    isTyping = input.isTyping
  }
}
