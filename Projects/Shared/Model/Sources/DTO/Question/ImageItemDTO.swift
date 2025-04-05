//
//  ImageItemDTO.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

public struct ImageItemDTO: Decodable {
    public let data: Data?
    public var filename: String?

    public init(data: Data?, filename: String? = nil) {
        self.data = data
        self.filename = filename
    }
}
