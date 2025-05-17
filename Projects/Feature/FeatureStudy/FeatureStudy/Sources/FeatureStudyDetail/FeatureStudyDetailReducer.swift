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
    @Dependency(\.mixpanelLogger) var mixpanelLogger

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var items: [ConceptItem] = []
        var currentIndex: Int = 0
        var isBookmarked: Bool = false
        var isPopupPresented: Bool = false // study 종료 뷰 표시 여부

        public var currentItem: ConceptItem? {
            guard items.indices.contains(currentIndex) else { return nil }
            return items[currentIndex]
        }

        var canGoPrevious: Bool {
            currentIndex > 0
        }

        var canGoNext: Bool {
            currentIndex < items.count - 1
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
        // 처음부터 다시 개념 공부 시작
        case restartStudy

        // 팝업 표시
        case showPopup
        // 팝업 숨기기
        case hidePopup(popupAction: StudyPopupAction)

        case pressedBackBtn
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let currentItem = state.currentItem else { return .none }
                let currentItemId = currentItem.id

                mixpanelLogger.log(
                    "imp_concept",
                    parameters: LogParamBuilder()
                        .add(.conceptID, value: currentItemId)
                        .add(.conceptIndex, value: state.currentIndex)
                        .add(.conceptName, value: currentItem.title)
                        .add(.conceptViewCount, value: currentItem.views)
                        .build()
                )

                return .run { send in
                    await MainActor.run {
                        // 최근 본 개념 초기화 후 저장
                        let allItems = try? modelContext.fetch(FetchDescriptor<RecentConceptItem>())
                        allItems?.forEach { modelContext.delete($0) }

                        let recent = RecentConceptItem(conceptId: currentItemId)
                        modelContext.insert(recent)

                        try? modelContext.save()
                    }

                    // 북마크 여부 확인
                    let isBookmarked: Bool = await MainActor.run {
                        let bookmarkPredicate = #Predicate<BookmarkItem> { $0.questionID == currentItemId }
                        let bookmarks = try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate))
                        return bookmarks?.isEmpty == false
                    }

                    await send(.updateBookmarkStatus(isBookmarked))
                }

            case .pressedBackBtn:
                return .none

            case .goPrevious:
                if let currentItem: ConceptItem = state.currentItem {
                    mixpanelLogger.log(
                        "click_prev_concept_btn",
                        parameters: LogParamBuilder()
                            .add(.conceptID, value: currentItem.id)
                            .add(.conceptIndex, value: state.currentIndex)
                            .add(.conceptName, value: currentItem.title)
                            .add(.conceptViewCount, value: currentItem.views)
                            .build()
                    )
                }

                return handlePageMove(&state, direction: -1)

            case .goNext:
                if let currentItem: ConceptItem = state.currentItem {
                    mixpanelLogger.log(
                        "click_next_concept_btn",
                        parameters: LogParamBuilder()
                            .add(.conceptID, value: currentItem.id)
                            .add(.conceptIndex, value: state.currentIndex)
                            .add(.conceptName, value: currentItem.title)
                            .add(.conceptViewCount, value: currentItem.views)
                            .build()
                    )
                }

                return handlePageMove(&state, direction: 1)

            case .toggleBookmarkTapped:
                guard let currentItem = state.currentItem else {
                    print("FeatureStudyDetailReducer :: currentItem is nil")
                    return .none
                }

                return .run { send in
                    let conceptID: String = currentItem.id

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
//                event : click_bookmark_btn
//                page : concept
//                concept_id : {}
//                concept_index : 3
//                concept_name : “name”
//                concept_view_count : 0
//                session_id : {}

                if let currentConcept: ConceptItem = state.currentItem {
                    var eventName: String = "click_bookmark_btn"
                    if bookmarked == false {
                        eventName = "click_unbookmark_btn"
                    }
                    mixpanelLogger.log(
                        eventName,
                        parameters: LogParamBuilder()
                            .add(.page, value: "concept")
                            .add(.conceptID, value: currentConcept.id)
                            .add(.conceptIndex, value: state.currentIndex)
                            .add(.conceptName, value: currentConcept.title)
                            .add(.conceptViewCount, value: currentConcept.views)
                            .build()
                    )
                }

                state.isBookmarked = bookmarked
                return .none

            case .showPopup:
                state.isPopupPresented = true
                return .none

            case .hidePopup(let action):
                switch action {
                case .review:
                    state.isPopupPresented = false
                    return .send(.restartStudy)

                case .dismiss:
                    return .send(.pressedBackBtn)
                }

            case .restartStudy:
                state.currentIndex = 0
                return .none
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

    private func handlePageMove(_ state: inout State, direction: Int) -> Effect<Action> {
        let newIndex = state.currentIndex + direction
        guard state.items.indices.contains(newIndex) else {
            // 다음이 없을 경우에는 팝업을 노출하도록
            return .send(.showPopup)
        }

        state.currentIndex = newIndex
        guard let currentItem = state.currentItem else { return .none }
        let currentItemId: String = currentItem.id

        return .run { send in
            await MainActor.run {
                // 최근 본 개념 초기화 후 저장
                let allItems: [RecentConceptItem]? = try? modelContext.fetch(FetchDescriptor<RecentConceptItem>())
                allItems?.forEach { modelContext.delete($0) }

                let recent: RecentConceptItem = .init(conceptId: currentItemId)
                modelContext.insert(recent)

                // 조회수 증가
                currentItem.views += 1
                try? modelContext.save()
            }

            // 북마크 여부 확인
            let isBookmarked: Bool = await MainActor.run {
                let bookmarkPredicate: Predicate<BookmarkItem> = #Predicate { $0.questionID == currentItemId }
                let bookmarks: [BookmarkItem]? = try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate))
                let isBookmarked = (bookmarks?.isEmpty == false)

                return isBookmarked
            }

            await send(.updateBookmarkStatus(isBookmarked))
        }
    }
}
