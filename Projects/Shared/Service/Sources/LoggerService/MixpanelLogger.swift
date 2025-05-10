//
//  MixpanelLogger.swift
//  Service
//
//  Created by 정진균 on 4/27/25.
//

import Foundation
import Mixpanel

// MARK: - MixpanelLoggerProtocol

public protocol MixpanelLoggerProtocol {
    func log(_ message: String)
    func log(_ message: String, parameters: [String: Any])
}

// MARK: - MixpanelLogger

public struct MixpanelLogger: MixpanelLoggerProtocol {
    public let instance: MixpanelInstance

    public init() {
        let instance = Mixpanel.initialize(
            token: "d1466888a5a3d7e109e760ecda62f46f",
            automaticPushTracking: true
        )
        Mixpanel.mainInstance().flushInterval = 1
        self.instance = instance
    }

    func peopleSet() {
        // instance.identify(distinctId: <#T##String#>)
    }

    public func log(_ message: String) {
        instance.track(event: message)
        print("MixpanelLogger :: event = \(message)")
    }

    public func log(_ message: String, parameters: [String: Any] = [:]) {
        let converted: Properties = parameters.compactMapValues { value in
            value as? MixpanelType
        }

        instance.track(event: message, properties: converted)
        print("MixpanelLogger :: event = \(message), properties = \(converted)")
    }
}
