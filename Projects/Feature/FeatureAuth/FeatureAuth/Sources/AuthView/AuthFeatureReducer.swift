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
        case navigateToAuthNameView
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

            return .run { send in
                let result = await firebaseAuth.signIn(with: credential)
                if case let .success(user) = result {
                    // await send(.signInCompleted(user))
                    await send(.navigateToAuthNameView)
                } else {
                    // TODO: 실패 처리 액션 필요시 여기에 추가
                }
            }

        case .signInCompleted(let user):
            state.isSignedIn = true
            return .none

        case .navigateToAuthNameView:
            return .none
        }
    }
}
