//
//  ConceptFilterReducer.swift
//  FeatureBookmark
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import Foundation
import Model

@Reducer
public struct ConceptSortingReducer {
    public struct State: Equatable, Hashable {
        var selectedOption: SortOption? = nil
    }

    public enum Action {
        case select(SortOption)
        case dismiss
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .select(option):
                state.selectedOption = option
                return .send(.dismiss)

            case .dismiss:
                return .none
            }
        }
    }
}
