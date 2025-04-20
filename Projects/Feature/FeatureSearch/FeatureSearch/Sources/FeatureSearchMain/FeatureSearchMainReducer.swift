//
//  FeatureSearchMainReducer.swift
//  FeatureSearch
//
//  Created by 정진균 on 3/30/25.
//

import ComposableArchitecture
import DI
import Model
import SwiftData
import Foundation

public enum SearchMode: Equatable, Hashable {
    case initial
    case searching
    case done
}

@Reducer
public struct FeatureSearchMainReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public var source: FeatureSearchSource? = nil
        public var keyword: String = ""
        public var results: [String] = []
        public var recentKeywords: [RecentSearchItem] = []
        public var selectedKeyword: String = ""
        public var mode: SearchMode = .initial
        public var allConceptItems: [ConceptItem] = []
        public var allQuestionItems: [QuestionItem] = []
        public var allBookmarkItems: [BookmarkItem] = []

        public var matchedConceptItems: [ConceptItem] = []
        public var matchedQuestionItems: [QuestionItem] = []

        public var questionFeedItems: [BookmarkFeedItem] {
            let bookmarkedIDs: Set<UUID> = Set(
                allBookmarkItems.map { $0.questionID }
            )
            let wrongAnswerIDs: Set<UUID> = Set(
                allBookmarkItems
                    .filter({ $0.type == .문제 && $0.reason == .wrong})
                    .map { $0.questionID }
            )
            return matchedQuestionItems.map {
                let isWrong = wrongAnswerIDs.contains($0.id)
                let isBookmarked = bookmarkedIDs.contains($0.id)
                let tags: [String] = $0.tags(isWrong: isWrong)

                return BookmarkFeedItem(
                    category: $0.subject.rawValue,
                    title: $0.title,
                    views: "\($0.viewCount)",
                    tags: tags,
                    isBookmarked: isBookmarked
                )
            }
        }

        public var conceptFeedItems: [BookmarkFeedItem] {
            let bookmarkedIDs = Set(allBookmarkItems.map { $0.questionID })
            return matchedConceptItems.map {
                BookmarkFeedItem(
                    category: $0.subject,
                    title: $0.title,
                    views: "\($0.views)",
                    tags: [],
                    isBookmarked: bookmarkedIDs.contains($0.id),
                    originConceptItem: $0
                )
            }
        }

        public init(
            source: FeatureSearchSource? = nil
        ) {
            self.source = source
        }
    }

    public enum Action {
        case keywordChanged(String)
        case clear
        case search
        case selectResult(String)
        case loadAllItems
        case loadRecentSearchItems
        case updateRecentSearchItems([RecentSearchItem])

        // 최근 검색어
        case addRecentKeyword(String)
        case removeRecentKeyword(RecentSearchItem)
        case removeAllRecentKeywords
        case selectRecentKeyword(RecentSearchItem)

        // Bookmark
        case toggleBookmark(index: Int)
        case updateBookmarkStatus(index: Int, isBookmarked: Bool, itemId: UUID)

        // 검색 결과를 선택했을때
        case selectCardView(index: Int)

        // Navigateion
        case pressedBackBtn
        case navigateToQuizPlay(questionItems: [QuestionItem], index: Int)
        case navigateToStudyDetail(items: [ConceptItem], index: Int)
    }

    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .keywordChanged(text):
                guard state.keyword != text else { return .none }

                state.keyword = text
                state.mode = text.isEmpty ? .initial : .searching
                if state.mode == .initial {
                    return .send(.loadRecentSearchItems)
                }

                return .send(.search)

            case .search:
                guard let source = state.source else { return .none }
                switch source {
                    // ConceptItem
                case .study:
                    let matched = state.allConceptItems
                        .filter { $0.title.localizedCaseInsensitiveContains(state.keyword) }
                    state.matchedConceptItems = matched
                    state.results = matched.map { $0.title }

                    // QuestionItem
                case .quiz(let quizTab):
                    switch quizTab {
                    case .실기:
                        let matched: [QuestionItem] = state.allQuestionItems
                            .filter { $0.subject.quizTab == .실기 }
                            .filter { $0.title.localizedCaseInsensitiveContains(state.keyword) }
                        state.matchedQuestionItems = matched
                        state.results = matched.map { $0.title }

                    case .필기:
                        let matched: [QuestionItem] = state.allQuestionItems
                            .filter { $0.subject.quizTab == .필기 }
                            .filter { $0.title.localizedCaseInsensitiveContains(state.keyword) }
                        state.matchedQuestionItems = matched
                        state.results = matched.map { $0.title }
                    }
                }
                state.mode = .searching
                return .none

                // 현재는 미사용
            case .clear:
                state.keyword = ""
                state.results = []
                state.mode = .initial
                return .none

            case .addRecentKeyword(let keyword):
                guard let searchCategory: SearchCategory = state.source?.searchCategory else { return .none }
                return .run { _ in
                    guard !keyword.isEmpty else { return }
                    _ = try await MainActor.run {
                        let predicate = #Predicate<RecentSearchItem> { $0.keyword == keyword }
                        let exists = try modelContext.fetch(FetchDescriptor<RecentSearchItem>(predicate: predicate)).isEmpty == false

                        if !exists {
                            let item = RecentSearchItem(keyword: keyword, searchedAt: .now, searchCategoryRawValue: searchCategory.rawValue)
                            modelContext.insert(item)
                            try modelContext.save()
                        }
                    }
                }

            case .removeRecentKeyword(let keyword):
                print("FeatureSearchMainReducer :: removeRecentKeyword \(keyword.keyword)")

                return .run { @Sendable send in
                    try await MainActor.run {
                        modelContext.delete(keyword)
                        try modelContext.save()
                    }
                    await send(.loadRecentSearchItems)
                }

            case .removeAllRecentKeywords:
                guard let searchCategory = state.source?.searchCategory else { return .none }
                return .run { @Sendable send in
                    try await MainActor.run {
                        let predicate: Predicate<RecentSearchItem> = #Predicate {
                            $0.searchCategoryRawValue == searchCategory.rawValue
                        }
                        let itemsToDelete: [RecentSearchItem] = try modelContext.fetch(FetchDescriptor<RecentSearchItem>(predicate: predicate))
                        for item in itemsToDelete {
                            modelContext.delete(item)
                        }
                        try modelContext.save()
                    }
                    await send(.loadRecentSearchItems)
                }

            case .selectResult(let result):
                // keyword 선택시 그 keyword 기준으로 띄운다
                guard let source = state.source else { return .none }
                switch source {
                    // ConceptItem
                case .study:
                    let matched = state.allConceptItems
                        .filter { $0.title.localizedCaseInsensitiveContains(result) }
                    state.matchedConceptItems = matched
                    state.results = matched.map { $0.title }

                    // QuestionItem
                case .quiz:
                    let matched = state.allQuestionItems
                        .filter { $0.title.localizedCaseInsensitiveContains(result) }
                    state.matchedQuestionItems = matched
                    state.results = matched.map { $0.title }
                }
                state.selectedKeyword = result
                state.keyword = result
                state.mode = .done

                return .run { send in
                    await send(.addRecentKeyword(result))
                }

            case .selectCardView(let index):
                guard let source = state.source else { return .none }
                switch source {
                case .study:
                    let matchedConceptItems: [ConceptItem] = state.matchedConceptItems
                    let selectedIndex: Int = index
                    guard let conceptItem: ConceptItem = matchedConceptItems[safe: selectedIndex] else { return .none }

                    return .run { send in
                        try await MainActor.run {
                            conceptItem.views += 1
                            try modelContext.save()
                        }

                        await send(.navigateToStudyDetail(items: matchedConceptItems, index: index))
                    }

                case .quiz:
                    let matchedQuestionItems: [QuestionItem] = state.matchedQuestionItems
                    let selectedIndex: Int = index
                    guard let questionItem: QuestionItem = matchedQuestionItems[safe: selectedIndex] else { return .none }

                    return .run { send in
                        try await MainActor.run {
                            questionItem.viewCount += 1
                            try modelContext.save()
                        }

                        await send(.navigateToQuizPlay(questionItems: matchedQuestionItems, index: selectedIndex))
                    }
                }

            case .loadAllItems:
                guard let source = state.source else { return .none }
                guard let searchCategory: SearchCategory = state.source?.searchCategory else { return .none }

                switch source {
                    // ConceptItem
                case .study:
                    do {
                        let descriptor = FetchDescriptor<ConceptItem>()
                        let items = try modelContext.fetch(descriptor)
                        state.allConceptItems = items
                    } catch {
                        print("FeatureSearchMainReducer :: Failed to load ConceptItems: \(error)")
                    }

                    // QuestionItem
                case .quiz:
                    do {
                        let descriptor = FetchDescriptor<QuestionItem>()
                        let items = try modelContext.fetch(descriptor)
                        state.allQuestionItems = items
                    } catch {
                        print("FeatureSearchMainReducer :: Failed to load QuestionItems: \(error)")
                    }
                }

                do {
                    let bookmarks = try modelContext.fetch(FetchDescriptor<BookmarkItem>())
                    state.allBookmarkItems = bookmarks
                } catch {
                    print("FeatureSearchMainReducer :: Failed to load BookmarkItems: \(error)")
                }

                do {
                    let recentSearchItems: [RecentSearchItem] = try modelContext.fetch(
                        FetchDescriptor<RecentSearchItem>(
                            predicate: #Predicate { $0.searchCategoryRawValue == searchCategory.rawValue },
                            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
                        )
                    )
                    print("FeatureSearchMainReducer :: \(recentSearchItems)")
                    state.recentKeywords = recentSearchItems
                } catch {
                    print("FeatureSearchMainReducer :: Failed to load RecentSearchItems: \(error)")
                }

                return .none

            case .loadRecentSearchItems:
                guard let searchCategory: SearchCategory = state.source?.searchCategory else { return .none }
                return .run { send in
                    do {
                        let recentKeywords: [RecentSearchItem] = try await MainActor.run {
                            try modelContext.fetch(
                                FetchDescriptor<RecentSearchItem>(
                                    predicate: #Predicate { $0.searchCategoryRawValue == searchCategory.rawValue },
                                    sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
                                )
                            )
                        }
                        await send(.updateRecentSearchItems(recentKeywords))
                    } catch {
                        print("FeatureSearchMainReducer :: Failed to fetch recent search items: \(error)")
                    }
                }

            case .updateRecentSearchItems(let items):
                state.recentKeywords = items
                return .none

            case .toggleBookmark(let index):
                guard let source = state.source else { return .none }
                print("FeatureSearchMainReducer :: toggleBookmark, index = \(index)")

                switch source {
                case .quiz:
                    guard state.matchedQuestionItems.indices.contains(index) else { return .none }
                    let item: QuestionItem = state.matchedQuestionItems[index]
                    let questionItemId: UUID = item.id
                    let predicate: Predicate<BookmarkItem> = #Predicate<BookmarkItem> { $0.questionID == questionItemId }

                    return .run { send in
                        let isBookmarked: Bool = try await MainActor.run {
                            if let existing: BookmarkItem = try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first {
                                modelContext.delete(existing)
                                try modelContext.save()
                                return false
                                // state.allBookmarkItems.removeAll { $0.questionID == item.id }
                            } else {
                                let newBookmarkItem: BookmarkItem = .init(questionID: questionItemId, type: .문제, reason: .manual)
                                modelContext.insert(newBookmarkItem)
                                try modelContext.save()
                                return true
                                // state.allBookmarkItems.append(newBookmarkItem)
                            }
                        }

                        await send(.updateBookmarkStatus(index: index, isBookmarked: isBookmarked, itemId: questionItemId))
                    }

                case .study:
                    guard state.matchedConceptItems.indices.contains(index) else { return .none }
                    let item: ConceptItem = state.matchedConceptItems[index]
                    let conceptItemId: UUID = item.id
                    let predicate: Predicate<BookmarkItem> = #Predicate<BookmarkItem> { $0.questionID == conceptItemId }

                    if let existing: BookmarkItem = try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first {
                        modelContext.delete(existing)
                        try? modelContext.save()
                        state.allBookmarkItems.removeAll { $0.questionID == item.id }
                    } else {
                        let newBookmarkItem: BookmarkItem = .init(questionID: item.id, type: .개념, reason: .manual)
                        modelContext.insert(newBookmarkItem)
                        try? modelContext.save()
                        state.allBookmarkItems.append(newBookmarkItem)
                    }
                }

                return .none

            case .updateBookmarkStatus(let index, let isBookmarked, let itemId):
                guard let source: FeatureSearchSource = state.source else { return .none }

                switch source {
                case .quiz:
                    // 이미 있는 북마크 제거
                    state.allBookmarkItems.removeAll { $0.questionID == itemId }

                    // 새로 북마크 추가
                    if isBookmarked {
                        let newBookmarkItem = BookmarkItem(questionID: itemId, type: .문제, reason: .manual)
                        state.allBookmarkItems.append(newBookmarkItem)
                    }

                case .study:
                    state.allBookmarkItems.removeAll { $0.questionID == itemId }

                    if isBookmarked {
                        let newBookmarkItem = BookmarkItem(questionID: itemId, type: .개념, reason: .manual)
                        state.allBookmarkItems.append(newBookmarkItem)
                    }
                }

                return .none

            case .selectRecentKeyword(let item):
                return .send(.selectResult(item.keyword))

            case .navigateToQuizPlay,
                    .navigateToStudyDetail,
                    .pressedBackBtn:
                return .none
            }
        }
    }
}
