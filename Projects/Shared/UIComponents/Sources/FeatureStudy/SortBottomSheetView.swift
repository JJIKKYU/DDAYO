//
//  SortBottomSheetView.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI
import Model

public struct SortBottomSheetView: View {
    public let selectedOption: SortOption?
    public let onSelect: (SortOption) -> Void
    public let onClose: () -> Void

    public init(
        selectedOption: SortOption?,
        onSelect: @escaping (SortOption) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.selectedOption = selectedOption
        self.onSelect = onSelect
        self.onClose = onClose
    }

    public var body: some View {
        VStack {
            HStack {
                Text("정렬")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.Grayscale._900)
                Spacer()
            }
            .frame(height: 27)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 20)

            ForEach(SortOption.allCases, id: \.self) { option in
                SortBottomSheetButton(
                    buttonTitle: option.displayName,
                    action: { onSelect(option) },
                    isPressed: .constant(selectedOption == option)
                )
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }

            Spacer()

            Button(action: onClose) {
                Text("닫기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.Grayscale._900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16.5)
                    .background(Color.Grayscale._100)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
    }
}
