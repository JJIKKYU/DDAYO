//
//  FeatureQuizPlayView.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents
import Model

public struct FeatureQuizPlayView: View {
    @State private var isFloatingButtonVisible = false
    public let store: StoreOf<FeatureQuizPlayReducer>

    public init(store: StoreOf<FeatureQuizPlayReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // ✅ 네비게이션 바
                    NaviBar(
                        type: .quizPlay,
                        title: "1번 문제",
                        leading1: {
                            viewStore.send(.pressedBackBtn)
                        },
                        trailing1: {
                            viewStore.send(.pressedCloseBtn)
                        }
                    )

                    // ✅ 문제 내용 및 이미지 (ScrollView)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)

                            Text("1과목 소프트웨어 설계   2022년 2회 기출문제")
                                .font(.footnote)
                                .foregroundColor(.gray)

                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 200)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                        Text("이미지 영역입니다")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        .padding(16)
                        .padding(.bottom, 100)
                    }
                }

                // ✅ ScrollView 위에 항상 떠 있는 버튼
                QuizBottomBtnView()
            }
            .background(Color(uiColor: .lightGray.withAlphaComponent(0.2)))
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    FeatureQuizPlayView(store: .init(initialState: FeatureQuizPlayReducer.State(), reducer: {
        FeatureQuizPlayReducer()
    }))
}
