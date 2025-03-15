//
//  ColorSystem.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

extension Color {
    public struct Grayscale {
        public static let _50 = Color(hex: "#f4f5f8")
        public static let _100 = Color(hex: "#e8eaf0")
        public static let _200 = Color(hex: "#d9dce2")
        public static let _300 = Color(hex: "#c5cad4")
        public static let _400 = Color(hex: "#a7adbc")
        public static let _500 = Color(hex: "#8b92a2")
        public static let _600 = Color(hex: "#707585")
        public static let _700 = Color(hex: "#5a6071")
        public static let _800 = Color(hex: "#373c48")
        public static let _900 = Color(hex: "#1c2029")
        public static let black = Color(hex: "#0f0f14")
        public static let white = Color(hex: "#ffffff")
    }

    public struct Green {
        public static let _50 = Color(hex: "#ebf9f4")
        public static let _100 = Color(hex: "#c0ecdd")
        public static let _200 = Color(hex: "#a2e2cc")
        public static let _300 = Color(hex: "#77d5b5")
        public static let _400 = Color(hex: "#5dcda6")
        public static let _500 = Color(hex: "#33bd8c")
        public static let _600 = Color(hex: "#2eab7f")
        public static let _700 = Color(hex: "#258966")
        public static let _800 = Color(hex: "#1d6a4f")
        public static let _900 = Color(hex: "#16513c")
    }

    public struct Blue {
        public static let _50 = Color(hex: "#ecf2ff")
        public static let _100 = Color(hex: "#c5d8ff")
        public static let _200 = Color(hex: "#a9c5ff")
        public static let _300 = Color(hex: "#82aaff")
        public static let _400 = Color(hex: "#6a99ff")
        public static let _500 = Color(hex: "#4580ff")
        public static let _600 = Color(hex: "#3f74e8")
        public static let _700 = Color(hex: "#315bb5")
        public static let _800 = Color(hex: "#26468c")
        public static let _900 = Color(hex: "#1d366b")
    }

    public struct Red {
        public static let _50 = Color(hex: "#ffeeee")
        public static let _100 = Color(hex: "#fdc9c9")
        public static let _200 = Color(hex: "#fdafaf")
        public static let _300 = Color(hex: "#fc8a8a")
        public static let _400 = Color(hex: "#fb7373")
        public static let _500 = Color(hex: "#fa5050")
        public static let _600 = Color(hex: "#e44949")
        public static let _700 = Color(hex: "#b23939")
        public static let _800 = Color(hex: "#8a2c2c")
        public static let _900 = Color(hex: "#692222")
    }

    public struct Background {
        public static let _1 = Color(hex: "#FFFFFF")
        public static let _2 = Color(hex: "#F9F9F9")
    }

    public init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scanner = Scanner(string: hexSanitized)
        if hexSanitized.hasPrefix("#") {
            scanner.currentIndex = hexSanitized.index(after: hexSanitized.startIndex)
        }
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
