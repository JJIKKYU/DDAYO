//
//  FirebaseLogger.swift
//  Service
//
//  Created by 정진균 on 4/26/25.
//

import Foundation
import Model

// MARK: - FirebaseEvent

public enum FirebaseEvent: String {
    case click = "click"
    case impression = "impression"
}

// MARK: - FirebaseLoggerProtocol

public protocol FirebaseLoggerProtocol {
    func logEvent(_ event: FirebaseEvent, parameters: [String: Any]?)
}
