//
//  FeatureProfileMainView.swift
//  FeatureProfile
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents

public struct FeatureProfileMainView: View {
    @Environment(\.openURL) private var openURL

    let store: StoreOf<FeatureProfileMainReducer>

    public init(store: StoreOf<FeatureProfileMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // 타이틀
                NaviBar(type: .profile, title: "프로필", leading1: {
                    viewStore.send(.pressedBackBtn)
                })

                ScrollView {

                    // 유저 정보 및 로그아웃 버튼
                    VStack(spacing: 0) {
                        Text(viewStore.userName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.Grayscale._900)
                            .padding(.bottom, 6)

                        Text(viewStore.userEmail)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.Grayscale._600)
                            .padding(.bottom, 12)

                        Button("로그아웃") {
                            viewStore.send(.logoutTapped)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.Grayscale._100)
                        .cornerRadius(4)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.Grayscale._900)
                        .padding(.bottom, 16)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 30)

                    // 약관 및 버전 정보
                    VStack(spacing: 30) {
                        Button {
                            if let url = URL(string: "https://kakao.com") {
                                openURL(url)
                            }
                            viewStore.send(.termsTapped)
                        } label: {
                            HStack {
                                Text("서비스 이용약관")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.Grayscale._800)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.Grayscale._800)
                            }
                            .contentShape(Rectangle())
                        }

                        Button {
                            if let url = URL(string: "https://naver.com") {
                                openURL(url)
                            }
                            viewStore.send(.privacyTapped)
                        } label: {
                            HStack {
                                Text("개인정보 처리방침")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.Grayscale._800)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.Grayscale._800)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        HStack {
                            Text("앱 버전")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.Grayscale._800)

                            Spacer()
                            Text("v\(viewStore.appVersion)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.Grayscale._600)

                            /*
                             if viewStore.isUpdateNeeded {
                             Text("업데이트 필요")
                             .foregroundColor(.red)
                             .font(.footnote)
                             .padding(.horizontal, 8)
                             .padding(.vertical, 4)
                             .background(Color.red.opacity(0.1))
                             .cornerRadius(4)
                             }
                             */
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    FeatureProfileMainView(
        store: Store(
            initialState: FeatureProfileMainReducer.State(),
            reducer: {
                FeatureProfileMainReducer()
            }
        )
    )
}
