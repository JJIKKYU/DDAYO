//
//  FirebaseClickEventParameter.swift
//  Model
//
//  Created by 정진균 on 4/27/25.
//

import Foundation

// MARK: - FirebaseClickEventParameter

public struct FBClickParam {
    public let clickTarget: String
    public let sessionID: String
    public let customParameters: [String: Any]

    public var parameters: [String: Any] {
        var base: [String: Any] = [
            "click_target": clickTarget,
            "session_id": sessionID
        ]
        base.merge(customParameters) { $1 }
        return base
    }

    public init(
        clickTarget: String,
        sessionID: String = "",
        customParameters: [String: Any] = [:]
    ) {
        self.clickTarget = clickTarget
        self.sessionID = sessionID
        self.customParameters = customParameters
    }
}
