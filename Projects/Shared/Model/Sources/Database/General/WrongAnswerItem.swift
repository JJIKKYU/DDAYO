//
//  WrongAnswerItem.swift
//  Model
//
//  Created by 정진균 on 4/5/25.
//

import Foundation
import SwiftData

@Model
public final class WrongAnswerItem {
    @Attribute(.unique) public var id: UUID
    public var questionID: UUID
    public var selectedAnswerIndex: Int
    public var date: Date

    public init(questionID: UUID, selectedAnswerIndex: Int, date: Date = .now) {
        self.id = UUID()
        self.questionID = questionID
        self.selectedAnswerIndex = selectedAnswerIndex
        self.date = date
    }
}
