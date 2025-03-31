//
//  QuestionServiceProtocol.swift
//  Service
//
//  Created by JJIKKYU on 3/31/25.
//

import Model

public protocol QuestionServiceProtocol {
    func fetchQuestionsFromFirebase() async throws -> [QuestionItemDTO]
}
