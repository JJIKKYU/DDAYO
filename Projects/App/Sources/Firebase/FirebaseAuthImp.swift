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
import SwiftData
import Model

struct FirebaseAuthImp: FirebaseAuthProtocol {
    var modelContext: ModelContext

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

        return FirebaseUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            idToken: nil
        )
    }

    public func userHasName() async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthError.signInFailed("No current user")
        }

        let db = Firestore.firestore()
        let document = try await db.collection("users").document(user.uid).getDocument()

        if let data = document.data(), let name = data["name"] as? String {
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else {
            return false
        }
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

        // userItem DB 삭제
        do {
            let userItems = try modelContext.fetch(FetchDescriptor<UserItem>())
            for item in userItems {
                modelContext.delete(item)
            }
            try modelContext.save()

            try Auth.auth().signOut()
        } catch {
            throw FirebaseAuthError.signInFailed(error.localizedDescription)
        }
    }

    func logout() throws {
        do {
            // userItem DB 삭제
            let userItems = try modelContext.fetch(FetchDescriptor<UserItem>())
            for item in userItems {
                modelContext.delete(item)
            }
            try modelContext.save()

            try Auth.auth().signOut()
        } catch {
            throw FirebaseAuthError.signInFailed("Logout failed: \(error.localizedDescription)")
        }
    }

    public func saveUserName(userId: String, name: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).setData([
            "name": name,
            "createdAt": FieldValue.serverTimestamp(),
            "didAgreeToTerms": true
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
