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
    @Dependency(\.mixpanelLogger) private var mixpanelLogger

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
                mixpanelLogger.log("click_test_type_filter_\(type.getLogName())")
                print("type = \(type)")
                return .none

            case let .selectQuestionType(type):
                state.questionType = type
                mixpanelLogger.log("click_ques_type_filter_\(type.getLogName())")
                print("type = \(type)")
                return .none

            case .dismiss:
                mixpanelLogger.log(
                    "click_ques_type_filter_apply",
                    parameters: LogParamBuilder()
                        .add(.testTypeFilter, value: state.examType.getLogName())
                        .add(.quesTypeFilter, value: state.questionType.getLogName())
                        .build()
                )
                return .none
            }
        }
    }
}
