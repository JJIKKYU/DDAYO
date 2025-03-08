//
//  FeatureQuizPlayReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture
import Model

@Reducer
public struct FeatureQuizPlayReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public init(selectedSubject: QuizSubject? = nil) {
            self.selectedSubject = selectedSubject
        }

        private let selectedSubject: QuizSubject?
    }

    public enum Action {
        case onAppear

        case pressedBackBtn
        case pressedCloseBtn
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .pressedBackBtn:
                print("FeatureQuizPlayReducer :: pressedBackBtn!")
                return .none

            case .pressedCloseBtn:
                print("FeatureQuizPlayReducer :: pressedCloseBtn!")
                return .none
            }
        }
    }
}
