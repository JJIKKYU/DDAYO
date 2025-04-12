//
//  BookmarkFeedItem.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

public struct BookmarkFeedItem: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let category: String
    public let title: String
    public let views: String
    public let tags: [String]
    public var isBookmarked: Bool
    public var originConceptItem: ConceptItem?

    public init(
        category: String,
        title: String,
        views: String,
        tags: [String],
        isBookmarked: Bool,
        originConceptItem: ConceptItem? = nil
    ) {
        self.category = category
        self.title = title
        self.views = views
        self.tags = tags
        self.isBookmarked = isBookmarked
        self.originConceptItem = originConceptItem
    }
}
