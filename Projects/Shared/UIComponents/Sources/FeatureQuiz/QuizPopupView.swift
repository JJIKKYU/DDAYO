//
//  QuizPopupView.swift
//  UIComponents
//
//  Created by 정진균 on 3/15/25.
//

import SwiftUI

public struct QuizPopupView: View {
    @Binding var isPresented: Bool
    // 푼 문제
    public let solvedQuizCnt: Int
    // 전체 문제
    public let allQuizCnt: Int
    // 맞춘 문제
    public let correctQuizCnt: Int

    public init(
        isPresented: Binding<Bool>,
        solvedQuizCnt: Int,
        allQuizCnt: Int,
        correctQuizCnt: Int
    ) {
        self._isPresented = isPresented
        self.solvedQuizCnt = solvedQuizCnt
        self.allQuizCnt = allQuizCnt
        self.correctQuizCnt = correctQuizCnt
    }

    public var body: some View {
        ZStack {
            if isPresented {
                // 배경 어둡게
                Color.Grayscale.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false // 배경 클릭 시 닫힘
                    }

                // 팝업 컨텐츠
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(allQuizCnt)문제 중 \(correctQuizCnt)문제를 맞혔어요!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)

                            Spacer()
                        }
                        .padding(.bottom, 6)

                        Text("\(allQuizCnt - solvedQuizCnt)문제만 더 풀면 \(allQuizCnt)문제를 채울 수 있어요\n오늘의 공부를 마무리할까요?")
                            .lineSpacing(4.0)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.Grayscale._800)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.all, 8)

                    HStack(spacing: 12) {
                        Button(action: {
                            isPresented = false // 닫기
                        }) {
                            Text("더 공부하기")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14.5)
                                .background(Color.Grayscale._100)
                                .foregroundColor(Color.Grayscale._900)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            print("공부 종료") // 원하는 동작 실행
                            isPresented = false
                        }) {
                            Text("끝내기")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14.5)
                                .background(Color.Red._500)
                                .foregroundColor(Color.Grayscale.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                }
                .padding(.all, 20)
                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                .background(Color.Grayscale.white)
                .cornerRadius(24)
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

#Preview {
    QuizPopupView(
        isPresented: .constant(false),
        solvedQuizCnt: 20,
        allQuizCnt: 10,
        correctQuizCnt: 7
    )
}
