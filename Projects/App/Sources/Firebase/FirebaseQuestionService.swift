//
//  FirebaseQuestionService.swift
//  DDAYO
//
//  Created by JJIKKYU on 3/31/25.
//

import FirebaseFirestore
import FirebaseStorage
import Model
import Service
import SwiftData

public struct FirebaseQuestionService: QuestionServiceProtocol {
    public init() {}

    @MainActor
    public func loadQuestions(context: ModelContext, version: Int) async throws -> [QuestionItem] {
        let localVersions = try context.fetch(FetchDescriptor<QuestionVersion>())
        let localVersion = localVersions.first?.version ?? 0
        print("🗂️ 로컬 버전 : \(localVersion), 서버 버전 : \(version)")

        let existingItems = try context.fetch(FetchDescriptor<QuestionItem>())
        let existingItemsMap: [String: QuestionItem] = Dictionary(
            uniqueKeysWithValues: existingItems.map { ($0.id, $0) }
        )

        // 한 번도 다운로드 받은 적이 없을 경우
        if existingItems.isEmpty {
            print("📦 기존 문제가 없으므로 번들에서 questions.json을 로딩합니다...")
            guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
                throw NSError(domain: "QuestionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "questions.json not found in bundle"])
            }

            let bundleData = try JSONDecoder().decode(QuestionBundleDataDTO.self, from: Data(contentsOf: url))
            let newItems = bundleData.items.compactMap { $0.toModel() }
            for item in newItems {
                context.insert(item)
            }

            if let existingVersion = localVersions.first {
                existingVersion.version = bundleData.version
            } else {
                context.insert(QuestionVersion(version: bundleData.version))
            }

            try context.save()
            print("✅ 번들에서 초기 문제 데이터를 로딩했습니다. 항목 수: \(newItems.count)")
            return newItems
        }

        if version <= localVersion {
            print("⏸️ 서버 버전이 최신이 아니므로 업데이트를 건너뜁니다.")
            return existingItems
        }

        print("☁️ Firebase Storage에서 최신 questions.json 다운로드 중...")
        let ref = Storage.storage().reference(withPath: "questions/questions.json")
        let downloadedData: Data = try await ref.data(maxSize: 10 * 1024 * 1024)
        let downloadedBundle = try JSONDecoder().decode(QuestionBundleDataDTO.self, from: downloadedData)
        print("✅ 다운로드 완료 - 항목 수: \(downloadedBundle.items.count)")

        if downloadedBundle.version != version {
            print("⏸️ 서버 버전 (\(version))과 다운로드된 JSON 버전 (\(downloadedBundle.version))이 일치하지 않아 세팅을 중지합니다.")
            return existingItems
        }

        var updatedItems: [QuestionItem] = []

        for dto in downloadedBundle.items {
            guard let model = dto.toModel() else { continue }
            var newModel = model
            let id: String = model.id
            if let existing = existingItemsMap[id] {
                if model.version > existing.version {
                    print("🔄 업데이트: \(id) (v\(existing.version) → v\(model.version))")
                    newModel.viewCount = existing.viewCount
                    context.delete(existing)
                    context.insert(newModel)
                    updatedItems.append(newModel)
                } else {
                    updatedItems.append(existing)
                }
            } else {
                print("🆕 추가: \(id) (v\(model.version))")
                context.insert(newModel)
                updatedItems.append(newModel)
            }
        }

        if let existingVersion = localVersions.first {
            existingVersion.version = version
        } else {
            context.insert(QuestionVersion(version: version))
        }

        try context.save()
        print("✅ 최종 업데이트된 문제 수: \(updatedItems.count)")
        return updatedItems
    }
}
