//
//  FirebaseQuestionService.swift
//  DDAYO
//
//  Created by JJIKKYU on 3/31/25.
//

import FirebaseFirestore
import Model
import Service

public struct FirebaseQuestionService: QuestionServiceProtocol {
    public init() {}

    public func fetchQuestionsFromFirebase() async throws -> [QuestionItemDTO] {
        let snapshot = try await Firestore.firestore().collection("questions").getDocuments()
        return try snapshot.documents.map {
            try $0.data(as: QuestionItemDTO.self)
        }
    }
}
