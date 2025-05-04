//
//  FeatureAuthNameReducer.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct FeatureAuthNameReducer {
    @Dependency(\.firebaseAuth) var firebaseAuth
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var name: String = ""
        public var isValid: Bool = false
        public var helperText: String? = nil

        @Presents var agreement: FeatureAuthAgreementReducer.State? = nil
        public var isAgreementSheetPresented: Bool {
            get { agreement != nil }
            set { agreement = newValue ? FeatureAuthAgreementReducer.State() : nil }
        }

        // 최종적으로 저장할때
        public var isLoading: Bool = false

        public init() {}
    }

    public enum Action: BindableAction {
        case pressedBackBtn

        case agreement(PresentationAction<FeatureAuthAgreementReducer.Action>)
        case toggleAgreement

        case binding(BindingAction<State>)
        case didTapNext

        case saveUserName
        case complete

        case navigateToMain
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<FeatureAuthNameReducer.State, FeatureAuthNameReducer.Action> { state, action in
            switch action {
            case .binding(\.name):
                print("binding! = \(state.name)")
                state.isValid = !state.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                state.helperText = state.isValid ? "멋진 이름이네요 :)" : nil
                return .none

            case .binding:
                return .none

            case .didTapNext:
                print("다음 버튼 탭됨: \(state.name)")
                return .none

            case .agreement(let action):
                switch action {
                case .presented(.didTapStart):
                    state.agreement = nil
                    return .send(.saveUserName)

                default:
                    return .none
                }

            case .toggleAgreement:
                state.isAgreementSheetPresented.toggle()
                return .none

            case .saveUserName:
                guard let user = firebaseAuth.getCurrentUser() else { return .none }
                let userUid: String = user.uid
                let name: String = state.name

                state.isLoading = true

                return .run { send in
                    do {
                        try await firebaseAuth.saveUserName(userId: userUid, name: name)
                    } catch {
                        print("❌ Firebase 저장 실패: \(error)")
                    }

                    await send(.complete)
               }

            case .complete:
                state.isLoading = false
                return .send(.navigateToMain)

            case .pressedBackBtn, .navigateToMain:
                return .none
            }
        }
        .ifLet(\.$agreement, action: \.agreement) {
            FeatureAuthAgreementReducer()
        }
    }
}
