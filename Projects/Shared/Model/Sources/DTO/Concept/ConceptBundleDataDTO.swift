//
//  ConceptBundleDataDTO.swift
//  Model
//
//  Created by 정진균 on 4/2/25.
//

public struct ConceptBundleDataDTO: Decodable {
    public let version: Int
    public let items: [ConceptItemDTO]

    public init(version: Int, items: [ConceptItemDTO]) {
        self.version = version
        self.items = items
    }
}
