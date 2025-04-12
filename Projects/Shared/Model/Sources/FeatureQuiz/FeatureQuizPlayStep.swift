//
//  FeatureQuizPlayStep.swift
//  Model
//
//  Created by 정진균 on 3/8/25.
//

import Foundation

public enum FeatureQuizPlayStep: Equatable, Hashable {
    case showAnswers
    case confirmAnswers
    case solvedQuestion(isCorrect: Bool)
}
