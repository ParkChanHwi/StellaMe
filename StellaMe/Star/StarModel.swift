//
//  StarModel.swift
//  StellaMe
//
//  Created by JaeyoungLee on 4/25/25.
//

import Foundation
import SwiftData

// MARK: - 텍스트 선언
@Model
class StarModel {
    @Attribute(.unique) var id: UUID
    var starText: String
    var date: Date

    // N:1 관계
    @Relationship var galaxy: GalaxyModel?

    init(id: UUID = UUID(), starText: String, date: Date, galaxy: GalaxyModel? = nil) {
        self.id = id
        self.starText = starText
        self.date = date
        self.galaxy = galaxy
    }
}
