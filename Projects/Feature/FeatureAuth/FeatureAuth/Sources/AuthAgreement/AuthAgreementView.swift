//
//  AuthAgreementView.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import DI

public struct FeatureAuthAgreementView: View {
    @Bindable var store: StoreOf<FeatureAuthAgreementReducer>

    @Environment(\.openURL) private var openURL
    @Dependency(\.appConfig) private var appConfig

    public init(store: StoreOf<FeatureAuthAgreementReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("따요를 사용하시려면\n동의가 필요해요")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.Grayscale._900)
                .lineSpacing(5.5)
                .padding(.bottom, 25)
                .padding(.horizontal, 20)
                .padding(.top, 25)

            VStack(alignment: .leading, spacing: 30) {
                agreementRow(title: "필수 항목 전체 동의", isChecked: store.agreeAll, isAgreeAll: true) {
                    store.send(.toggleAgreeAll)
                }

                agreementRow(title: "[필수] 만 14세 이상입니다.", isChecked: store.agreeAge) {
                    store.send(.toggleAgreeAge)
                }

                agreementRow(title: "[필수] 서비스 이용약관", isChecked: store.agreeTerms, showArrow: true) {
                    store.send(.toggleAgreeTerms)
                } onArrowTap: {
                    if let url = appConfig.termsOfService {
                        openURL(url)
                    }
                    store.send(.pressedDetailTerms)
                }

                agreementRow(title: "[필수] 개인정보 수집 및 이용", isChecked: store.agreePrivacy, showArrow: true) {
                    store.send(.toggleAgreePrivacy)
                } onArrowTap: {
                    if let url = appConfig.privacyConsent {
                        openURL(url)
                    }
                    store.send(.pressedDetailPrivacy)
                }
            }

            Spacer()

            Button {
                store.send(.didTapStart)
            } label: {
                Text("시작하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.system(size: 16, weight: .semibold))
                    .background(store.canStart ? Color.Green._500 : Color.Grayscale._50)
                    .foregroundStyle(store.canStart ? Color.Grayscale.white : Color.Grayscale._300)
                    .cornerRadius(12)
            }
            .disabled(!store.canStart)
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func agreementRow(
        title: String,
        isChecked: Bool,
        isAgreeAll: Bool = false,
        showArrow: Bool = false,
        onTap: @escaping () -> Void,
        onArrowTap: (() -> Void)? = nil
    ) -> some View {
        HStack {
            Image(asset: UIComponentsAsset.check)
                .renderingMode(.template)
                .foregroundColor(isChecked ? Color.Green._500 : Color.Grayscale._200)
                .frame(width: 20, height: 20)

            Text(title)
                .foregroundColor(Color.Grayscale._800)
                .font(.system(size: 15, weight: isAgreeAll ? .bold : .medium))

            Spacer()

            if showArrow {
                Button(action: {
                    onArrowTap?()
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.Grayscale._400)
                }
            }
        }
        .onTapGesture {
            onTap()
        }
        .padding(.horizontal, 20)
    }
}
