//
//  Answer.swift
//  Model
//
//  Created by 정진균 on 3/8/25.
//

import Foundation

public struct QuizAnswer: Equatable, Hashable {
    public let number: Int
    public let title: String

    public init(number: Int, title: String) {
        self.number = number
        self.title = title
    }
}
