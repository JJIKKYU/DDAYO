//
//  AuthNameView.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents

public struct FeatureAuthNameView: View {
    @Bindable var store: StoreOf<FeatureAuthNameReducer>
    @State private var showAgreementSheet = false

    public init(store: StoreOf<FeatureAuthNameReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                NaviBar(
                    type: .authName,
                    title: "",
                    leading1: {
                        viewStore.send(.pressedBackBtn)
                    }
                )

                Spacer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("만나서 반가워요!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)

                            Spacer()
                        }

                        HStack {
                            Text("따요와 함께 합격할 준비 되셨나요?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("이름")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.Grayscale._500)

                        TextField("이름을 입력해주세요", text: $store.name)
                            .foregroundStyle(Color.Grayscale._900)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.Grayscale._200, lineWidth: 1)
                            )

                        if let helper = store.helperText {
                            Text(helper)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.Green._500)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Button {
                    viewStore.send(.toggleAgreement)
                } label: {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(store.isValid ? Color.Green._500 : Color.gray)
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .cornerRadius(12)
                }
                .disabled(!store.isValid)
                .padding(.horizontal, 20)
            }
            .overlay {
                if store.isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        ProgressView()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(
            store: store.scope(state: \.$agreement, action: FeatureAuthNameReducer.Action.agreement)
        ) { store in
            FeatureAuthAgreementView(store: store)
                .presentationDetents([.height(360)])
        }
    }
}
