//
//  BookmarkFilterBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI
import Model

public struct BookmarkFilterBtnView: View {
    public let examType: ExamType?
    public let questionType: QuestionType?
    public let onTap: () -> Void

    public init(
        examType: ExamType? = nil,
        questionType: QuestionType? = nil,
        onTap: @escaping () -> Void
    ) {
        self.examType = examType
        self.questionType = questionType
        self.onTap = onTap
    }

    private var labelText: String {
        if let examType = examType {
            return examType.displayName
        } else if let questionType = questionType {
            return questionType.displayName
        } else {
            return "-"
        }
    }

    private var foregroundColor: Color {
        if let examType {
            if examType == .all {
                return Color.Grayscale._900
            } else {
                return Color.Green._600
            }
        } else if let questionType {
            if questionType == .all {
                return Color.Grayscale._900
            } else {
                return Color.Green._600
            }
        } else {
            return Color.Grayscale._900
        }
    }

    private var borderColor: Color {
        if let examType {
            if examType == .all {
                return Color.Grayscale._200
            } else {
                return Color.Green._200
            }
        } else if let questionType {
            if questionType == .all {
                return Color.Grayscale._200
            } else {
                return Color.Green._200
            }
        } else {
            return Color.Grayscale._200
        }
    }

    private var backgroundColor: Color {
        if let examType {
            if examType == .all {
                return Color.Grayscale.white
            } else {
                return Color.Green._50
            }
        } else if let questionType {
            if questionType == .all {
                return Color.Grayscale.white
            } else {
                return Color.Green._50
            }
        } else {
            return Color.Grayscale.white
        }
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Text(labelText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(foregroundColor)

                Image(.directionDown)
                    .renderingMode(.template)
                    .foregroundStyle(foregroundColor)
                    .frame(width: 16, height: 16)
            }
            .padding(.init(top: 7, leading: 12, bottom: 7, trailing: 10))
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BookmarkFilterBtnView(examType: .written, questionType: nil, onTap: { print("모든 시험")})
}
