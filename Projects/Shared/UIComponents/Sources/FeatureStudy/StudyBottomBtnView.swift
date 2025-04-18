//
//  StudyBottomBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import Model
import SwiftUI

public struct StudyBottomBtnView: View {
    @Binding var isBookmarked: Bool
    let onSelectBookmark: () -> Void
    let prevAction: () -> Void
    let nextAction: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool

    public init(
        isBookmarked: Binding<Bool>,
        onSelectBookmark: @escaping () -> Void,
        prevAction: @escaping () -> Void,
        nextAction: @escaping () -> Void,
        canGoPrevious: Bool,
        canGoNext: Bool
    ) {
        self._isBookmarked = isBookmarked
        self.onSelectBookmark = onSelectBookmark
        self.prevAction = prevAction
        self.nextAction = nextAction
        self.canGoPrevious = canGoPrevious
        self.canGoNext = canGoNext
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 12) {
                    RoundImageButton(image: isBookmarked ? .bookmarkFilled : .bookmark, isBookmarked: $isBookmarked) {
                        print("북마크 버튼 터치!")
                        onSelectBookmark()
                    }

                    Button(action: {
                        print("이전 개념 터치!")
                        prevAction()
                    }) {
                        Text("이전 개념")
                            .font(.headline)
                            .foregroundColor(canGoPrevious ? Color.Grayscale.white : Color.Grayscale._900)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canGoPrevious ? Color.Green._500 : Color.Grayscale._100)
                            .cornerRadius(12)
                    }
                    .disabled(!canGoPrevious)

                    Button(action: {
                        print("다음 개념 터치!")
                        nextAction()
                    }) {
                        Text("다음 개념")
                            .font(.headline)
                            .foregroundColor(canGoNext ? Color.Grayscale.white : Color.Grayscale._900)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canGoNext ? Color.Green._500 : Color.Grayscale._100)
                            .cornerRadius(12)
                    }
                    .disabled(!canGoNext)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 16)
                .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
                .background(Color.Grayscale.white)
                .background(.shadow(.drop(color: .black.opacity(0.06), radius: 20, x: 0, y: -2)))
            }
        }
        .ignoresSafeArea()
    }
}

struct StudyBottomBtnView_Previews: PreviewProvider {
    static var previews: some View {
        StudyBottomBtnView(
            isBookmarked: .constant(false),
            onSelectBookmark: { print("북마크!") },
            prevAction: { print("이전!") },
            nextAction: { print("다음!") },
            canGoPrevious: true,
            canGoNext: true
        )
    }
}
