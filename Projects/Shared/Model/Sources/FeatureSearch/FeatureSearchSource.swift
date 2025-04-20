//
//  FeatureSearchSource.swift
//  Model
//
//  Created by 정진균 on 3/30/25.
//

import Foundation

public enum FeatureSearchSource: Equatable, Hashable {
    case study
    case quiz(QuizTab)
    // case bookmark
}

extension FeatureSearchSource {
    public var searchCategory: SearchCategory {
        switch self {
        case .study:
            return .개념

        case .quiz(let tab):
            switch tab {
            case .필기:
                return .필기
            case .실기:
                return .실기
            }
        }
    }
}
