//
//  AppleSignManager.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import AuthenticationServices
import Service

public final class AppleSignInManager: NSObject, ASAuthorizationControllerDelegate {
    public static let shared = AppleSignInManager()

    private var continuation: CheckedContinuation<Result<User, AuthError>, Never>?

    public func signIn() async -> Result<User, AuthError> {
        print("AppleSignInManager :: signIn!")
        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
    }

    public func test(credential: ASAuthorizationAppleIDCredential) {
        guard let appleIdToken = credential.identityToken,
              let tokenData = String(data: appleIdToken, encoding: .utf8) else {
            continuation?.resume(returning: .failure(.appleSignInFailed))
            return
        }

//        let firebaseCredential = OAuthProvider.appleCredential(withIDToken: tokenData, rawNonce: nil, fullName: credential.fullName)
//
//        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
//            print("authResult = \(authResult), error = \(error)")
//        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let user = User(
                id: credential.user,
                name: credential.fullName?.givenName,
                email: credential.email
            )
            print("AppleSignInManager :: user = \(user)")

            guard let appleIdToken = credential.identityToken,
                  let tokenData = String(data: appleIdToken, encoding: .utf8) else {
                continuation?.resume(returning: .failure(.appleSignInFailed))
                return
            }
//
//            let firebaseCredential = OAuthProvider.appleCredential(withIDToken: tokenData, rawNonce: nil, fullName: credential.fullName)
//
//            Auth.auth().signIn(with: firebaseCredential) { authResult, error in
//                print("authResult = \(authResult), error = \(error)")
//            }
            continuation?.resume(returning: .success(user))
        } else {
            continuation?.resume(returning: .failure(.appleSignInFailed))
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(returning: .failure(.appleSignInFailed))
    }
}

/*
 ▿ User
   - id : "000597.fdfb232b961541b58a99537c96e5f296.1046"
   - name : nil
   - email : nil
 */
