//
//  ExamType.swift
//  Model
//
//  Created by 정진균 on 3/29/25.
//

import Foundation

public enum ExamType: String, Equatable, CaseIterable {
    case all
    case written
    case practical

    public var displayName: String {
        switch self {
        case .all: return "모든 시험"
        case .written: return "필기 시험"
        case .practical: return "실기 시험"
        }
    }
}
