//
//  BoundingBoxOverlay.swift
//  Pawsitive
//
//  Created by Michael David Sin on 21/08/26.
//

import SwiftUI

struct BoundingBoxOverlay: View {
    let detections: [DetectionResult]
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            ForEach(detections) { detection in
                // Konversi koordinat Vision (0.0 - 1.0) ke koordinat layar SwiftUI
                let rect = convertBoundingBox(detection.boundingBox, screenSize: screenSize)
                let color = colorForLabel(detection.label)
                
                ZStack(alignment: .topLeading) {
                    // Kotak deteksi
                    Rectangle()
                        .path(in: rect)
                        .stroke(color, lineWidth: 3)
                    
                    // Label emosi & confidence
                    Text("\(detection.label.capitalized) (\(Int(detection.confidence * 100))%)")
                        .font(.caption)
                        .bold()
                        .padding(4)
                        .background(color)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .offset(x: rect.minX, y: max(0, rect.minY - 25))
                }
            }
        }
        .accessibilityHidden(true)
    }
    
    // Warna dinamis sesuai emosi
    private func colorForLabel(_ label: String) -> Color {
        switch label.lowercased() {
        case "angry": return .red
        case "happy": return .green
        case "alert": return .yellow
        default: return .blue
        }
    }
    
    private func convertBoundingBox(_ box: CGRect, screenSize: CGSize) -> CGRect {
        // Core ML / Vision menggunakan origin di kiri bawah (Y terbalik)
        let x = box.origin.x * screenSize.width
        let y = (1 - box.origin.y - box.size.height) * screenSize.height
        let width = box.size.width * screenSize.width
        let height = box.size.height * screenSize.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

#Preview {
    BoundingBoxOverlay(
        detections: [DetectionResult(label: "Happy", confidence: 0.99, boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6))],
        screenSize: CGSize(width: 300, height: 400)
    )
    .frame(width: 300, height: 400)
    .background(Color.gray)
}
