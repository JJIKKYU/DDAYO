//
//  Dependency+Auth.swift
//  DI
//
//  Created by 정진균 on 5/4/25.
//

import ComposableArchitecture
import Service

private enum FirebaseAuthKey: DependencyKey {
    static var liveValue: any FirebaseAuthProtocol {
        fatalError("fireBaseAuth is not set.")
    }
}

public extension DependencyValues {
    var firebaseAuth: any FirebaseAuthProtocol {
        get { self[FirebaseAuthKey.self] }
        set { self[FirebaseAuthKey.self] = newValue }
    }
}
