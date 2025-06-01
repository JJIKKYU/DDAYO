//
//  FeatureProfileMainView.swift
//  FeatureProfile
//
//  Created by 정진균 on 5/4/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents

public struct FeatureProfileMainView: View {
    @Environment(\.openURL) private var openURL
    @Dependency(\.appConfig) private var appConfig

    let store: StoreOf<FeatureProfileMainReducer>

    public init(store: StoreOf<FeatureProfileMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottom) {
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

                            ZStack {
                                Button("로그아웃") {
                                    viewStore.send(.showLogoutPopup)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.Grayscale._100)
                                .cornerRadius(4)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.Grayscale._900)
                                .opacity(viewStore.isLoggingOut ? 0.3 : 1)

                                if viewStore.isLoggingOut {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 30)

                        // 약관 및 버전 정보
                        VStack(spacing: 30) {
                            Button {
                                if let url = appConfig.termsOfService {
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
                                if let url = appConfig.privacyPolicy {
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

                            Button {
                                if let url = appConfig.attribution {
                                    openURL(url)
                                }
                                viewStore.send(.attributionTapped)
                            } label: {
                                HStack {
                                    Text("문제 출처 고지")
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

                            Button {
                                viewStore.send(.showDeletePopup)
                            } label: {
                                HStack {
                                    Text("회원 탈퇴")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Color.Red._600)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .renderingMode(.template)
                                        .foregroundStyle(Color.Red._600)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .onAppear { viewStore.send(.onAppear) }

                if let popup = viewStore.popupState {
                    BasePopupView(
                        isVisible: Binding(
                            get: {
                                print("Get :: \(viewStore.isPopupPresented)")
                                return viewStore.isPopupPresented
                            },
                            set: { _ in }
                        ),
                        title: popup.title,
                        desc: popup.desc,
                        leadingTitle: popup.leadingTitle,
                        trailingTitle: popup.trailingTitle,
                        allDone: popup.allDone,
                        onLeadingAction: {
                            viewStore.send(.hidePopup)
                        },
                        onTrailingAction: {
                            viewStore.send(.confirmPopup)
                        }
                    )
                }
            }
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
