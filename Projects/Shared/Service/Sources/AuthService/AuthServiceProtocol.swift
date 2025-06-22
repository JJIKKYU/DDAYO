//
//  AuthServiceProtocol.swift
//  Service
//
//  Created by 정진균 on 5/4/25.
//


import Foundation
import SwiftData

public struct FirebaseUser: Equatable {
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let idToken: String?

    public init(uid: String, email: String?, displayName: String?, idToken: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.idToken = idToken
    }
}

public enum FirebaseAuthError: Error, Equatable {
    case signInFailed(String)
    case tokenRetrievalFailed
    case unknown
}

public struct FirebaseAuthCredential: Equatable {
    public let idToken: String

    public init(idToken: String) {
        self.idToken = idToken
    }
}

public protocol FirebaseAuthProtocol {
    var modelContext: ModelContext { get set }

    func signIn(with credential: FirebaseAuthCredential) async -> Result<FirebaseUser, FirebaseAuthError>
    func getCurrentUser() -> FirebaseUser?
    func signOut() throws
    func logout() throws

    // 한번 로그인하고 로그아웃 했던 유저라면 name을 가지고 있다
    func userHasName() async throws -> Bool

    // firebase token 기준으로 userName
    func saveUserName(userId: String, name: String) async throws

    // firebase store에서 userName fetch
    func fetchUserName(userId: String) async throws -> String?
}
