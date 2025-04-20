//
//  QuizSourceType.swift
//  Model
//
//  Created by 정진균 on 4/5/25.
//

import Foundation

public enum QuizSourceType: Equatable, Hashable {
    case subject(QuizSubject?, QuestionType?)
    case random(QuizTab, QuestionType)
    case searchResult(items: [QuestionItem], index: Int)
    case fromBookmark(items: [QuestionItem], index: Int)
}

public extension QuizSourceType {
    var isBookmarkSource: Bool {
        if case .fromBookmark = self {
            return true
        }
        return false
    }
}
