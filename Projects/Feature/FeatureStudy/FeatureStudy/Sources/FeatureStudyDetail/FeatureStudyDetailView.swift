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
            VStack(alignment: .leading) {
                NaviBar(type: .studyDetail, title: "개념 학습", trailing1: {
                    print("close Btn")
                    viewStore.send(.pressedCloseBtn)
                    viewStore.send(.dismiss)
                })

                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("스키마")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)

                            Spacer()
                        }

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

                        Text("데이터베이스의 논리적 구조를 사용자가 이해하고, 원하는 데이터를 검색할 수 있도록 지원하는 데이터베이스의 구성 요소이다. 사용자는 이 구조를 통해 테이블, 뷰, 인덱스 등을 접근하거나 조작할 수 있다.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.Grayscale._700)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .padding(.all, 0)

                        HStack(alignment: .center, spacing: 0) {
                            Image(uiImage: UIComponentsAsset.eye.image)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.Grayscale._300)
                                .frame(width: 16, height: 16)
                                .padding(.trailing, 2)

                            Text("99회")
                                .font(.system(size: 11))
                                .foregroundColor(Color.Grayscale._400)

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                }

                StudyBottomBtnView(
                    bookmarkAction: { print("북마크") },
                    prevAction: { print("prev") },
                    nextAction: { print("next") }
                )
            }
        }
    }
}

struct FeatureStudyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureStudyDetailView(
            store: Store(
                initialState: FeatureStudyDetailReducer.State(),
                reducer: { FeatureStudyDetailReducer() }
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
