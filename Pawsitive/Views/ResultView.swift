//
//  ResultView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI
import SwiftData 
import UIKit

struct ResultView: View {
    let image: UIImage
    let detections: [DetectionResult]
    let onRetake: () -> Void
    let onGoHome: () -> Void
    
    @State private var adviceText: String = "Generating AI Advice..."
    @State private var detectedBreed: String = "Detecting..."
    @State private var isLoading: Bool = true
    
    private let adviceGenerator = LocalLLMService.shared
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Detection Result")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .padding(.top, 24)
                    
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            
                            BoundingBoxOverlay(detections: detections, screenSize: geometry.size)
                        }
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Captured image of your dog.")
                    }
                    .aspectRatio(image.size.width > 0 && image.size.height > 0 ? image.size.width / image.size.height : 1.0, contentMode: .fit)
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 16) {
                        if let topDetection = detections.first {

                            VStack(alignment: .leading, spacing: 12) {
                                
                                HStack {
                                    Image(systemName: "pawprint.fill")
                                        .font(.system(size: 12))
                                    Text(detectedBreed)
                                        .font(.system(.caption, design: .rounded))
                                        .bold()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Theme.gradientStart.opacity(0.15))
                                .foregroundColor(Theme.gradientStart)
                                .clipShape(Capsule())
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Detected Emotion")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.secondary)
                                        
                                        Text(topDetection.label.capitalized)
                                            .font(.system(.title3, design: .rounded))
                                            .bold()
                                            .foregroundColor(color(for: topDetection.label))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Confidence")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.secondary)
                                        Text("\(Int(topDetection.confidence * 100))%")
                                            .font(.system(.title3, design: .rounded))
                                            .bold()
                                    }
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Detected Breed: \(detectedBreed), Emotion: \(topDetection.label), Confidence: \(Int(topDetection.confidence * 100)) percent")
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("AI Pet Care Advice")
                                    .font(.system(.caption, design: .rounded))
                                    .bold()
                                    .foregroundColor(.secondary)
                                
                                if isLoading {
                                    ProgressView("Analyzing breed & condition...")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                } else {
                                    Text(adviceText)
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .accessibilityElement(children: .combine)
                        } else {
                            HStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("No Dog Detected")
                                        .font(.system(.headline, design: .rounded))
                                        .bold()
                                    
                                    Text("Please make sure your dog's face is clearly visible with good lighting.")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .padding(20)
                    .background(Theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            
            .task {
                guard let topDetection = detections.first else {
                    await MainActor.run {
                        self.adviceText = "No dog detected to analyze."
                        self.isLoading = false
                    }
                    return
                }
                
                let breed = await VisionBreedDetector.detectBreed(from: image)
                let result = await adviceGenerator.generateAdvice(
                    for: topDetection.label,
                    confidence: topDetection.confidence,
                    breed: breed
                )
                
                await MainActor.run {
                    self.detectedBreed = breed
                    self.adviceText = result.text
                    self.isLoading = false
                    
                    // Simpan otomatis ke SwiftData
                    self.saveScanHistory(breed: breed, topDetection: topDetection, advice: result.text)
                }
            }

            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: onRetake) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Retake")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.gradientStart)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.gradientStart.opacity(0.15))
                    .clipShape(Capsule())
                }
                .accessibilityLabel("Retake Photo")
                .accessibilityAddTraits(.isButton)
                
                Button(action: onGoHome) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.primaryGradient)
                    .clipShape(Capsule())
                    .shadow(color: Theme.gradientStart.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("Go to Home")
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            if let topLabel = detections.first?.label {
                triggerHaptic(for: topLabel)
            }
        }
    }
    
    private func color(for label: String) -> Color {
        switch label.lowercased() {
        case "happy":
            return .green
        case "angry":
            return .red
        case "alert", "sad":
            return .orange
        default:
            return Theme.gradientStart
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
    
    private func saveScanHistory(breed: String, topDetection: DetectionResult, advice: String) {
        let imageData = image.jpegData(compressionQuality: 0.7)
        
        let newEntry = MoodEntry(
            emotionLabel: topDetection.label,
            confidence: topDetection.confidence,
            breed: breed,
            adviceText: advice,
            imageData: imageData
        )
        
        modelContext.insert(newEntry)
        try? modelContext.save()
    }
}

#Preview {
    ResultView(
        image: UIImage(systemName: "photo")!,
        detections: [DetectionResult(label: "Happy", confidence: 0.95, boundingBox: .zero)],
        onRetake: {},
        onGoHome: {}
    )
}
