//
//  BookmarkTab.swift
//  Model
//
//  Created by 정진균 on 3/29/25.
//

import Foundation

// MARK: - BookmarkTabType

public enum BookmarkTabType: Int, Equatable, CaseIterable, Codable {
    case 문제 = 0
    case 개념 = 1

    public func getName() -> String {
        switch self {
        case .문제:
            return "문제"

        case .개념:
            return "개념"
        }
    }

    public func getLogName() -> String {
        switch self {
        case .문제:
            return "ques"

        case .개념:
            return "concept"
        }
    }
}
