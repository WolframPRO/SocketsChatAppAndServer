//
//  WSSService.swift
//  Client
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation
import Combine

let playerId = UUID()

final class WSSService {

  enum Constants {
    static let url = "localhost:8080"
    static var wssUrl = "ws://\(url)/channel"
  }

  // MARK: - Publis Properties

  var messagesPublisher: AnyPublisher<[NetworkMessage], Never> {
    messagesArray
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  private let messagesArray = CurrentValueSubject<[NetworkMessage], Never>([])

  var isConnected: AnyPublisher<Bool, Never> {
    isConnectedSubject
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  private let isConnectedSubject = CurrentValueSubject<Bool, Never>(false)

  // MARK: - Private Properties

  private let wss = WSS(stringURL: Constants.wssUrl)

  func start(name: String) {

    wss.onConnected = { [weak wss, weak self] _ in
      guard let message = WebsocketMessage(client: playerId, data: Connect(connect: true, name: name)).json() else { return }
      wss?.send(data: message)
      self?.isConnectedSubject.send(true)
    }

    wss.onDisconnected = { [weak self] reason in
      self?.messagesArray.send([])
      self?.isConnectedSubject.send(false)
    }

    wss.onText = { text in
      print(text)
    }

    wss.onBinary = { [weak self] data in
      guard let messagesArray = NetworkMessage.createArray(from: data) else { return }
      self?.messagesArray.send(messagesArray)
    }

    wss.onCancelled = { [weak self] in
      self?.messagesArray.send([])
      self?.isConnectedSubject.send(false)
    }
    let headers = [
      "Cookie": "",
      "Origin": "http://localhost:8080"
    ]
    wss.connect(headers: headers)
  }

  func send(_ input: Input) {
    guard let message = WebsocketMessage(client: playerId, data: input).json() else { return }
    wss.send(data: message)
  }

  func sendMessage(_ message: String) {
    guard let message = WebsocketMessage(client: playerId, data: NewMessage(text: message, date: Date())).json() else { return }
    wss.send(data: message)
  }

  func disconnect() {
    wss.disconnect()
  }
}

extension Encodable {
  func json() -> Data? {
    try? JSONEncoder().encode(self)
  }
}
