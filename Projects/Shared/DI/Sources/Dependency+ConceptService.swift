//
//  Dependency+ConceptService.swift
//  DI
//
//  Created by 정진균 on 4/2/25.
//

import ComposableArchitecture
import Service

private enum ConceptServiceKey: DependencyKey {
    static let liveValue: ConceptServiceProtocol = ConceptService()
}

public extension DependencyValues {
    var conceptService: ConceptServiceProtocol {
        get { self[ConceptServiceKey.self] }
        set { self[ConceptServiceKey.self] = newValue }
    }
}
