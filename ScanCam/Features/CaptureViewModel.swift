
//
//  HomeViewModel.swift
//  ScanCam
//
//  Created by NTTDATA on 06/05/26.
//

import SwiftUI
import Vision
import Combine

// @MainActor ensures all UI updates (@Published) happen safely on the main thread
@MainActor
class CaptureViewModel: ObservableObject {
    
    @Published var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                // Call the async function using a Task context
                Task {
                    self.recognizedText = await recognizeText(from: image)
                }
            }
        }
    }
    
    @Published var recognizedText: String = ""
    
    // Marked as async so it can wait for the background Vision thread to complete
    func recognizeText(from image: UIImage) async -> String {
       
        guard let cgImage = image.cgImage else { return "" }
        
        // withCheckedContinuation bridges old closure-based APIs to modern async/await
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    continuation.resume(returning: "")
                    return
                }
                
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations.compactMap {
                    $0.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                // Return the final text string back to the async function caller
                continuation.resume(returning: text)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            request.minimumTextHeight = 0.02
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("OCR failed: \(error)")
                continuation.resume(returning: "")
            }
        }
    }
}
