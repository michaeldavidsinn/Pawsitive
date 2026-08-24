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
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.top, 50)
                
                Spacer()
                
                // Shutter Button
                Button(action: {
                    if let buffer = cameraManager.currentBuffer {
                        onCapture(buffer)
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 78, height: 78)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 66, height: 66)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}
