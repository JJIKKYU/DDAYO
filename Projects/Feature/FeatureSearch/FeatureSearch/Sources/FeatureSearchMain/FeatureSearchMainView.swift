//
//  FeatureSearchMainView.swift
//  FeatureSearch
//
//  Created by 정진균 on 3/30/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Model

public struct FeatureSearchMainView: View {
    public let store: StoreOf<FeatureSearchMainReducer>
    @FocusState private var isTextFieldFocused: Bool

    public init(store: StoreOf<FeatureSearchMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    HStack {
                        TextField("", text: viewStore.binding(
                            get: \.keyword,
                            send: FeatureSearchMainReducer.Action.keywordChanged
                        ), prompt: Text(placeholderText)
                            .foregroundStyle(Color.Grayscale._300)
                            .font(.system(size: 14, weight: .medium))
                        )
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            viewStore.send(.selectResult(viewStore.keyword))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.Green._500, lineWidth: 1)
                            .background(Color.Background._2)
                    )
                    .padding(.leading, 16)

                    Button("취소") {
                        viewStore.send(.pressedBackBtn)
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.Grayscale._800)
                    .padding(.trailing, 16)
                }

                switch viewStore.mode {
                case .initial:
                    if viewStore.recentKeywords.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("최근 검색어 내역이 없습니다.")
                            Text(recentKeywordEmptyText)
                        }
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("최근 검색어")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.Grayscale._700)

                                Spacer()

                                Button("전체삭제") {
                                    viewStore.send(.removeAllRecentKeywords)
                                }
                                .font(.system(size: 12))
                                .foregroundColor(Color.Grayscale._500)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)

                            List {
                                ForEach(viewStore.recentKeywords, id: \.self) { keyword in
                                    RecentSearchCellView(
                                        keyword: keyword.keyword,
                                        searchedAt: keyword.searchedAt,
                                        onClose: {
                                            viewStore.send(.removeRecentKeyword(keyword))
                                        },
                                        onSelect: {
                                            viewStore.send(.selectRecentKeyword(keyword))
                                        })
                                    .listRowBackground(Color.Background._2)
                                    .padding(.vertical, 8)
                                }
                            }
                            .background(Color.Background._2)
                            .listStyle(.plain)
                        }
                    }

                case .searching:
                    List(viewStore.results, id: \.self) { result in
                        SearchResultCellView(
                            keyword: viewStore.keyword,
                            result: result,
                            onTap: {
                                viewStore.send(.selectResult(result))
                            }
                        )
                        .listRowBackground(Color.Background._2)
                    }
                    .background(Color.Background._2)
                    .listStyle(.plain)

                case .done:
                    switch viewStore.source {
                    case .quiz:
                        List(Array(viewStore.questionFeedItems.enumerated()), id: \.element) { index, item in
                            BookmarkCardView(
                                category: item.category,
                                title: item.title,
                                views: item.views,
                                tags: item.tags,
                                isBookmarked: viewStore.binding(
                                    get: { _ in item.isBookmarked },
                                    send: FeatureSearchMainReducer.Action.toggleBookmark(index: index)
                                ),
                                onTap: {
                                    viewStore.send(.selectCardView(index: index))
                                }
                            )
                            .listRowBackground(Color.Background._2)
                            .listRowSeparator(.hidden)
                        }
                        .listRowSeparator(.hidden)
                        .listStyle(.plain)

                    case .study:
                        List(Array(viewStore.conceptFeedItems.enumerated()), id: \.element) { index, item in
                            if let originItem: ConceptItem = item.originConceptItem {
                                ConceptListCell(
                                    concept: originItem,
                                    type: .regular,
                                    isBookmarked: viewStore.binding(
                                        get: { _ in item.isBookmarked },
                                        send: FeatureSearchMainReducer.Action.toggleBookmark(index: index)
                                    ),
                                    onTap: {
                                        viewStore.send(.selectCardView(index: index))
                                    }
                                )
                                .listRowBackground(Color.Background._2)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listStyle(.plain)

                    case .none:
                        EmptyView()
                    }
                }
            }
            .padding(.top, 16)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewStore.send(.loadAllItems)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
        .background(Color.Background._2)
    }
}

// MARK: - Extension

extension FeatureSearchMainView {
    public var recentKeywordEmptyText: String {
        switch store.source {
        case .quiz(let quizTab):
            switch quizTab {
            case .실기:
                return "찾으시는 문제를 검색해보세요"

            case .필기:
                return "찾으시는 문제를 검색해보세요"
            }
        case .study:
            return "궁금한 모든 개념을 검색해보세요"

        case .none:
            return "찾으시는 문제를 검색해보세요"
        }
    }

    public var placeholderText: String {
        switch store.source {
        case .quiz(let quizTab):
            switch quizTab {
            case .실기:
                return "찾으시는 문제를 검색해보세요"

            case .필기:
                return "찾으시는 문제를 검색해보세요"
            }
        case .study:
            return "궁금한 모든 개념을 검색해보세요"

        case .none:
            return "찾으시는 문제를 검색해보세요"
        }
    }
}
