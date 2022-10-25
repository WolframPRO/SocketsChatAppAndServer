//
//  File.swift
//  
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation

struct WebsocketMessage<T: Codable>: Codable {
    let client: UUID
    let data: T
}
