//
//  QuestionType.swift
//  Model
//
//  Created by 정진균 on 3/30/25.
//

import Foundation

public enum QuestionType: String, Equatable, CaseIterable {
    case all
    case past
    case predicted

    public var displayName: String {
        switch self {
        case .all: return "모든 유형"
        case .past: return "기출 문제"
        case .predicted: return "AI 예상 문제"
        }
    }
}
