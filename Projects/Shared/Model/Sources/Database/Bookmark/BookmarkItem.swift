//
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

    public var questionID: UUID  // 북마크한 문제의 UUID

    public init(id: UUID = UUID(), questionID: UUID) {
        self.id = id
        self.questionID = questionID
    }
}
