//
//  ConceptItemDTO+ex.swift
//  Model
//
//  Created by 정진균 on 4/2/25.
//

import SwiftData
import Foundation

extension ConceptItemDTO {
    public func toModel() -> ConceptItem? {
        return ConceptItem(
            id: id,
            title: title,
            desc: description,
            subject: subject,
            subjectId: subjectId
        )
    }
}
