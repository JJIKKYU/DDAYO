//
//  AuthAgreementReducer.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FeatureAuthAgreementReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var agreeAll: Bool = false
        public var agreeAge: Bool = false
        public var agreeTerms: Bool = false
        public var agreePrivacy: Bool = false

        public var canStart: Bool {
            agreeAge && agreeTerms && agreePrivacy
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case toggleAgreeAll
        case toggleAgreeAge
        case toggleAgreeTerms
        case toggleAgreePrivacy
        case didTapStart
        case pressedDetailTerms
        case pressedDetailPrivacy
        case dismiss
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .toggleAgreeAll:
                let newValue = !state.agreeAll
                state.agreeAll = newValue
                state.agreeAge = newValue
                state.agreeTerms = newValue
                state.agreePrivacy = newValue
                return .none

            case .toggleAgreeAge:
                state.agreeAge.toggle()
                state.agreeAll = state.agreeAge && state.agreeTerms && state.agreePrivacy
                return .none

            case .toggleAgreeTerms:
                state.agreeTerms.toggle()
                state.agreeAll = state.agreeAge && state.agreeTerms && state.agreePrivacy
                return .none

            case .toggleAgreePrivacy:
                state.agreePrivacy.toggle()
                state.agreeAll = state.agreeAge && state.agreeTerms && state.agreePrivacy
                return .none

            case .didTapStart:
                return .send(.dismiss)

            case .pressedDetailTerms, .pressedDetailPrivacy:
                return .none

            case .binding:
                return .none

            case .dismiss:
                return .none
            }
        }
    }
}
