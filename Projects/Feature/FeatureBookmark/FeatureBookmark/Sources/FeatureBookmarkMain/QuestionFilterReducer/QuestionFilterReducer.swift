//
//  QuestionFilterReducer.swift
//  FeatureBookmark
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import Foundation
import Model

@Reducer
public struct QuestionFilterReducer {
    public struct State: Equatable, Hashable {
        var examType: ExamType = .all
        var questionType: QuestionType = .all
    }

    public enum Action {
        case selectExamType(ExamType)
        case selectQuestionType(QuestionType)
        case dismiss
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectExamType(type):
                state.examType = type
                return .none

            case let .selectQuestionType(type):
                state.questionType = type
                return .none

            case .dismiss:
                return .none
            }
        }
    }
}
