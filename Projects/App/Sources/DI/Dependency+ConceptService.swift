//
//  Dependency+ConceptService.swift
//  DDAYO
//
//  Created by 정진균 on 5/31/25.
//

import ComposableArchitecture
import Service

extension DependencyValues {
    public var conceptService: ConceptServiceProtocol {
        get { self[ConceptServiceKey.self] }
        set { self[ConceptServiceKey.self] = newValue }
    }
}

private enum ConceptServiceKey: DependencyKey {
    static let liveValue: ConceptServiceProtocol = ConceptService()
}
