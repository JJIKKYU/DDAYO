//
//  Colletion+Ex.swift
//  Model
//
//  Created by 정진균 on 4/6/25.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
