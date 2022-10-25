//
//  File.swift
//  
//
//  Created by Vladimir Petrov on 16/02/2022.
//

import Foundation
import Vapor

extension ByteBuffer {
    func decodeWebsocketMessage<T: Codable>(_ type: T.Type) -> WebsocketMessage<T>? {
        try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
    }
}
