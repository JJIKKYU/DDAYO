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
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var desc: String
    public var views: Int
    public var mnemonics: [String]
    public var subject: String
    public var subjectId: Int

    public init(
        id: UUID = UUID(),
        title: String,
        desc: String,
        views: Int,
        mnemonics: [String],
        subject: String,
        subjectId: Int
    ) {
        self.id = id
        self.title = title
        self.desc = desc
        self.views = views
        self.mnemonics = mnemonics
        self.subject = subject
        self.subjectId = subjectId
    }
}
