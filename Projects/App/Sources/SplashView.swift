//
//  SplashView.swift
//  DDAYO
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Image(.splash)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
