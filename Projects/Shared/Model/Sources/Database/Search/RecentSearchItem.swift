//
//  RecentSearchItem.swift
//  Model
//
//  Created by 정진균 on 4/13/25.
//

import Foundation
import SwiftData

public enum SearchCategory: String, Codable {
    case 개념
    case 필기
    case 실기
}

@Model
public final class RecentSearchItem {
    @Attribute(.unique)
    public var id: UUID

    public var keyword: String
    public var searchedAt: Date
    // 저장은 rawValue로
    public var searchCategoryRawValue: String

    public var searchCategory: SearchCategory {
        get { return SearchCategory(rawValue: searchCategoryRawValue) ?? .개념 }
        set { searchCategoryRawValue = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        keyword: String,
        searchedAt: Date = .now,
        searchCategoryRawValue: String
    ) {
        self.id = id
        self.keyword = keyword
        self.searchedAt = searchedAt
        self.searchCategoryRawValue = searchCategoryRawValue
    }
}
