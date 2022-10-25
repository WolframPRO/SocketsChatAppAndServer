//
//  File.swift
//  
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation

struct Input: Codable {
  let isTyping: Bool
}

struct NewMessage: Codable, Identifiable {

  typealias ID = Date

  var id: ID { date }
  let text: String
  let date: Date

  static func createArray(from data: Data) -> [NewMessage]? {
    try? JSONDecoder().decode([NewMessage].self, from: data)
  }
}

struct NetworkMessage: Codable {
  let id: Int
  let text: String
  let date: Date
  let authorName: String
  let isCurrentUser: Bool

  static func createArray(from data: Data) -> [NetworkMessage]? {
    try? JSONDecoder().decode([NetworkMessage].self, from: data)
  }
}

struct Message: Codable, Identifiable, Equatable {
  var id: Int
  let text: String
  let date: Date
  let authorName: String
  let isCurrentUser: Bool

  static func createArray(from data: [NetworkMessage]) -> [Message] {
    data.map {
      .init(
        id: $0.id,
        text: $0.text,
        date: $0.date,
        authorName: $0.authorName,
        isCurrentUser: $0.isCurrentUser
      )
    }
  }
}
