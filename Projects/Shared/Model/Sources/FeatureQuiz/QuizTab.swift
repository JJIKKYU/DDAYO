//
//  QuizTab.swift
//  Model
//
//  Created by 정진균 on 3/30/25.
//

import Foundation

// MARK: - 필기, 실기 선택 상태 정의

public enum QuizTab: Int, Equatable, CaseIterable {
    case 필기 = 0
    case 실기 = 1

    public func getName() -> String {
        switch self {
        case .필기:
            return "필기"

        case .실기:
            return "실기"
        }
    }
}
