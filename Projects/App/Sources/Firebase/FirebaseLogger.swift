//
//  FirebaseLogger.swift
//  DDAYO
//
//  Created by 정진균 on 4/26/25.
//

import Foundation
import FirebaseAnalytics
import Service

public final class FirebaseLogger: FirebaseLoggerProtocol {
    public init() {}

    public func logEvent(_ event: Service.FirebaseEvent, parameters: [String : Any]?) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}
