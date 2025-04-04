//
//  FeatureStudyDetailReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import DI
import Model
import SwiftData
import Foundation

@Reducer
public struct FeatureStudyDetailReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var items: [ConceptItem] = []
        var currentIndex: Int = 0

        public var currentItem: ConceptItem? {
            guard items.indices.contains(currentIndex) else { return nil }
            return items[currentIndex]
        }

        public init(
            items: [ConceptItem],
            index: Int
        ) {
            self.items = items
            self.currentIndex = index
        }
    }

    public enum Action {
        case onAppear
        case goPrevious
        case goNext
        case toggleBookmarkTapped
        case pressedBackBtn
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let currentItem = state.currentItem {
                    Task { [modelContext]
                        await updateRecentItem(modelContext, currentItem)
                    }
                }
                return .none

            case .pressedBackBtn:
                return .none

            case .goPrevious:
                if state.currentIndex > 0 {
                    state.currentIndex -= 1
                    if let currentItem = state.currentItem {
                        Task { [modelContext]
                            await updateRecentItem(modelContext, currentItem)
                        }
                    }
                }
                return .none

            case .goNext:
                if state.currentIndex < state.items.count - 1 {
                    state.currentIndex += 1
                    if let currentItem = state.currentItem {
                        Task { [modelContext]
                            await updateRecentItem(modelContext, currentItem)
                        }
                    }
                }
                return .none

            case .toggleBookmarkTapped:
                guard let currentItem = state.currentItem else {
                    print("FeatureStudyDetailReducer :: currentItem is nil")
                    return .none
                }

                return .run { send in
                    let conceptID: UUID = currentItem.id

                    let predicate = #Predicate<BookmarkItem> {
                        $0.questionID == conceptID
                    }

                    let existing = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first

                    if let existing {
                        modelContext.delete(existing)
                        try modelContext.save()
                    } else {
                        let newBookmark = BookmarkItem(questionID: conceptID)
                        modelContext.insert(newBookmark)
                        try modelContext.save()
                    }
                }
            }
        }
    }
}

// MARK: - extension

extension FeatureStudyDetailReducer {
    @MainActor
    private func updateRecentItem(_ modelContext: ModelContext, _ item: ConceptItem) {
        let allItems = try? modelContext.fetch(FetchDescriptor<RecentConceptItem>())
        allItems?.forEach { modelContext.delete($0) }

        let recent = RecentConceptItem(conceptId: item.id)
        modelContext.insert(recent)

        try? modelContext.save()
    }
}
