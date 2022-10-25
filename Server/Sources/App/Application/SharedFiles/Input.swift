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

struct NewMessage: Codable {
  let text: String
  let date: Date
}

struct Message: Codable {
  let id: Int
  let text: String
  let date: Date
  let authorId: UUID
}

struct NetworkMessage: Codable {
  let id: Int
  let text: String
  let date: Date
  let authorName: String
  let isCurrentUser: Bool
}
