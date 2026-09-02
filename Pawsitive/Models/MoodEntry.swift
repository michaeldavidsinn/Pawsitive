//
//  MoodEntry.swift
//  Pawsitive
//
//  Created by Michael David Sin on 02/09/26.
//

import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var timestamp: Date
    var emotionLabel: String
    var confidence: Float
    var breed: String
    var adviceText: String
    @Attribute(.externalStorage) var imageData: Data?
    
    var pet: PetProfile?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        emotionLabel: String,
        confidence: Float,
        breed: String,
        adviceText: String,
        imageData: Data? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.emotionLabel = emotionLabel
        self.confidence = confidence
        self.breed = breed
        self.adviceText = adviceText
        self.imageData = imageData
    }
}
