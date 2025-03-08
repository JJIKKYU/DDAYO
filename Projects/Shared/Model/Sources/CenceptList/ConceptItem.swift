//
//  ConceptItem.swift
//  Model
//
//  Created by 정진균 on 3/1/25.
//

import Foundation

public struct ConceptItem: Identifiable, Equatable, Hashable {
    public let id = UUID() // 각 아이템의 고유 ID
    public let title: String // 개념 이름
    public let description: String // 개념 상세 내용
    public let views: Int // 조회수

    public init(title: String, description: String, views: Int) {
        self.title = title
        self.description = description
        self.views = views
    }
}
