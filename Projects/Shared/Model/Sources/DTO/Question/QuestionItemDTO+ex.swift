//
//  QuestionDTO+ex.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation

extension QuestionItemDTO {
    public func toModel() -> QuestionItem? {
        func convertRich(_ dto: RichContentDTO) -> RichContent {
            let images = dto.images?.compactMap { ImageItem(data: $0.data, filename: $0.filename) }
            return RichContent(text: dto.text, images: images)
        }

        return QuestionItem(
            id: id,
            title: title,
            subject: subject,
            questionType: questionType,
            date: date,
            choice1: convertRich(choice1),
            choice2: convertRich(choice2),
            choice3: convertRich(choice3),
            choice4: convertRich(choice4),
            desc: convertRich(desc),
            code: code,
            answer: answer,
            explanation: convertRich(explanation),
            version: version
        )
    }
}
