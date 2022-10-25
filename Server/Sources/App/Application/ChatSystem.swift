//
//  File.swift
//  
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation
import Vapor

class ChatSystem {
  var clients: WebsocketClients
  var messages: [Message] = []

  var timer: DispatchSourceTimer
  var timeout: DispatchTime?

  init(eventLoop: EventLoop) {
    self.clients = WebsocketClients(eventLoop: eventLoop)

    self.timer = DispatchSource.makeTimerSource()
    self.timer.setEventHandler { [unowned self] in
      self.notify()
    }
    self.timer.schedule(deadline: .now() + .milliseconds(20), repeating: .milliseconds(20))
    self.timer.activate()
  }

  func randomRGBAColor() -> String {
    let range = (0..<255)
    let r = range.randomElement()!
    let g = range.randomElement()!
    let b = range.randomElement()!
    return "\(r),\(g),\(b)"
  }

  func connect(_ ws: WebSocket) {
    ws.onBinary { [unowned self] ws, buffer in
      if let msg = buffer.decodeWebsocketMessage(Connect.self) {
        let user = UserClient(id: msg.client,
                              socket: ws,
                              status: .init(name: msg.data.name,
                                            color: self.randomRGBAColor()))
        self.clients.add(user)
      }

      if let msg = buffer.decodeWebsocketMessage(Input.self),
         let user = self.clients.find(msg.client) as? UserClient {
        user.update(msg.data)
      }

      if let msg = buffer.decodeWebsocketMessage(NewMessage.self),
         let user = self.clients.find(msg.client) as? UserClient {
        self.messages.append(.init(id: (messages.last?.id ?? 0) + 1, text: msg.data.text, date: msg.data.date, authorId: user.id))
      }
    }
  }

  func notify() {
    if let timeout = self.timeout {
      let future = timeout + .seconds(2)
      if future < DispatchTime.now() {
        self.timeout = nil
      }
    }

    let users = self.clients.active.compactMap { $0 as? UserClient }
    guard !users.isEmpty else {
      return
    }

    users.forEach { user in
      let data = try! JSONEncoder().encode(self.messages.map { message in
        NetworkMessage(
          id: message.id,
          text: message.text,
          date: message.date,
          authorName: users.first(where: { $0.id == message.authorId })?.status.name ?? "Unknow",
          isCurrentUser: user.id == message.authorId)
      })
      user.socket.send([UInt8](data))
    }
  }

  deinit {
    self.timer.setEventHandler {}
    self.timer.cancel()
  }
}
