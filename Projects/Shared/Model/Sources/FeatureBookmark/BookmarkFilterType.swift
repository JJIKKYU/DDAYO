//
//  BookmarkFilterType.swift
//  Model
//
//  Created by 정진균 on 5/25/25.
//

public enum BookmarkFilterType {
    case test
    case type

    public func getLogName() -> String {
        switch self {
        case .test:
            return "test"

        case .type:
            return "type"
        }
    }
}
