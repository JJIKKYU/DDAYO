//
//  AuthClient.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture

public struct User: Equatable {
    let id: String
    let name: String?
    let email: String?
}

public enum AuthError: Error, Equatable {
    case appleSignInFailed
    case missingToken
}

@DependencyClient
public struct AuthClient {
    public var signInWithApple: @Sendable () async -> Result<User, AuthError> = {
        // 테스트나 미구현 상태일 때 사용할 기본 반환값
        return .failure(.appleSignInFailed)
    }

    public init(signInWithApple: @Sendable @escaping () -> Result<User, AuthError>) {
        self.signInWithApple = signInWithApple
    }
}

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

extension AuthClient: DependencyKey {
    public static let liveValue = Self(
        signInWithApple: {
            print("AuthClient :: signInWithApple")
            return await AppleSignInManager.shared.signIn()
        }
    )
}
