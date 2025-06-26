//
//  AuthAgreementReducer.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import ComposableArchitecture
import Foundation
import Service
import Model

@Reducer
public struct FeatureAuthAgreementReducer {
    @Dependency(\.firebaseAuth) var firebaseAuth
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var userName: String
        public var agreeAll: Bool = true
        public var agreeAge: Bool = true
        public var agreeTerms: Bool = true
        public var agreePrivacy: Bool = true

        public var isLoading: Bool = false

        public var canStart: Bool {
            agreeAge && agreeTerms && agreePrivacy
        }

        public init(userName: String) {
            self.userName = userName
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
        case pressedBackBtn
        case navigateToMain
        case complete
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
                // guard let user = firebaseAuth.getCurrentUser() else { return .none }
                // let userUid: String = user.uid
                // let name: String = state.userName
                state.isLoading = true

                return .run { send in
                    do {
                        // fireBase Document에 유저 이름 저장
                        // try await firebaseAuth.saveUserName(userId: userUid, name: name)

                        // useritemDB를 생성하여 저장
                        let userItem = UserItem(
                            name: "",
                            email: "",
                            hasAgreedToTerms: true,
                            createdAt: .now,
                            lastLogin: .now
                        )
                        modelContext.insert(userItem)
                        try? modelContext.save()
                    } catch {
                        print("❌ Firebase 저장 실패: \(error)")
                    }

                    await send(.complete)
               }

            case .complete:
                return .send(.navigateToMain)

            case .pressedDetailTerms, .pressedDetailPrivacy:
                return .none

            case .pressedBackBtn:
                return .none

            case .binding:
                return .none

            case .dismiss:
                return .none

            case .navigateToMain:
                return .none
            }
        }
    }
}
