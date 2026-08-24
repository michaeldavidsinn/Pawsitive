//
//  ResultView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI
import UIKit

struct ResultView: View {
    let image: UIImage
    let detections: [DetectionResult]
    let onRetake: () -> Void
    let onGoHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detection Result")
                .font(.title2)
                .bold()
                .padding(.top, 20)
            
            // Image Canvas + Bounding Box Overlay
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(16)
                    
                    BoundingBoxOverlay(detections: detections, screenSize: geometry.size)
                }
            }
            .padding(.horizontal, 20)
            
            // Dynamic Emotion & Interaction Advice Card
            VStack(alignment: .leading, spacing: 12) {
                if let topDetection = detections.first {
                    HStack {
                        Text("Detected Emotion:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(topDetection.label.capitalized)
                            .font(.headline)
                            .bold()
                    }
                    
                    HStack {
                        Text("Confidence Score:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(topDetection.confidence * 100))%")
                            .font(.subheadline)
                            .bold()
                    }
                    
                    Divider()
                    
                    // Recommended Action Message
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended Action:")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        
                        Text(recommendationMessage(for: topDetection.label))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                } else {
                    Text("No dog detected. Please try capturing closer with better lighting.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onRetake) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Retake")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
                }
                
                Button(action: onGoHome) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            if let topLabel = detections.first?.label {
                triggerHaptic(for: topLabel)
            }
        }
    }
    
    private func triggerHaptic(for label: String) {
        let notificationGenerator = UINotificationFeedbackGenerator()
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        switch label.lowercased() {
        case "happy":
            notificationGenerator.notificationOccurred(.success)
        case "angry":
            notificationGenerator.notificationOccurred(.warning)
        case "alert":
            impactGenerator.impactOccurred()
        default:
            break
        }
    }
    
    private func recommendationMessage(for label: String) -> String {
        switch label.lowercased() {
        case "happy":
            return "Your dog feels safe and relaxed. Great time for playing or giving treats!"
        case "angry":
            return "Give your dog some space. Avoid sudden movements or direct eye contact."
        case "alert":
            return "Your dog is observing surroundings closely. Check what caught their attention."
        default:
            return "Observe your dog's overall body language for context."
        }
    }
}
