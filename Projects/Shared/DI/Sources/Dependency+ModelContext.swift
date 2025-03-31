//
//  Dependency+ModelContext.swift
//  DI
//
//  Created by JJIKKYU on 3/31/25.
//

import ComposableArchitecture
import SwiftData

private enum ModelContextKey: DependencyKey {
    static var liveValue: ModelContext {
        fatalError("modelContext가 주입되지 않았습니다.")
    }
}

public extension DependencyValues {
    var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }
}
