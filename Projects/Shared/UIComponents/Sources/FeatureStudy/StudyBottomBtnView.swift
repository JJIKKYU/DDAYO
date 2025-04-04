//
//  StudyBottomBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import Model
import SwiftUI

public struct StudyBottomBtnView: View {
    let bookmarkAction: () -> Void
    let prevAction: () -> Void
    let nextAction: () -> Void

    public init(
        bookmarkAction: @escaping () -> Void,
        prevAction: @escaping () -> Void,
        nextAction: @escaping () -> Void
    ) {
        self.bookmarkAction = bookmarkAction
        self.prevAction = prevAction
        self.nextAction = nextAction
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 12) {
                    RoundImageButton(image: .bookmark, isBookmarked: .constant(false)) {
                        print("북마크 버튼 터치!")
                        bookmarkAction()
                    }

                    Button(action: {
                        print("이전 개념 터치!")
                        prevAction()
                    }) {
                        Text("이전 개념")
                            .font(.headline)
                            .foregroundColor(Color.Grayscale._900)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.Grayscale._100)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        print("다음 개념 터치!")
                        nextAction()
                    }) {
                        Text("다음 개념")
                            .font(.headline)
                            .foregroundColor(Color.Grayscale.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.Green._500)
                            .cornerRadius(12)
                    }
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
            bookmarkAction: { print("북마크!") },
            prevAction: { print("이전!") },
            nextAction: { print("다음!") }
        )
    }
}
