//
//  ImageItemDTO.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

public struct ImageItemDTO: Decodable {
    public let data: Data  // base64로 되어 있다고 가정

    public init(data: Data) {
        self.data = data
    }
}
