//
//  UserItem.swift
//  Model
//
//  Created by 정진균 on 6/14/25.
//

import Foundation
import SwiftData

@Model
public final class UserItem {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var email: String
    public var hasAgreedToTerms: Bool
    public var createdAt: Date
    public var lastLogin: Date?

    public init(
        name: String,
        email: String,
        hasAgreedToTerms: Bool = false,
        createdAt: Date = .now,
        lastLogin: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.hasAgreedToTerms = hasAgreedToTerms
        self.createdAt = createdAt
        self.lastLogin = lastLogin
    }
}
