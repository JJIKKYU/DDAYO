//
//  RichContentDTO.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

public struct RichContentDTO: Decodable {
    public let text: String
    public let images: [ImageItemDTO]?

    public init(text: String, images: [ImageItemDTO]) {
        self.text = text
        self.images = images
    }
}
