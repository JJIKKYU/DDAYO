//
//  SortBottomSheetButton.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI

import SwiftUI

public struct SortBottomSheetButton: View {
    public let buttonTitle: String
    public let action: (() -> Void)
    @Binding public var isPressed: Bool

    public init(
        buttonTitle: String,
        action: @escaping (() -> Void),
        isPressed: Binding<Bool>
    ) {
        self.buttonTitle = buttonTitle
        self.action = action
        self._isPressed = isPressed
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if isPressed {
                    Image(.check)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.Green._500)
                        .frame(width: 20, height: 20)
                }

                Text(buttonTitle)
                    .font(.system(size: 16, weight: isPressed ? .semibold : .regular))
                    .foregroundColor(isPressed ? Color.Grayscale._900 : Color.Grayscale._800)

                Spacer()
            }
        }
    }
}

#Preview {
    // ✅ Preview에서 @State를 활용하여 Binding 전달
    @Previewable @State var isPressed = true

    SortBottomSheetButton(
        buttonTitle: "안녕하세요",
        action: {
            print("action!")
        },
        isPressed: .constant(false))
}
