//
//  VersionsResponse.swift
//  Model
//
//  Created by 정진균 on 5/31/25.
//

import Foundation

public struct VersionsResponse: Decodable {
    public let conceptsVersion: Int
    public let questionVersion: Int

    public init(conceptsVersion: Int, questionVersion: Int) {
        self.conceptsVersion = conceptsVersion
        self.questionVersion = questionVersion
    }
}
