//
//  FeatureBookmarkMainView.swift
//  FeatureBookmark
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents
import Model

public struct FeatureBookmarkMainView: View {
    public let store: StoreOf<FeatureBookmarkMainReducer>
    @Namespace private var animationNamespace  // matchedGeometryEffect 사용

    public init(store: StoreOf<FeatureBookmarkMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                BookmarkTabView(
                    tabs: [
                        .문제, .개념
                    ],
                    animationNamespace: animationNamespace,
                    selectedTab: viewStore.binding(
                        get: \.selectedTab,
                        send: FeatureBookmarkMainReducer.Action.selectTab
                    )
                )
                .padding(.init(top: 15, leading: 20, bottom: 20, trailing: 20))

                TabView(
                    selection: viewStore.binding(
                        get: \.selectedTab,
                        send: { .swipeTab($0) }
                    )) {
                        VStack(spacing: 0) {
                            HStack(alignment: .center, spacing: 8) {
                                BookmarkFilterBtnView(title: "모든 시험") {
                                    print("tap filter btn!")
                                }

                                BookmarkFilterBtnView(title: "모든 유형") {
                                    print("tap filter btn!")
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Text("틀린 문제만")
                                        .foregroundStyle(Color.Grayscale._900)
                                        .font(.system(size: 14, weight: .medium))

                                    Image(uiImage: UIComponentsAsset.checkCircle.image)
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(Color.Grayscale._300)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewStore.bookmarkItems) { item in
                                        BookmarkCardView(
                                            category: item.category,
                                            title: item.title,
                                            views: item.views,
                                            tags: item.tags,
                                            isBookmarked: item.isBookmarked
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)

                                Spacer()
                            }
                        }
                        .tag(BookmarkTabType.문제)

                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center) {
                                SortingBtnView(title: "A-Z순", onTap: {
                                    // viewStore.send(.showSheet(true))
                                })

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewStore.conceptItems) { item in
                                        ConceptListCell(
                                            concept: item,
                                            type: .regular,
                                            onTap: {
                                                print("onTap!")
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)

                                Spacer()
                            }
                        }
                        .tag(BookmarkTabType.개념)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: viewStore.selectedTab)
            }
        }
        .background(Color.Background._2)
    }
}

struct FeatureBookmarkMainView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureBookmarkMainView(
            store: Store(
                initialState: FeatureBookmarkMainReducer.State(),
                reducer: { FeatureBookmarkMainReducer() }
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
