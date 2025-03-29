//
//  SortBottomSheetView.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI

public struct SortBottomSheetView: View {
    public let sortOptions: [String] = [
        "A-Z순",
        "Z-A순",
        "적게 읽은 순",
        "많이 읽은 순"
    ]

    @Binding public var selectedOption: String?
    @Binding public var isSheetPresented: Bool

    public init(selectedOption: Binding<String?>, isSheetPresented: Binding<Bool>) {
            self._selectedOption = selectedOption
            self._isSheetPresented = isSheetPresented
        }

    public var body: some View {
        VStack {
            HStack {
                Text("정렬")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.Grayscale._900)
                    .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                Spacer()
            }
            .frame(height: 27)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 20)

            ForEach(sortOptions, id: \.self) { option in
                SortBottomSheetButton(
                    buttonTitle: option,
                    action: {
                        selectedOption = option
                        print("action!")
                    },
                    isPressed: Binding(
                        get: { selectedOption == option },
                        set: { if $0 { selectedOption = option } }
                    )
                )
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
            }

            Spacer()

            Button(action: {
                print("닫기 버튼 클릭됨") // 실제 앱에서는 dismiss 로직 추가 가능
                isSheetPresented = false
            }, label: {
                Text("닫기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.Grayscale._900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16.5)
                    .background(Color.Grayscale._100)
                    .cornerRadius(12)
            })
            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.horizontal, 20)
        }
    }
}
