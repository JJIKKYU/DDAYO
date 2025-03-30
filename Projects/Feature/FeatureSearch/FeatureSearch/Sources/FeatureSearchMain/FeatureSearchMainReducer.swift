//
//  FeatureSearchMainReducer.swift
//  FeatureSearch
//
//  Created by 정진균 on 3/30/25.
//

import ComposableArchitecture
import Model

public enum SearchMode: Equatable {
    case initial
    case searching
    case done
}

@Reducer
public struct FeatureSearchMainReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public var source: FeatureSearchSource? = nil
        public var keyword: String = ""
        public var results: [String] = []
        public var recentKeywords: [String] = []
        public var mode: SearchMode = .initial

        public init(source: FeatureSearchSource? = nil) {
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
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .keywordChanged(text):
                state.keyword = text
                state.mode = text.isEmpty ? .initial : .searching
                if state.mode == .initial {
                    return .none
                }

                return .run { send in
                    await send(.search)
                }

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

            case .search:
                state.results = dummyData.filter {
                    $0.localizedCaseInsensitiveContains(state.keyword)
                }
                state.mode = .searching
                let keyword = state.keyword
                return .run { send in
                    await send(.addRecentKeyword(keyword))
                }
            }
        }
    }

    private var dummyData: [String] {
        [
            "UML", "ERD", "Agile", "Scrum", "Stack", "Queue", "Semaphore",
            "TCP/IP", "HTTP", "Encryption", "Normalization", "REST", "JWT",
            "iOS", "Android", "Swift", "Kotlin", "ViewModel", "Reducer", "TCA"
        ]
    }
}
