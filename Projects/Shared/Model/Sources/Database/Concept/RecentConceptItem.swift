//
//  RecentConceptItem.swift
//  Model
//
//  Created by 정진균 on 4/5/25.
//

import Foundation
import SwiftData

@Model
public final class RecentConceptItem {
    @Attribute(.unique) public var id: UUID
    public var conceptId: UUID
    public var viewedAt: Date

    public init(
        id: UUID = UUID(),
        conceptId: UUID,
        viewedAt: Date = .now
    ) {
        self.id = id
        self.conceptId = conceptId
        self.viewedAt = viewedAt
    }
}
