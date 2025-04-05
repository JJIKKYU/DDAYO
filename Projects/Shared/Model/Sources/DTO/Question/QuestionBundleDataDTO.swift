//
//  QuestionBundleDataDTO.swift
//  Model
//
//  Created by 정진균 on 4/5/25.
//

import Foundation

public struct QuestionBundleDataDTO: Decodable {
    public let version: Int
    public let items: [QuestionItemDTO]

    public init(version: Int, items: [QuestionItemDTO]) {
        self.version = version
        self.items = items
    }
}
