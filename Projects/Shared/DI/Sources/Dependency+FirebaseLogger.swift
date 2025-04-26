//
//  Dependency+FirebaseLogger.swift
//  DI
//
//  Created by 정진균 on 4/26/25.
//

import ComposableArchitecture
import Service

private enum FirebaseLoggerKey: DependencyKey {
    static var liveValue: FirebaseLoggerProtocol {
        fatalError("!")
    }
}

public extension DependencyValues {
    var firebaseLogger: FirebaseLoggerProtocol {
        get { self[FirebaseLoggerKey.self] }
        set { self[FirebaseLoggerKey.self] = newValue }
    }
}
