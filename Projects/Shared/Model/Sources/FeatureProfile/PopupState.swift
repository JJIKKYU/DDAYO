//
//  PopupState.swift
//  Model
//
//  Created by 정진균 on 6/1/25.
//

import Foundation

// MARK: - PopupState

public struct PopupState: Equatable {
    public var type: ProfilePopupType
    public var title: String
    public var desc: String
    public var leadingTitle: String
    public var trailingTitle: String
    public var allDone: Bool

    public init(type: ProfilePopupType, title: String, desc: String, leadingTitle: String, trailingTitle: String, allDone: Bool) {
        self.type = type
        self.title = title
        self.desc = desc
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.allDone = allDone
    }
}

// MARK: - ProfilePopupType

public enum ProfilePopupType {
    case logout
    case delete
}
