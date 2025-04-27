//
//  QuestionType.swift
//  Model
//
//  Created by 정진균 on 3/30/25.
//

import Foundation

public enum QuestionType: String, Equatable, CaseIterable, Codable {
    case all = "all"
    case past = "기출"
    case expected = "예상"
    case ai = "AI 예상"

    public var displayName: String {
        switch self {
        case .all: return "모든 유형"
        case .past: return "기출 문제"
        case .expected: return "예상 문제"
        case .ai: return "AI 예상 문제"
        }
    }
}
