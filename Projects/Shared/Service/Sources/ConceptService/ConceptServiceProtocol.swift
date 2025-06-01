//  ConceptServiceProtocol.swift
//  Service
//
//  Created by 정진균 on 4/2/25.
//

import Foundation
import Model
import SwiftData

public protocol ConceptServiceProtocol {
    func loadConcepts(context: ModelContext, version: Int) async throws -> [ConceptItem]
}
