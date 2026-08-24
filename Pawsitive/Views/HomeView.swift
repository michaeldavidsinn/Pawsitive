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
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Pawsitive")
                    .font(.largeTitle)
                    .bold()
                
                Text("Decode your dog's feelings instantly using AI facial analysis.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: onStart) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Analyze Dog Emotion")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(14)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}
