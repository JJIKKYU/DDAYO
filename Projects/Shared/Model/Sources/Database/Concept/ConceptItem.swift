//
//  ConceptItem.swift
//  Model
//
//  Created by 정진균 on 4/2/25.
//

import Foundation
import SwiftData

@Model
public final class ConceptItem {
    @Attribute(.unique) public var id: String
    public var title: String
    public var desc: String
    public var views: Int
    public var subject: String
    public var subjectId: Int

    public init(
        id: String,
        title: String,
        desc: String,
        views: Int = 0,
        subject: String,
        subjectId: Int
    ) {
        self.id = id
        self.title = title
        self.desc = desc
        self.views = views
        self.subject = subject
        self.subjectId = subjectId
    }
}

// MARK: - Sort Extension

public extension Array where Element == ConceptItem {
    func sortedByDefault() -> [ConceptItem] {
        return self.sorted {
            if $0.subjectId == $1.subjectId {
                return $0.id < $1.id
            } else {
                return $0.subjectId < $1.subjectId
            }
        }
    }

    func sortedByViews(ascending: Bool = true) -> [ConceptItem] {
        return self.sorted {
            ascending ? $0.views < $1.views : $0.views > $1.views
        }
    }

    func sortedByTitle(ascending: Bool = true) -> [ConceptItem] {
        return self.sorted {
            ascending ? $0.title < $1.title : $0.title > $1.title
        }
    }
}
