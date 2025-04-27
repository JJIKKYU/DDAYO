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

    public var title: String
    public var subjectRawValue: String
    public var questionTypeRawValue: String
    public var date: String?

    public var choice1: RichContent
    public var choice2: RichContent
    public var choice3: RichContent
    public var choice4: RichContent

    public var desc: RichContent
    public var code: String
    public var answer: Int
    public var explanation: RichContent

    public var viewCount: Int
    public var version: Int

    // 문제 틀리면 false, 맞으면 true, 아직 풀기 전이면 nil
    @Transient
    public var isCorrect: Bool? = nil
    @Transient
    public var selectedIndex: Int? = nil

    public init(
        id: UUID = UUID(),
        title: String,
        subject: QuizSubject,
        questionType: QuestionType,
        date: String?,
        choice1: RichContent,
        choice2: RichContent,
        choice3: RichContent,
        choice4: RichContent,
        desc: RichContent,
        code: String,
        answer: Int,
        explanation: RichContent,
        viewCount: Int = 0,
        version: Int
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
        self.desc = desc
        self.code = code
        self.answer = answer
        self.explanation = explanation
        self.viewCount = viewCount
        self.version = version
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

public extension QuestionItem {
    func tags(isWrong: Bool) -> [String] {
        var tags: [String] = []

        // 시험 유형
        tags.append(self.questionType.displayName)

        if isWrong {
            tags.append("틀린 문제")
        }

        // 필기/실기 (subject 기준)
        if QuizSubject.writtenCases.contains(self.subject) {
            tags.append("필기시험")
        } else {
            tags.append("실기시험")
        }

        return tags
    }
}
