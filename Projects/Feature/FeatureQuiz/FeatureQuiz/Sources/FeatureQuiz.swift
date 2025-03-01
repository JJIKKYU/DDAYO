//
//  FeatureQuiz.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 12/31/24.
//

import ComposableArchitecture

@Reducer
public struct FeatureQuiz {
    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var count = 0

        public init(count: Int = 0) {
            self.count = count
        }
    }

    public enum Action {
        case decrementButtonTapped
        case incrementButtonTapped

        case navigateToSecondFeatureQuiz
        case navigateToQuizMain
        case navigateToQuizSubject
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .decrementButtonTapped:
                state.count -= 1
                return .none

            case .navigateToQuizMain, .navigateToSecondFeatureQuiz, .navigateToQuizSubject:
                return .none
            }
        }
    }
}

