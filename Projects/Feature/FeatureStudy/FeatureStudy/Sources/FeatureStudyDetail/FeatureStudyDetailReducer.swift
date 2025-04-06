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
        var isBookmarked: Bool = false

        public var currentItem: ConceptItem? {
            guard items.indices.contains(currentIndex) else { return nil }
            return items[currentIndex]
        }

        public init(
            items: [ConceptItem],
            index: Int,
            isBookmarked: Bool = false
        ) {
            self.items = items
            self.currentIndex = index
            self.isBookmarked = isBookmarked
        }
    }

    public enum Action {
        case onAppear
        case goPrevious
        case goNext

        // 북마크 버튼을 눌렀을 경우
        case toggleBookmarkTapped
        // 북마크 상태 업데이트가 필요할 경우
        case updateBookmarkStatus(Bool)

        case pressedBackBtn
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let currentItem = state.currentItem else { return .none }

                let currentItemId: UUID = currentItem.id
                Task { [modelContext] in
                    await updateRecentItem(modelContext, currentItem)
                }

                let bookmarkPredicate = #Predicate<BookmarkItem> { $0.questionID == currentItemId }
                let isBookmarked = (try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate)).isEmpty == false) ?? false

                return .run { send in
                    await send(.updateBookmarkStatus(isBookmarked))
                }

            case .pressedBackBtn:
                return .none

            case .goPrevious:
                guard state.currentIndex > 0 else { return .none }

                state.currentIndex -= 1
                guard let currentItem = state.currentItem else { return .none }

                let currentItemId: UUID = currentItem.id
                Task { [modelContext] in
                    await updateRecentItem(modelContext, currentItem)
                }

                let bookmarkPredicate = #Predicate<BookmarkItem> { $0.questionID == currentItemId }
                let isBookmarked = (try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate)).isEmpty == false) ?? false

                return .run { send in
                    await send(.updateBookmarkStatus(isBookmarked))
                }

            case .goNext:
                guard state.currentIndex < state.items.count - 1 else { return .none }
                state.currentIndex += 1

                let currentItem = state.currentItem!
                let currentItemId: UUID = currentItem.id
                Task { [modelContext] in
                    await updateRecentItem(modelContext, currentItem)
                }

                let bookmarkPredicate = #Predicate<BookmarkItem> { $0.questionID == currentItemId }
                let isBookmarked = (try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate)).isEmpty == false) ?? false

                return .run { send in
                    await send(.updateBookmarkStatus(isBookmarked))
                }

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
                        await send(.updateBookmarkStatus(false))
                    } else {
                        let newBookmark = BookmarkItem(
                            questionID: conceptID,
                            type: .개념,
                            reason: .manual
                        )
                        modelContext.insert(newBookmark)
                        try modelContext.save()
                        await send(.updateBookmarkStatus(true))
                    }
                }

            case .updateBookmarkStatus(let bookmarked):
                state.isBookmarked = bookmarked
                return .none
            }
        }
    }
}

// MARK:: - extension

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
