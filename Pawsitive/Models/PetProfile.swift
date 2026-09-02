//
//  PetProfile.swift
//  Pawsitive
//
//  Created by Michael David Sin on 02/09/26.
//

import Foundation
import SwiftData

@Model
final class PetProfile {
    var id: UUID
    var name: String
    var breed: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \MoodEntry.pet)
    var moodEntries: [MoodEntry] = []
    
    init(id: UUID = UUID(), name: String, breed: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.breed = breed
        self.createdAt = createdAt
    }
}
