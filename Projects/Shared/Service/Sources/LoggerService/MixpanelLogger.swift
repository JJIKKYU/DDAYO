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
    var isEnabled: Bool { get set }

    func log(_ message: String)
    func log(_ message: String, parameters: [String: Any])

    func identify(id: String)
    func setIsEnabled(_ isEnabled: Bool)
}

// MARK: - MixpanelLogger

public class MixpanelLogger: MixpanelLoggerProtocol {
    public let instance: MixpanelInstance
    public var isEnabled: Bool = true

    public init() {
        let instance = Mixpanel.initialize(
            token: "d1466888a5a3d7e109e760ecda62f46f",
            automaticPushTracking: true
        )
        Mixpanel.mainInstance().flushInterval = 1
        self.instance = instance
    }

    public func identify(id: String) {
        instance.identify(distinctId: id)
    }

    public func setIsEnabled(_ isEnabled: Bool) {
        print("MixpanelLogger :: setIsEnabled = \(isEnabled)")
        self.isEnabled = isEnabled
    }

    func peopleSet() {
        // instance.identify(distinctId: <#T##String#>)
    }

    public func log(_ message: String) {
        if self.isEnabled == false { return }

        instance.track(event: message)
        print("MixpanelLogger :: event = \(message)")
    }

    public func log(_ message: String, parameters: [String: Any] = [:]) {
        if self.isEnabled == false { return }

        let converted: Properties = parameters.compactMapValues { value in
            value as? MixpanelType
        }

        instance.track(event: message, properties: converted)
        print("MixpanelLogger :: event = \(message), properties = \(converted)")
    }
}
