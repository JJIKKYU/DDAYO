//
//  FeatureProfileMainReducer.swift
//  FeatureProfile
//
//  Created by 정진균 on 5/4/25.
//

import Foundation
import ComposableArchitecture
import Service
import DI

public struct FeatureProfileMainReducer: Reducer {
    @Dependency(\.firebaseAuth) var firebaseAuth

    public init() {}

    public struct State: Equatable {
        public var userName: String = ""
        public var userEmail: String = ""
        public var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        public var isUpdateNeeded: Bool = true
        public var isLoggingOut: Bool = false

        public init() {}
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case logoutTapped
        case termsTapped
        case privacyTapped
        case pressedBackBtn

        case setUserName(String)
        case navigateToAuthView
        case setLoggingOut(Bool)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                let currentUser = firebaseAuth.getCurrentUser()
                print("FeatureProfileMainReducer :: currentUSer = \(currentUser)")
                state.userName = currentUser?.displayName ?? ""
                state.userEmail = currentUser?.email ?? "-"
                // 유저 정보 fetch 등의 로직
                if let uid = currentUser?.uid {
                    return .run { send in
                        do {
                            if let name = try await firebaseAuth.fetchUserName(userId: uid) {
                                await send(.setUserName(name))
                            }
                        } catch {
                            print("❌ 이름 불러오기 실패: \(error)")
                        }
                    }
                }

                return .none

            case .setUserName(let name):
                state.userName = name
                return .none

            case .logoutTapped:
                state.isLoggingOut = true
                return .run { send in
                    do {
                        try firebaseAuth.signOut()
                        await send(.setLoggingOut(false))
                        await send(.navigateToAuthView)
                    } catch {
                        print("❌ 로그아웃 실패: \(error)")
                        await send(.setLoggingOut(false))
                    }
                }

            case .setLoggingOut(let value):
                state.isLoggingOut = value
                return .none

            case .termsTapped:
                // 약관 링크 오픈
                return .none

            case .privacyTapped:
                // 개인정보 링크 오픈
                return .none

            // 뒤로가기 버튼
            case .pressedBackBtn:
                return .none

            case .binding:
                return .none

            case .navigateToAuthView:
                return .none
            }
        }
    }
}
