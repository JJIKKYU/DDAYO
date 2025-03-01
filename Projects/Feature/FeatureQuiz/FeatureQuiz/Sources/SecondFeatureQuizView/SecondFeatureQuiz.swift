//
//  SecondFeatureQuiz.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 12/31/24.
//

import ComposableArchitecture

@Reducer
public struct SecondFeatureQuiz {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {

        public init() {}
    }

    public enum Action {

    }


    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
//            switch action {
//            case .clickBackButton:
//                return .none
//            case .clickNextButton:
//                return .none
//            }
        }
    }
}
