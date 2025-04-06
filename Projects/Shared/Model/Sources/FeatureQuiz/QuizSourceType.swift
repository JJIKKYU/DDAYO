//
//  QuizSourceType.swift
//  Model
//
//  Created by 정진균 on 4/5/25.
//

import Foundation

public enum QuizSourceType: Equatable, Hashable {
    case subject(QuizSubject?)
    case random(QuizTab, QuestionType)
    case searchResult(items: [QuestionItem], index: Int)
    case fromBookmark(items: [QuestionItem], index: Int)
}
