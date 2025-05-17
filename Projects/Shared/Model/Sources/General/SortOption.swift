//
//  SortOption.swift
//  Model
//
//  Created by 정진균 on 3/30/25.
//

import Foundation

public enum SortOption: String, Equatable, CaseIterable {
    case `default`
    case az
    case za
    case mostViewed
    case leastViewed

    public var displayName: String {
        switch self {
        case .az: return "A-Z순"
        case .za: return "Z-A순"
        case .leastViewed: return "적게 읽은 순"
        case .mostViewed: return "많이 읽은 순"
        case .default: return "기본순"
        }
    }

    public var eventName: String {
        switch self {
        case .az: return "click_study_sort_az"
        case .za: return "click_study_sort_za"
        case .leastViewed: return "click_study_sort_read-alot"
        case .mostViewed: return "click_study_sort_read-little"
        case .default: return "click_study_sort_default"
        }
    }
}
