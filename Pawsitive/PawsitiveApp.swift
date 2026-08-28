//
//  PawsitiveApp.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import SwiftUI

@main
struct PawsitiveApp: App {

    let slmEngine = SLMAdviceGenerator.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {

                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    
                    let testOutput = await slmEngine.testGenerate(prompt: "Hello Dog")
                    print("Hasil Test Output: \(testOutput)")
                }
        }
    }
}
