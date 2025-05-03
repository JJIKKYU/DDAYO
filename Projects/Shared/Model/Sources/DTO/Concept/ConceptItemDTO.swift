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
    public let views: Int // 조회수
    public let subject: String // 과목명
    public let subjectId: Int // 과목 번호
    public let mnemonics: [String] // 암기어 배열

    public init(
        id: String,
        title: String,
        description: String,
        views: Int,
        subject: String,
        subjectId: Int,
        mnemonics: [String]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.views = views
        self.subject = subject
        self.subjectId = subjectId
        self.mnemonics = mnemonics
    }
}
