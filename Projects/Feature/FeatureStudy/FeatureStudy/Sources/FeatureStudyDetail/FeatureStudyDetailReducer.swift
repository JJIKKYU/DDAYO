//
//  FeatureStudyDetailReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import Model

@Reducer
public struct FeatureStudyDetailReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {

        public init() {}
    }

    public enum Action {
        case onAppear

        case pressedCloseBtn
        case dismiss
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .pressedCloseBtn:
                return .none

            case .dismiss:
                return .none
            }
        }
    }
}
