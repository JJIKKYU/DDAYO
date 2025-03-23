//
//  AnswerBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

// MARK: - isConfirmAnswerType

public enum AnswerBtnViewType {
    case `default`                  // 정답여부가 아닌 리스트로 버튼 노출할 때
    case correct                    // 정답일 때 초록색
    case incorrectCorrectAnswer     // 오답이지만 정답 내용은 파란색
    case incorrectWrongAnswer       // 오답이며 오답 내용은 빨간색
}

// MARK: - AnswerBtnView

public struct AnswerBtnView: View {
    public let title: String
    @Binding public var isChecked: Bool

    // 정답 확인에서 노출하는 경우
    public let btnType: AnswerBtnViewType

    public init(
        title: String,
        isChecked: Binding<Bool>,
        btnType: AnswerBtnViewType = .default
    ) {
        self.title = title
        self._isChecked = isChecked
        self.btnType = btnType
    }

    private var textColor: Color {
        switch btnType {
        case .default:
            return isChecked ? Color.Green._600 : Color.Grayscale._800

        case .correct:
            return Color.Green._600

        case .incorrectCorrectAnswer:
            return Color.Blue._600

        case .incorrectWrongAnswer:
            return Color.Red._600
        }
    }

    private var backgroundColor: Color {
        switch btnType {
        case .default:
            return isChecked ? Color.Green._50 : Color.Grayscale._50

        case .correct:
            return Color.Green._50

        case .incorrectCorrectAnswer:
            return Color.Blue._50

        case .incorrectWrongAnswer:
            return Color.Red._50
        }
    }

    private var iconColor: Color {
        switch btnType {
        case .default:
            return isChecked ? Color.Green._500 : Color.Grayscale._200
        case .correct:
            return Color.Green._600

        case .incorrectCorrectAnswer:
            return Color.Blue._600

        case .incorrectWrongAnswer:
            return Color.Red._600
        }
    }


    public var body: some View {
        Button {
            if btnType == .default {
                isChecked.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(textColor)
                    .padding(.vertical, 15)

                Spacer()

                switch btnType {
                case .default:
                    Image(ImageResource.checkCircleFilled)
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                        .frame(width: 24, height: 24)

                case .correct, .incorrectCorrectAnswer:
                    Image(ImageResource.circle)
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                        .frame(width: 24, height: 24)

                case .incorrectWrongAnswer:
                    Image(ImageResource.close)
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                        .frame(width: 24, height: 24)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .disabled(btnType != .default)
    }
}

#Preview {
    @Previewable @State var isChecked: Bool = false

    AnswerBtnView(
        title: "선택지 내용",
        isChecked: $isChecked,
        btnType: .correct
    )
    .padding(.horizontal, 20)
}
