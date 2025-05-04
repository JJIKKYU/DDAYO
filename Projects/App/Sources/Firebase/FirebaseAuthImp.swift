//  FirebaseAuthImp.swift
//  DDAYO
//
//  Created by 정진균 on 5/4/25.
//

import Foundation
import FeatureAuth
import FirebaseAuth
import FirebaseFirestore
import Service
import DI

struct FirebaseAuthImp: FirebaseAuthProtocol {
    func signIn(with credential: FirebaseAuthCredential) async -> Result<FirebaseUser, FirebaseAuthError> {
        do {
            let firebaseCredential = OAuthProvider.credential(providerID: .apple, idToken: credential.idToken)
            let authDataResult = try await Auth.auth().signIn(with: firebaseCredential)
            let user = authDataResult.user
            let idToken = try await user.getIDToken()

            let firebaseUser = FirebaseUser(
                uid: user.uid,
                email: user.email,
                displayName: user.displayName,
                idToken: idToken
            )
            return .success(firebaseUser)
        } catch {
            return .failure(.signInFailed(error.localizedDescription))
        }
    }

    func getCurrentUser() -> FirebaseUser? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }

        /*
        Task {
            do {
                let idToken = try await user.getIDToken(forcingRefresh: true)
                print("JJIKKYU :: idToken = \(idToken)")
            } catch {
                print("🚫 Token invalid or Apple ID unlinked: \(error.localizedDescription)")
            }
        }
        */

        return FirebaseUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            idToken: nil // For real use, you can update this with a fresh token if needed
        )
    }

    func signOut() throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthError.signInFailed("No current user")
        }

        let uid = user.uid
        let db = Firestore.firestore()
        let semaphore = DispatchSemaphore(value: 0)
        var firestoreError: Error?

        db.collection("users").document(uid).delete { error in
            firestoreError = error
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5) // wait max 5 seconds

        if let error = firestoreError {
            throw FirebaseAuthError.signInFailed("Firestore delete failed: \(error.localizedDescription)")
        }

        do {
            try Auth.auth().signOut()
        } catch {
            throw FirebaseAuthError.signInFailed(error.localizedDescription)
        }
    }

    public func saveUserName(userId: String, name: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).setData([
            "name": name,
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    public func fetchUserName(userId: String) async throws -> String? {
       let db = Firestore.firestore()
       let document = try await db.collection("users").document(userId).getDocument()

       if let data = document.data(), let name = data["name"] as? String {
           return name
       } else {
           return nil
       }
   }
}
