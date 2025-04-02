//  ConceptServiceProtocol.swift
//  Service
//
//  Created by 정진균 on 4/2/25.
//

import Foundation
import Model
import SwiftData

public protocol ConceptServiceProtocol {
    func loadConceptsFromBundle() throws -> [ConceptItemDTO]
    func loadConceptsAndSyncWithLocal(context: ModelContext) throws -> [ConceptItem]
}

public struct ConceptService: ConceptServiceProtocol {
    public init() {}

    public func loadConceptsFromBundle() throws -> [ConceptItemDTO] {
        guard let url = Bundle.main.url(forResource: "concepts", withExtension: "json") else {
            throw NSError(domain: "ConceptService", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON file not found in bundle"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        let bundleData = try decoder.decode(ConceptBundleDataDTO.self, from: data)
        return bundleData.items
    }

    public func loadConceptsAndSyncWithLocal(context: ModelContext) throws -> [ConceptItem] {
        // 1. json load
        guard let url = Bundle.main.url(forResource: "concepts", withExtension: "json") else {
            throw NSError(domain: "ConceptService", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON file not found in bundle"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let bundleData = try decoder.decode(ConceptBundleDataDTO.self, from: data)

        // Fetch local version from SwiftData
        let localVersions = try context.fetch(FetchDescriptor<ConceptVersion>())
        let localVersion = localVersions.first?.version ?? 0

        // 버전이 같으면 그대로 반환
        let existingItems = try context.fetch(FetchDescriptor<ConceptItem>())
        guard bundleData.version > localVersion else {
            return existingItems
        }

        // 기존 데이터 삭제
        for item in existingItems {
            context.delete(item)
        }

        // 새 데이터 저장
        let newItems = bundleData.items.compactMap { $0.toModel() }
        for item in newItems {
            context.insert(item)
        }

        // Update stored version
        if let existingVersion = localVersions.first {
            context.delete(existingVersion)
        }
        context.insert(ConceptVersion(version: bundleData.version))

        try context.save()

        return newItems
    }
}
