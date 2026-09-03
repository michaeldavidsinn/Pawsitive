//
//  CameraCaptureScreen.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI
import PhotosUI

struct CameraCaptureScreen: View {
    @ObservedObject var cameraManager: CameraManager
    let onCapture: (CVPixelBuffer) -> Void
    var onPhotoSelected: ((UIImage) -> Void)? = nil
    var onClose: (() -> Void)? = nil
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Top Navigation Bar (Back / Close Button)
                HStack {
                    if let onClose = onClose {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .frame(width: 44, height: 44)
                        .accessibilityLabel("Back")
                        .accessibilityHint("Returns to the home screen.")
                        .accessibilityAddTraits(.isButton)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Centered Instruction Pill
                Text("Center your dog's face in the frame")
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                Spacer()
                
                // Camera Controls Area
                HStack(spacing: 40) {
                    // Upload Photo Button
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Upload Photo")
                    .accessibilityHint("Choose a photo of your dog from your library.")
                    
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
                    .accessibilityLabel("Take Photo")
                    .accessibilityHint("Captures an image of your dog for analysis.")
                    .accessibilityAddTraits(.isButton)
                    
                    // Switch Camera Button
                    Button(action: {
                        cameraManager.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Switch Camera")
                    .accessibilityHint("Toggles between the front and back camera.")
                    .accessibilityAddTraits(.isButton)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top)
                )
            }
            .padding(.top)
            .padding(.bottom)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    onPhotoSelected?(uiImage)
                }
            }
        }
    }
}

#Preview {
    CameraCaptureScreen(cameraManager: CameraManager(), onCapture: { _ in })
}
