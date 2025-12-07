//
//  ImagePickerView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper for UIImagePickerController
/// Provides camera and photo library access
struct ImagePickerView: UIViewControllerRepresentable {
    // MARK: - Properties
    
    /// Source type (camera or photo library)
    let sourceType: UIImagePickerController.SourceType
    
    /// Callback when image is selected
    let onImagePicked: (UIImage) -> Void
    
    /// Callback when picker is dismissed
    let onDismiss: () -> Void
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        
        // Allow editing for cropping
        picker.allowsEditing = false
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Get the selected image
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            
            parent.onDismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onDismiss()
        }
    }
}

/// Checks if camera is available on device
func isCameraAvailable() -> Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
}

