//
//  WSS.swift
//  Client
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket
import WebSocketKit

final class WSS: WebSocketProtocol {

  var url: URL
  private var eventLoopGroup: EventLoopGroup
  @Atomic var ws: WebSocket?

  init(stringURL: String, coreCount: Int = System.coreCount) {
    url = URL(string: stringURL)!
    eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: coreCount)
  }

  var onConnected: ((_ headers: [String: String]?) -> Void)?
  var onDisconnected: ((_ reason: String?) -> Void)?
  var onCancelled: (() -> Void)?
  var onText: ((_ text: String) -> Void)?
  var onBinary: ((_ data: Data) -> Void)?
  var onPing: (() -> Void)?
  var onPong: (() -> Void)?

  func connect(headers: [String: String]?) {

    var httpHeaders: HTTPHeaders = .init()
    headers?.forEach({ name, value in
      httpHeaders.add(name: name, value: value)
    })
    let promise: EventLoopPromise<Void> = eventLoopGroup.next().makePromise(of: Void.self)

    WebSocket.connect(to: url.absoluteString,
                      headers: httpHeaders,
                      on: eventLoopGroup
    ) { ws in
      self.ws = ws

      ws.onPing { [weak self] _ in
        self?.onPing?()
      }

      ws.onPong { [weak self] _ in
        self?.onPong?()
      }

      ws.onClose.whenComplete { [weak self] result in
        switch result {
        case .success:
          self?.onDisconnected?(nil)
          self?.onCancelled?()

        case let .failure(error):
          self?.onDisconnected?(error.localizedDescription)
          self?.onCancelled?()
        }
      }

      ws.onText { _, text in
        self.onText?(text)
      }

      ws.onBinary { _, buffer in
        var data = Data()
        data.append(contentsOf: buffer.readableBytesView)
        self.onBinary?(data)
      }

    }
    .cascade(to: promise)

    promise.futureResult.whenSuccess { [weak self] _ in
      guard let self = self else { return }
      self.onConnected?(nil)
    }
  }

  func disconnect() {
    ws?.close(promise: nil)
  }

  func send(data: Data) {
    ws?.send([UInt8](data))
  }

  func send(data: Data, _ completion: (() -> Void)?) {
    let promise: EventLoopPromise<Void>? = ws?.eventLoop.next().makePromise(of: Void.self)
    ws?.send([UInt8](data), promise: promise)
    promise?.futureResult.whenComplete { _ in
      completion?()
    }
  }

  func send(text: String) {
    ws?.send(text)
  }

  func send(text: String, _ completion: (() -> Void)?) {
    let promise: EventLoopPromise<Void>? = ws?.eventLoop.next().makePromise(of: Void.self)
    ws?.send(text, promise: promise)
    promise?.futureResult.whenComplete { _ in
      completion?()
    }
  }
}
