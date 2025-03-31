//
//  QuestionItem.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation
import SwiftData

@Model
public final class QuestionItem {
    @Attribute(.unique)
    public var id: UUID

    public var title: RichContent
    public var subjectRawValue: String
    public var questionTypeRawValue: String
    public var date: String?

    public var choice1: RichContent
    public var choice2: RichContent
    public var choice3: RichContent
    public var choice4: RichContent

    public var answer: Int
    public var explanation: String

    public init(
        id: UUID = UUID(),
        title: RichContent,
        subject: QuizSubject,
        questionType: QuestionType,
        date: String?,
        choice1: RichContent,
        choice2: RichContent,
        choice3: RichContent,
        choice4: RichContent,
        answer: Int,
        explanation: String
    ) {
        self.id = id
        self.title = title
        self.subjectRawValue = subject.rawValue
        self.questionTypeRawValue = questionType.rawValue
        self.date = date
        self.choice1 = choice1
        self.choice2 = choice2
        self.choice3 = choice3
        self.choice4 = choice4
        self.answer = answer
        self.explanation = explanation
    }

    public var subject: QuizSubject {
        get { QuizSubject(rawValue: subjectRawValue) ?? .softwareDesign }
        set { subjectRawValue = newValue.rawValue }
    }

    public var questionType: QuestionType {
        get { QuestionType(rawValue: questionTypeRawValue) ?? .past }
        set { questionTypeRawValue = newValue.rawValue }
    }
}

public extension QuestionItem {
    var choices: [String] {
        [choice1.text, choice2.text, choice3.text, choice4.text]
    }
}
