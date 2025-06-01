//
//  FirebaseConceptServiceImp.swift
//  DDAYO
//
//  Created by 정진균 on 5/31/25.
//
import Foundation
import Model
import SwiftData
import FirebaseStorage
import Service

public struct ConceptService: ConceptServiceProtocol {
    public init() {}

    public func loadConcepts(context: ModelContext, version: Int) async throws -> [ConceptItem] {
        print("📦 번들에서 concepts.json 파일을 로딩 중입니다...")
        guard let url = Bundle.main.url(forResource: "concepts", withExtension: "json") else {
            throw NSError(domain: "ConceptService", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON file not found in bundle"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let bundleData = try decoder.decode(ConceptBundleDataDTO.self, from: data)
        print("✅ 번들 데이터 로딩 완료 - 버전: \(bundleData.version)")

        let localVersions = try context.fetch(FetchDescriptor<ConceptVersion>())
        let localVersion = localVersions.first?.version ?? 0
        print("🗂️ 로컬 버전 : \(localVersion), 서버 버전 : \(version)")

        let existingItems: [ConceptItem] = (try? context.fetch(FetchDescriptor<ConceptItem>())) ?? []
        if existingItems.isEmpty {
            print("📦 기존 개념이 없으므로 번들에서 concepts.json을 로딩합니다...")
            guard let url = Bundle.main.url(forResource: "concepts", withExtension: "json") else {
                throw NSError(domain: "ConceptService", code: 1, userInfo: [NSLocalizedDescriptionKey: "concepts.json not found in bundle"])
            }

            let bundleData = try JSONDecoder().decode(ConceptBundleDataDTO.self, from: Data(contentsOf: url))
            let newItems = bundleData.items.compactMap { $0.toModel() }
            for item in newItems {
                context.insert(item)
            }

            if let existingVersion = localVersions.first {
                existingVersion.version = bundleData.version
            } else {
                context.insert(ConceptVersion(version: bundleData.version))
            }

            try context.save()
            print("✅ 번들에서 초기 개념 데이터를 로딩했습니다. 항목 수: \(newItems.count)")
            return newItems
        }

        guard version > localVersion else {
            print("⏸️ 서버 버전이 최신이 아니므로 업데이트를 건너뜁니다.")
            return existingItems
        }

        // Firebase Storage에서 최신 concepts.json 다운로드
        print("☁️ Firebase Storage에서 최신 concepts.json 다운로드 중...")
        let storageRef = Storage.storage().reference(withPath: "concepts/concepts.json")
        let downloadedData: Data = try await storageRef.data(maxSize: 5 * 1024 * 1024) // 최대 5MB
        let downloadedBundle: ConceptBundleDataDTO = try JSONDecoder().decode(ConceptBundleDataDTO.self, from: downloadedData)
        print("✅ 다운로드 완료 - 항목 수: \(downloadedBundle.items.count)")

        if downloadedBundle.version != version {
            print("⏸️ 서버 버전 (\(version))과 다운로드된 JSON 버전 (\(downloadedBundle.version))이 일치하지 않아 세팅을 중지합니다.")
            return existingItems
        }

        // 기존 데이터 삭제
        print("🧹 기존 개념 데이터를 삭제합니다... \(existingItems.count)개")
        for item in existingItems {
            context.delete(item)
        }

        // 새 데이터 삽입
        let newItems = downloadedBundle.items.compactMap { $0.toModel() }
        print("📥 새로운 개념 데이터를 저장합니다... 총 \(newItems.count)개")
        for item in newItems {
            context.insert(item)
        }

        // 버전 정보 업데이트
        if let existingVersion = localVersions.first {
            context.delete(existingVersion)
        }
        context.insert(ConceptVersion(version: version))

        try context.save()
        print("✅ 최종 업데이트된 개념 수: \(newItems.count)")
        return newItems
    }
}
