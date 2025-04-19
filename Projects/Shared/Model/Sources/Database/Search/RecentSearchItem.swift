//
//  RecentSearchItem.swift
//  Model
//
//  Created by 정진균 on 4/13/25.
//

import Foundation
import SwiftData

@Model
public final class RecentSearchItem {
    @Attribute(.unique)
    public var id: UUID

    public var keyword: String
    public var searchedAt: Date

    public init(id: UUID = UUID(), keyword: String, searchedAt: Date = .now) {
        self.id = id
        self.keyword = keyword
        self.searchedAt = searchedAt
    }
}
