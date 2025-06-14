//
//  AuthFeatureReducer.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import ComposableArchitecture
import SwiftUI
import Dependencies
import AuthenticationServices
import Service
import DI

@Reducer
public struct AuthFeatureReducer {
    @Dependency(\.authClient) var authClient
    @Dependency(\.firebaseAuth) var firebaseAuth

    public init() {}

    public struct State: Equatable {
        var isSignedIn: Bool = false
        var userInfo: User? = nil

        public init() {

        }
    }

    public enum Action: Equatable {
        case signInTapped
        case appleSignInCompleted(ASAuthorization)
        case signInCompleted(FirebaseUser)
        case navigateToAuthNameView(userName: String?)
        case navigateToAuthAgreementView(userName: String)
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .signInTapped:
            return .none

        case .appleSignInCompleted(let auth):
            print("AuthFeatureReducer :: auth = \(auth)")
            guard let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
                return .none
            }

            print("AuthFeatureReducer :: \(appleCredential.fullName)")
            print("AuthFeatureReducer :: \(appleCredential)")
            let idToken = appleCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let credential = FirebaseAuthCredential(idToken: idToken)
            var userName: String = appleCredential.fullName?.givenName ?? ""

            if userName.isEmpty == false {
                // 이름은 최초에 한 번만 받으므로 임시로 로컬 저장
                UserDefaults.standard.set(userName, forKey: "appleUserName")
            }
            // 이름이 비어있을 경우 userDefaults에 저장이 되어있는지 한 번 더 확인
            else if userName.isEmpty {
                let savedName = UserDefaults.standard.string(forKey: "appleUserName") ?? ""
                if savedName.isEmpty == false {
                    userName = savedName
                }
            }

            return .run { send in
                let result = await firebaseAuth.signIn(with: credential)
                if case let .success(user) = result {
                    do {
                        let hasName = try await firebaseAuth.userHasName()
                        print("AuthFeatureReducer :: hasName = \(hasName)")
                        if hasName {
                            await send(.signInCompleted(user))
                        } else {
                            await send(.navigateToAuthAgreementView(userName: userName))
                        }
                    } catch {
                        print("❌ Error checking user name: \(error)")
                        // fallback: treat as if no name exists
                        await send(.navigateToAuthAgreementView(userName: userName))
                    }
                } else {
                    // TODO: 실패 처리 액션 필요시 여기에 추가
                }
            }

        case .signInCompleted(let user):
            state.isSignedIn = true
            return .none

        case .navigateToAuthNameView, .navigateToAuthAgreementView:
            return .none
        }
    }
}
