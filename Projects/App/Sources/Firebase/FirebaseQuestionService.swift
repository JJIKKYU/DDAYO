//
//  FirebaseQuestionService.swift
//  DDAYO
//
//  Created by JJIKKYU on 3/31/25.
//

import FirebaseFirestore
import Model
import Service
import SwiftData

public struct FirebaseQuestionService: QuestionServiceProtocol {
    public init() {}

    @MainActor
    public func fetchQuestionsFromFirebase() async throws -> [QuestionItemDTO] {
        let snapshot = try await Firestore.firestore().collection("questions").getDocuments()
        return try snapshot.documents.map {
            try $0.data(as: QuestionItemDTO.self)
        }
    }

    @MainActor
    public func loadQuestionsAndSyncWithLocal(context: ModelContext) throws -> [QuestionItem] {
        // 1. json loadun
        print("📦 번들에서 questions.json 파일을 로딩 중입니다...")
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw NSError(domain: "QuestionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON 파일을 번들에서 찾을 수 없습니다."])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let bundleData = try decoder.decode(QuestionBundleDataDTO.self, from: data)
        print("✅ 번들 데이터 로딩 완료 - 버전: \(bundleData.version)")

        // Fetch local version from SwiftData
        let localVersions = try context.fetch(FetchDescriptor<QuestionVersion>())
        print("🗂️ 로컬 버전 확인됨: \(localVersions.map(\.version))")

        let existingItems = try context.fetch(FetchDescriptor<QuestionItem>())
        var updatedItems: [QuestionItem] = []

        let existingItemsMap = Dictionary(uniqueKeysWithValues: existingItems.map { ($0.id, $0) })

        if let localVersion = localVersions.first, bundleData.version > localVersion.version {
            print("🔄 새로운 번들 버전으로 기존 문제들을 업데이트합니다...")
            for dto in bundleData.items {
                guard let model = dto.toModel() else { continue }
                if let existing = existingItemsMap[model.id] {
                    if model.version > existing.version {
                        context.delete(existing)
                        context.insert(model)
                        updatedItems.append(model)
                    } else {
                        updatedItems.append(existing)
                    }
                } else {
                    context.insert(model)
                    updatedItems.append(model)
                }
            }

            localVersion.version = bundleData.version
        } else if localVersions.isEmpty {
            print("📥 로컬 버전이 없어 모든 문제와 버전 정보를 새로 삽입합니다...")
            for dto in bundleData.items {
                guard let model = dto.toModel() else { continue }
                context.insert(model)
                updatedItems.append(model)
            }

            let newVersion = QuestionVersion(version: bundleData.version)
            context.insert(newVersion)
        } else {
            print("⏸️ 번들 버전이 최신이 아니므로 업데이트를 건너뜁니다.")
            updatedItems = existingItems
        }

        try context.save()

        print("✅ 최종 업데이트된 문제 수: \(updatedItems.count)")
        return updatedItems
    }
}
