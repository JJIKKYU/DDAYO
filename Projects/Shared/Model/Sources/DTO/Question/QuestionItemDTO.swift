//
//  QuestionItemDTO.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

public struct QuestionItemDTO: Decodable {
    public let id: String
    public let title: RichContentDTO
    public let subject: QuizSubject
    public let questionType: QuestionType
    public let date: String?

    public let choice1: RichContentDTO
    public let choice2: RichContentDTO
    public let choice3: RichContentDTO
    public let choice4: RichContentDTO

    public let answer: Int
    public let explanation: String

    public init(
        id: String,
        title: RichContentDTO,
        subject: QuizSubject,
        questionType: QuestionType,
        date: String?,
        choice1: RichContentDTO,
        choice2: RichContentDTO,
        choice3: RichContentDTO,
        choice4: RichContentDTO,
        answer: Int,
        explanation: String
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
        self.answer = answer
        self.explanation = explanation
    }
}
