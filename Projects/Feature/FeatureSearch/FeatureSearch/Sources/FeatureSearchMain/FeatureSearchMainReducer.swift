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
            let bookmarkedIDs = Set(allBookmarkItems.map { $0.questionID })
            return matchedQuestionItems.map {
                BookmarkFeedItem(
                    category: $0.subject.rawValue,
                    title: $0.title,
                    views: "\($0.viewCount)",
                    tags: [],
                    isBookmarked: bookmarkedIDs.contains($0.id)
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
        case addRecentKeyword(String)
        case removeRecentKeyword(RecentSearchItem)
        case removeAllRecentKeywords
        case selectResult(String)
        case loadAllItems
        case loadRecentSearchItems
        case updateRecentSearchItems([RecentSearchItem])

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
        Reduce { state, action in
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
                case .quiz:
                    let matched = state.allQuestionItems
                        .filter { $0.title.localizedCaseInsensitiveContains(state.keyword) }
                    state.matchedQuestionItems = matched
                    state.results = matched.map { $0.title }
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
                return .run { _ in
                    guard !keyword.isEmpty else { return }
                    _ = try await MainActor.run {
                        let predicate = #Predicate<RecentSearchItem> { $0.keyword == keyword }
                        let exists = try modelContext.fetch(FetchDescriptor<RecentSearchItem>(predicate: predicate)).isEmpty == false

                        if !exists {
                            let item = RecentSearchItem(keyword: keyword, searchedAt: .now)
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
                // state.recentKeywords = []
                return .none

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

                    return .run { send in
                        await send(.navigateToStudyDetail(items: matchedConceptItems, index: index))
                    }

                case .quiz:
                    let matchedQuestionItems: [QuestionItem] = state.matchedQuestionItems
                    let selectedIndex: Int = index

                    return .run { send in
                        await send(.navigateToQuizPlay(questionItems: matchedQuestionItems, index: selectedIndex))
                    }
                }

            case .loadAllItems:
                guard let source = state.source else { return .none }
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
                    let recentSearchItems = try modelContext.fetch(FetchDescriptor<RecentSearchItem>(sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]))
                    state.recentKeywords = recentSearchItems
                } catch {
                    print("FeatureSearchMainReducer :: Failed to load RecentSearchItems: \(error)")
                }

                return .none

            case .loadRecentSearchItems:
                return .run { send in
                    do {
                        let recentKeywords = try await MainActor.run {
                            try modelContext
                                .fetch(FetchDescriptor<RecentSearchItem>(sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]))
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

            case .navigateToQuizPlay, .navigateToStudyDetail, .pressedBackBtn:
                return .none
            }
        }
    }
}
