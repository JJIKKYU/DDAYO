//
//  QuestionVersion.swift
//  Model
//
//  Created by 정진균 on 4/5/25.
//

import Foundation
import SwiftData

@Model
public final class QuestionVersion {
    @Attribute(.unique) public var id: UUID
    public var version: Int

    public init(id: UUID = UUID(), version: Int) {
        self.id = id
        self.version = version
    }
}
