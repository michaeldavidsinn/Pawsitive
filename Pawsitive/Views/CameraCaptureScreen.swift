//
//  CameraCaptureScreen.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI

struct CameraCaptureScreen: View {
    @ObservedObject var cameraManager: CameraManager
    let onCapture: (CVPixelBuffer) -> Void
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            VStack {
                Text("Center your dog's face in the frame")
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.top, 50)
                
                Spacer()
                
                // Camera Controls Area
                HStack {
                    Spacer()
                    // Shutter Button
                    Button(action: {
                        if let buffer = cameraManager.currentBuffer {
                            onCapture(buffer)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 5)
                                .frame(width: 82, height: 82)
                            Circle()
                                .fill(Theme.primaryGradient)
                                .frame(width: 68, height: 68)
                                .shadow(color: Theme.gradientStart.opacity(0.5), radius: 8, x: 0, y: 4)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]), startPoint: .bottom, endPoint: .top)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}
