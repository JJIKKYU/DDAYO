//
//  Dependency+DataVersionService.swift
//  DDAYO
//
//  Created by 정진균 on 5/31/25.
//


import ComposableArchitecture
import Service

extension DependencyValues {
    public var dataVersionService: DataVersionServiceProtocol {
        get { self[DataVersionServiceKey.self] }
        set { self[DataVersionServiceKey.self] = newValue }
    }
}

private enum DataVersionServiceKey: DependencyKey {
    static let liveValue: DataVersionServiceProtocol = FirebaseDataVersionServiceImp()
}
