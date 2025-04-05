//
//  QuestionItemDTO.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

public struct QuestionItemDTO: Decodable {
    public let id: String
    public let title: String
    public let subject: QuizSubject
    public let questionType: QuestionType
    public let date: String?

    public let choice1: RichContentDTO
    public let choice2: RichContentDTO
    public let choice3: RichContentDTO
    public let choice4: RichContentDTO

    public let desc: RichContentDTO
    public let answer: Int
    public let explanation: String

    public var viewCount: Int?
    public var version: Int

    public init(
        id: String,
        title: String,
        subject: QuizSubject,
        questionType: QuestionType,
        date: String?,
        choice1: RichContentDTO,
        choice2: RichContentDTO,
        choice3: RichContentDTO,
        choice4: RichContentDTO,
        desc: RichContentDTO,
        answer: Int,
        explanation: String,
        viewCount: Int?,
        version: Int
    ) {
        self.id = id
        self.title = title
        self.subject = subject
        self.questionType = questionType
        self.date = date
        self.choice1 = choice1
        self.choice2 = choice2
        self.choice3 = choice3
        self.choice4 = choice4
        self.desc = desc
        self.answer = answer
        self.explanation = explanation
        self.viewCount = viewCount
        self.version = version
    }
}
