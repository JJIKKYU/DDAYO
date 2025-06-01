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
import Model

public struct FeatureProfileMainReducer: Reducer {
    @Dependency(\.firebaseAuth) var firebaseAuth

    public init() {}

    public struct State: Equatable {
        public var userName: String = ""
        public var userEmail: String = ""
        public var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        public var isUpdateNeeded: Bool = true
        public var isLoggingOut: Bool = false

        @BindingState public var isPopupPresented: Bool = false
        public var popupState: PopupState? = nil

        public init() {}
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear

        case termsTapped
        case privacyTapped
        case attributionTapped
        case pressedBackBtn

        case setUserName(String)
        case navigateToAuthView
        case setLoggingOut(Bool)

        case logout
        case deleteAccount

        case showLogoutPopup
        case showDeletePopup
        case hidePopup
        case confirmPopup
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(let state):
                print("FeatureProfileMainReducer :: binding state = \(state)")
                return .none

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

            case .logout:
                state.isLoggingOut = true
                return .run { send in
                    do {
                        try firebaseAuth.logout()
                        await send(.setLoggingOut(false))
                        await send(.navigateToAuthView)
                    } catch {
                        print("❌ 로그아웃 실패: \(error)")
                        await send(.setLoggingOut(false))
                    }
                }

            case .setLoggingOut(let value):
                state.isPopupPresented = true
                // state.isLoggingOut = value
                return .none

            case .deleteAccount:
                state.isLoggingOut = true
                return .run { send in
                    do {
                        try firebaseAuth.signOut()
                        await send(.setLoggingOut(false))
                        await send(.navigateToAuthView)
                    } catch {
                        print("❌ 회원 탈퇴 실패: \(error)")
                        await send(.setLoggingOut(false))
                    }
                }

            case .termsTapped:
                // 약관 링크 오픈
                return .none

            case .privacyTapped:
                // 개인정보 링크 오픈
                return .none

            case .attributionTapped:
                return .none

            // 뒤로가기 버튼
            case .pressedBackBtn:
                return .none

            case .binding:
                return .none

            case .navigateToAuthView:
                return .none

            case .showLogoutPopup:
                state.popupState = PopupState(
                    type: .logout,
                    title: "로그아웃하시겠어요?",
                    desc: "로그아웃하면 앱이 재시작돼요.\n현재 계정으로 다시 로그인하면\n저장된 학습 내용을 불러올 수 있어요.",
                    leadingTitle: "취소",
                    trailingTitle: "로그아웃",
                    allDone: false
                )
                state.isPopupPresented = true
                return .none

            case .showDeletePopup:
                state.popupState = PopupState(
                    type: .delete,
                    title: "탈퇴하기 전에 확인해주세요.",
                    desc: "탈퇴하면 저장한 학습 내용이 모두 삭제되고\n동일한 이메일로 재가입해도 복구되지 않아요.\n정말 탈퇴하시겠어요?",
                    leadingTitle: "취소",
                    trailingTitle: "탈퇴하기",
                    allDone: false
                )
                state.isPopupPresented = true
                return .none

            case .hidePopup:
                state.isPopupPresented = false
                return .none

            case .confirmPopup:
                // 로그아웃 또는 탈퇴 실행
                // 팝업 상태를 보고 처리 분기 가능
                guard let popupState = state.popupState?.type else { return .none }

                switch popupState {
                case .logout:
                    return .send(.logout)

                case .delete:
                    return .send(.deleteAccount)
                }
            }
        }
    }
}
