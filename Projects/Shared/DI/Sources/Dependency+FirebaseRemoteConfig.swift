//
//  Dependency+FirebaseRemoteConfig.swift
//  DI
//
//  Created by 정진균 on 5/23/25.
//

import ComposableArchitecture
import Service

private enum FirebaseRemoteConfigKey: DependencyKey {
    static var liveValue: any FirebaseRemoteConfigService {
        fatalError("fireBaseAuth is not set.")
    }
}

extension DependencyValues {
    public var remoteConfig: FirebaseRemoteConfigService {
        get { self[FirebaseRemoteConfigKey.self] }
        set { self[FirebaseRemoteConfigKey.self] = newValue }
    }
}
