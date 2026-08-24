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
                .tint(Theme.gradientStart)
            
            Text("Analyzing Emotion...")
                .font(.system(.headline, design: .rounded))
                .bold()
            
            Text("Reading facial expressions and posture cues")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Analyzing Emotion. Please wait.")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    LoadingView()
}
