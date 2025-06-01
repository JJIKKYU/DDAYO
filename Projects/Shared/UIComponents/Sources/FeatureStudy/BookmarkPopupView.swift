//
//  StudyPopupView.swift
//  UIComponents
//
//  Created by 정진균 on 4/26/25.
//

import SwiftUI
import Model

public struct StudyPopupView: View {
    public let onAction: (StudyPopupAction) -> Void
    @Binding private var isVisible: Bool

    public init(
        visible: Binding<Bool>,
        onAction: @escaping (StudyPopupAction) -> Void
    ) {
        self.onAction = onAction
        self._isVisible = visible
    }

    public var body: some View {
        BasePopupView(
            isVisible: $isVisible,
            title: title,
            desc: desc,
            leadingTitle: leadingTitle,
            trailingTitle: trailingTitle,
            allDone: true,
            onLeadingAction: {
                onAction(.dismiss)
                isVisible = false
            },
            onTrailingAction: {
                onAction(.review)
            }
        )
    }
}

// MARK: - String Token

extension StudyPopupView {
    private var title: String {
        return "모든 개념을 살펴봤어요! 👏"
    }

    private var desc: String {
        return "처음부터 다시 복습해볼까요?"
    }

    private var leadingTitle: String {
        return "나가기"
    }

    private var trailingTitle: String {
        return "복습하기"
    }
}

// MARK: - Preview

#Preview {
    StudyPopupView(
        visible: .constant(true),
        onAction: { _ in }
    )
}
