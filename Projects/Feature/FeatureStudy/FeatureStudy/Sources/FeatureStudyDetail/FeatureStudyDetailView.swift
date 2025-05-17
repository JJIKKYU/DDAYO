//
//  FeatureStudyDetailView.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents

public struct FeatureStudyDetailView: View {
    public let store: StoreOf<FeatureStudyDetailReducer>

    public init(store: StoreOf<FeatureStudyDetailReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe:  { $0 }) { viewStore in
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    NaviBar(type: .studyDetail, title: "개념 학습", trailing1: {
                        viewStore.send(.pressedBackBtn)
                    })

                    ScrollView {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewStore.currentItem?.title ?? "")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color.Grayscale._900)

                                Spacer()
                            }
                            .padding(.bottom, 16)

                            /*
                             이미지가 필요할 경우에 활성화
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.Grayscale._50)
                                .frame(height: 200)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundStyle(Color.Grayscale._400)

                                        Text("이미지 영역입니다")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundStyle(Color.Grayscale._400)
                                    }
                                )
                                .padding(.bottom, 16)
                            */

                            MarkdownTextView(text: viewStore.currentItem?.desc ?? "")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.Grayscale._700)
                                .lineSpacing(6.5)
                                .multilineTextAlignment(.leading)
                                // .padding(.top, 12)
                                .padding(.all, 0)

                            HStack(alignment: .center, spacing: 0) {
                                Image(uiImage: UIComponentsAsset.eye.image)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color.Grayscale._300)
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 2)

                                Text("\(viewStore.currentItem?.views ?? 0)회")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.Grayscale._400)

                                Spacer()
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 90)
                    }
                    .frame(maxHeight: .infinity)
                }

                StudyBottomBtnView(
                    isBookmarked: viewStore.binding(
                        get: \.isBookmarked,
                        send: FeatureStudyDetailReducer.Action.updateBookmarkStatus),
                    onSelectBookmark: { viewStore.send(.toggleBookmarkTapped) },
                    prevAction: { viewStore.send(.goPrevious) },
                    nextAction: { viewStore.send(.goNext) },
                    canGoPrevious: viewStore.canGoPrevious,
                    canGoNext: viewStore.canGoNext
                )

                StudyPopupView(
                    visible: Binding(
                        get: { viewStore.isPopupPresented },
                        set: { _ in } // 변경은 내부 onAction에서 처리
                    ),
                    onAction: { action in
                        viewStore.send(.hidePopup(popupAction: action))
                    }
                )
                .transition(.opacity)
                .opacity(viewStore.isPopupPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: viewStore.isPopupPresented)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct FeatureStudyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureStudyDetailView(
            store: Store(
                initialState: FeatureStudyDetailReducer.State(
                    items: [],
                    index: 0
                ),
                reducer: { FeatureStudyDetailReducer() }
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
