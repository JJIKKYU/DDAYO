//
//  FirestoreClientImpl.swift
//  DDAYO
//
//  Created by JJIKKYU on 3/31/25.
//

import ComposableArchitecture
import Service

extension DependencyValues {
    public var questionService: QuestionServiceProtocol {
        get { self[QuestionServiceKey.self] }
        set { self[QuestionServiceKey.self] = newValue }
    }
}

private enum QuestionServiceKey: DependencyKey {
    static let liveValue: QuestionServiceProtocol = FirebaseQuestionService()
}
