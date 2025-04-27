//
//  FirebaseImpressionEventParameter.swift
//  Model
//
//  Created by 정진균 on 4/27/25.
//

import Foundation

public enum FBImpParamKey: String {
    case contentsType = "contents_type"
    case page
    case sessionID = "session_id"
    case quesID = "ques_id"
    case quesIndex = "ques_index"
    case ai
    case subjectDetail = "subject_detail"
    case languageDetail = "language_detail"
    case duration
    case conceptID = "concept_id"
    case conceptCardIndex = "concept_card_index"
    case conceptName = "concept_name"
    case conceptViewCount = "concept_view_count"
    case answer
}

public final class FBImpParamBuilder {
    private var parameters: [String: Any] = [:]

    public init() {}

    @discardableResult
    public func add(_ key: FBImpParamKey, value: Any?) -> Self {
        guard let value else { return self }
        parameters[key.rawValue] = value
        return self
    }

    public func build() -> [String: Any] {
        parameters
    }
}

public extension FBImpParamBuilder {
    @discardableResult
    func addIf(_ condition: Bool, _ key: FBImpParamKey, value: Any?) -> Self {
        if condition {
            self.add(key, value: value)
        }
        return self
    }
}
