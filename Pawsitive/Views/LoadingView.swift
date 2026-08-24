//
//  LoadingView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Analyzing Emotion...")
                .font(.headline)
                .bold()
            
            Text("Reading facial expressions and posture cues")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
