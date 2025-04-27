//
//  Dependency+MixpanelLogger.swift
//  DI
//
//  Created by 정진균 on 4/27/25.
//

import ComposableArchitecture
import Service

private enum MixpanelLoggerKey: DependencyKey {
    static var liveValue: MixpanelLoggerProtocol {
        fatalError("!")
    }
}

public extension DependencyValues {
    var mixpanelLogger: MixpanelLoggerProtocol {
        get { self[MixpanelLoggerKey.self] }
        set { self[MixpanelLoggerKey.self] = newValue }
    }
}
