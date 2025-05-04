//
//  ConceptItem.swift
//  Model
//
//  Created by 정진균 on 3/1/25.
//

import Foundation

public struct ConceptItemDTO: Identifiable, Codable, Equatable, Hashable {
    public var id: String // 고유 ID
    public let title: String // 개념 이름
    public let description: String // 개념 요약
    public let subject: String // 과목명
    public let subjectId: Int // 과목 번호

    public init(
        id: String,
        title: String,
        description: String,
        subject: String,
        subjectId: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.subject = subject
        self.subjectId = subjectId
    }
}
