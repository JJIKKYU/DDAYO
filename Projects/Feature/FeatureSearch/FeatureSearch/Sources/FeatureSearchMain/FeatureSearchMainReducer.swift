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
        public var recentKeywords: [String] = []
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
                    isBookmarked: bookmarkedIDs.contains($0.id)
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
        case removeRecentKeyword(String)
        case removeAllRecentKeywords
        case selectResult(String)
        case loadAllItems

        // 검색 결과를 선택했을때
        case selectCardView(index: Int)

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
                    return .none
                }

                return .run { send in
                    await send(.search)
                }

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

            case .clear:
                state.keyword = ""
                state.results = []
                state.mode = .initial
                return .none

            case .addRecentKeyword(let keyword):
                if !keyword.isEmpty && !state.recentKeywords.contains(keyword) {
                    state.recentKeywords.insert(keyword, at: 0)
                }
                return .none

            case .removeRecentKeyword(let keyword):
                state.recentKeywords.removeAll { $0 == keyword }
                return .none

            case .removeAllRecentKeywords:
                state.recentKeywords = []
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
                        print("Failed to load ConceptItems: \(error)")
                    }

                // QuestionItem
                case .quiz:
                    do {
                        let descriptor = FetchDescriptor<QuestionItem>()
                        let items = try modelContext.fetch(descriptor)
                        state.allQuestionItems = items
                    } catch {
                        print("Failed to load QuestionItems: \(error)")
                    }
                }

                do {
                    let bookmarks = try modelContext.fetch(FetchDescriptor<BookmarkItem>())
                    state.allBookmarkItems = bookmarks
                } catch {
                    print("Failed to load BookmarkItems: \(error)")
                }
                return .none

            case .navigateToQuizPlay, .navigateToStudyDetail:
                return .none
            }
        }
    }
}
