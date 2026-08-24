//
//  HomeView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI

struct HomeView: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Theme.gradientStart.opacity(0.3), radius: 16, x: 0, y: 8)
                .accessibilityHidden(true) // Decorative
            
            VStack(spacing: 12) {
                Text("Pawsitive")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                Text("Decode your dog's feelings instantly using AI facial analysis.")
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            .accessibilityElement(children: .combine)
            
            Spacer()
            
            // Call to action button
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                    Text("Analyze Dog Emotion")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.primaryGradient)
                .clipShape(Capsule())
                .shadow(color: Theme.gradientStart.opacity(0.4), radius: 10, x: 0, y: 6)
            }
            .accessibilityLabel("Analyze Dog Emotion")
            .accessibilityHint("Opens the camera to detect your dog's feelings.")
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    HomeView(onStart: {})
}
