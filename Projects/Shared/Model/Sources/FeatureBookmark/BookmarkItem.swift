//
//  BookmarkItem.swift
//  Model
//
//  Created by 정진균 on 3/29/25.
//

import Foundation

public struct BookmarkItem: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let category: String
    public let title: String
    public let views: String
    public let tags: [String]
    public let isBookmarked: Bool

    public init(category: String, title: String, views: String, tags: [String], isBookmarked: Bool) {
        self.category = category
        self.title = title
        self.views = views
        self.tags = tags
        self.isBookmarked = isBookmarked
    }
}
