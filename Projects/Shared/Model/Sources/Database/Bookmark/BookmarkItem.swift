//  BookmarkItem.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation
import SwiftData

@Model
public final class BookmarkItem {
    @Attribute(.unique)
    public var id: UUID  // Bookmark의 고유 ID

    public var type: BookmarkTabType
    public var reason: BookmarkReason

    public var questionID: UUID  // 북마크한 문제의 UUID
    public var date: Date

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        questionID: UUID,
        type: BookmarkTabType,
        reason: BookmarkReason
    ) {
        self.id = id
        self.questionID = questionID
        self.type = type
        self.date = date
        self.reason = reason
    }
}
