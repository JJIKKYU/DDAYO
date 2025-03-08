//
//  QuizBottomBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

public struct QuizBottomBtnView: View {
    @State private var isSheetPresented = false  // ✅ Sheet 표시 여부 관리

    public init(isSheetPresented: Bool = false) {
        self.isSheetPresented = isSheetPresented
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // ✅ 메인 화면
            Color.clear.ignoresSafeArea()

            // ✅ 하단 고정 버튼
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    RoundImageButton(image: .bookmark) {
                        print("북마크 버튼 터치!")
                    }

                    Button(action: {
                        isSheetPresented.toggle()  // ✅ 버튼을 눌러 Sheet 표시
                    }) {
                        Text("정답 맞히기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 16)
                .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
                .background(.white)
                .background(.shadow(.drop(color: .black.opacity(0.06), radius: 20, x: 0, y: -2)))
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isSheetPresented) {
            AnswerSheetView(isSheetPresented: $isSheetPresented)
                .presentationDetents([.fraction(0.45), .medium, .large])
        }
    }
}

// ✅ Sheet 내부 UI
public struct AnswerSheetView: View {
    @Binding var isSheetPresented: Bool
    @State private var contentHeight: CGFloat = 0 // ✅ 콘텐츠 크기 저장

    public init(isSheetPresented: Binding<Bool>) {
        self._isSheetPresented = isSheetPresented
    }

    public var body: some View {
        VStack {
            Spacer()
                .frame(height: 24)

            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack {
                        Text("선택지 내용")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }

            Spacer()

            Button(action: {
                isSheetPresented = false  // ✅ Sheet 닫기
            }) {
                Text("정답 확인")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .background(Color.white.ignoresSafeArea())
        .presentationDetents([.height(contentHeight + 100)]) // ✅ 콘텐츠 높이에 맞춰 동적 조절
    }
}

// ✅ 미리보기
struct QuizBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        QuizBottomBtnView()
    }
}

// ✅ `AnswerSheetView`의 높이를 미리 측정하는 Extension
extension View {
    func getHeight(_ completion: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self, perform: completion)
    }
}

// ✅ `PreferenceKey`를 사용하여 높이를 전달하는 구조체
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
