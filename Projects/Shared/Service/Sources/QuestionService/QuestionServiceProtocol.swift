//
//  QuestionServiceProtocol.swift
//  Service
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation
import Model
import SwiftData

public protocol QuestionServiceProtocol {
    func loadQuestions(context: ModelContext, version: Int) async throws -> [QuestionItem]
}
