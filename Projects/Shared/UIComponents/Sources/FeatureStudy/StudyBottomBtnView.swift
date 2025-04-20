//
//  StudyBottomBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import Model
import SwiftUI

public enum StudyButtonType {
    case previous
    case next
}

public struct StudyBottomBtnView: View {
    @Binding var isBookmarked: Bool
    let onSelectBookmark: () -> Void
    let prevAction: () -> Void
    let nextAction: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool
    let prevButtonType: StudyButtonType
    let nextButtonType: StudyButtonType

    private func textColor(for type: StudyButtonType) -> Color {
        switch type {
        case .previous: return canGoPrevious ? Color.Grayscale._900 : Color.Grayscale._300
        // case .next: return canGoNext ? Color.Grayscale.white : Color.Grayscale._900
        case .next: return Color.Grayscale.white
        }
    }

    private func backgroundColor(for type: StudyButtonType) -> Color {
        switch type {
        case .previous: return canGoPrevious ? Color.Grayscale._100 : Color.Grayscale._50
        // case .next: return canGoNext ? Color.Green._500 : Color.Grayscale._100
        case .next: return Color.Green._500
        }
    }

    public init(
        isBookmarked: Binding<Bool>,
        onSelectBookmark: @escaping () -> Void,
        prevAction: @escaping () -> Void,
        nextAction: @escaping () -> Void,
        canGoPrevious: Bool,
        canGoNext: Bool,
        prevButtonType: StudyButtonType = .previous,
        nextButtonType: StudyButtonType = .next
    ) {
        self._isBookmarked = isBookmarked
        self.onSelectBookmark = onSelectBookmark
        self.prevAction = prevAction
        self.nextAction = nextAction
        self.canGoPrevious = canGoPrevious
        self.canGoNext = canGoNext
        self.prevButtonType = prevButtonType
        self.nextButtonType = nextButtonType
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
                            .foregroundColor(textColor(for: .previous))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(backgroundColor(for: .previous))
                            .cornerRadius(12)
                    }
                    .disabled(!canGoPrevious)

                    Button(action: {
                        print("다음 개념 터치!")
                        nextAction()
                    }) {
                        Text("다음 개념")
                            .font(.headline)
                            .foregroundColor(textColor(for: .next))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(backgroundColor(for: .next))
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
            isBookmarked: .constant(false),
            onSelectBookmark: { print("북마크!") },
            prevAction: { print("이전!") },
            nextAction: { print("다음!") },
            canGoPrevious: true,
            canGoNext: true
        )
    }
}
