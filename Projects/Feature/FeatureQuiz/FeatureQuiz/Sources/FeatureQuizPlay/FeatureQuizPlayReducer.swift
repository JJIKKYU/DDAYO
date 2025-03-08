//
//  FeatureQuizPlayReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture

@Reducer
public struct FeatureQuizPlayReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public init() {}
    }

    public enum Action {
        case test
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .test:
                return .none
            }
        }
    }
}
