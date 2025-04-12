//
//  HostingController.swift
//  Model
//
//  Created by 정진균 on 4/12/25.
//

import UIKit
import SwiftUI
//import SwiftUIIntrospect

public struct DisableInteractivePopGestureModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
//            .introspect(.navigationView(style: .stack), on: .iOS(.v18)) { navigationController in
//                print("✅ NavigationController found!")
//                navigationController.interactivePopGestureRecognizer?.isEnabled = false
//            }
    }
}

public struct EnableInteractivePopGestureModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
//            .introspect(.navigationView(style: .stack), on: .iOS(.v18)) { navigationController in
//                print("✅ NavigationController found!")
//                navigationController.interactivePopGestureRecognizer?.isEnabled = true
//            }
    }
}

public extension View {
    func disableInteractivePopGesture() -> some View {
        self.modifier(DisableInteractivePopGestureModifier())
    }

    func enableInteractivePopGesture() -> some View {
        self.modifier(EnableInteractivePopGestureModifier())
    }
}
