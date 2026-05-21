//
//  CaptureView.swift
//  ScanCam
//
//  Created by NTTDATA on 06/05/26.
//
import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct CaptureView: View {

    @State private var selectedItem: PhotosPickerItem?

    @State private var showCameraPicker = false
    @State private var selectionType: UIImagePickerController.SourceType = .camera

    @StateObject var viewModel = CaptureViewModel()

    var body: some View {

        VStack(spacing: 10) {
            
            if let image = viewModel.selectedImage {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .padding()
                    .cornerRadius(10)
                
                ScrollView {
                    
                    Text(
                        viewModel.recognizedText.isEmpty
                        ? "Scanned text will appear here"
                        : viewModel.recognizedText
                    )
                    .foregroundColor(Color.black)
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 200)
                .background(Color.white)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 1.5)
                })
                .padding(15)
                
                // CLEAR BUTTON
                Button {
                    
                    viewModel.selectedImage = nil
                    viewModel.recognizedText = ""
                    
                } label: {
                    
                    Text("Clear Image")
                        .padding(10)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .background(Color.green)
                .cornerRadius(8)
                .frame(height: 60)
                .padding(.horizontal, 35)
                
                
            } else {
                
                // CAMERA BUTTON
                Button {
                    
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        
                        print("Granted: \(granted)")
                        
                        DispatchQueue.main.async {
                            
                            if granted {
                                
                                selectionType = .camera
                                showCameraPicker = true
                            }
                        }
                    }
                    
                } label: {
                    
                    captureImage
                }
                .padding(15)
                
                // PHOTOS PICKER
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    
                    photoLibrary
                }
                .padding(15)
            }
        }

        // CAMERA SHEET
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(
                sourceType: selectionType,
                selectedImage: $viewModel.selectedImage
            )
        }

        // LOAD PHOTO PICKER IMAGE
        .task(id: selectedItem) {

            guard let item = selectedItem else { return }

            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {

                viewModel.selectedImage = image
            }
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            let permission = AVCaptureDevice.authorizationStatus(for: .video)
            print(permission.rawValue)
        }
    }

    // CAMERA VIEW
    var captureImage: some View {

        VStack {

            Spacer()

            Image(systemName: "camera.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(.systemGray3))
                .frame(width: 60, height: 60)

            Text("Capture Image")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color(.systemGray))

            Spacer()

        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(.red)
        )
    }

    // PHOTO LIBRARY VIEW
    var photoLibrary: some View {

        VStack {

            Spacer()

            Image(systemName: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(.systemGray3))
                .frame(width: 60, height: 60)

            Text("Photo Library")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color(.systemGray))

            Spacer()

        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(.red)
        )
    }
}

#Preview {
    CaptureView()
}
