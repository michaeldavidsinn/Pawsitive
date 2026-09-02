//
//  PawsitiveApp.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import SwiftUI
import SwiftData

@main
struct PawsitiveApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PetProfile.self, MoodEntry.self])
    }
}
