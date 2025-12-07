//
//  PhotoManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import UIKit
import Photos

/// Manages photo storage and retrieval for journal entries
/// Handles saving photos to disk and generating thumbnails
class PhotoManager {
    // MARK: - Singleton
    
    static let shared = PhotoManager()
    
    // MARK: - Private Properties
    
    /// Directory for storing photos
    private let photosDirectory: URL
    
    /// Maximum thumbnail size
    private let thumbnailSize = CGSize(width: 300, height: 300)
    
    // MARK: - Initialization
    
    private init() {
        // Create photos directory in Documents
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        photosDirectory = documentsPath.appendingPathComponent("photos")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Saves a photo and returns the filename
    /// - Parameter image: The UIImage to save
    /// - Returns: Filename of saved photo, or nil if save failed
    func savePhoto(_ image: UIImage) -> String? {
        // Generate unique filename
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        // Compress and save image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return filename
        } catch {
            print("Failed to save photo: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Loads a photo from filename
    /// - Parameter filename: The filename to load
    /// - Returns: UIImage if found, nil otherwise
    func loadPhoto(filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
    
    /// Loads a thumbnail version of a photo
    /// - Parameter filename: The filename to load
    /// - Returns: Resized UIImage if found, nil otherwise
    func loadThumbnail(filename: String) -> UIImage? {
        guard let fullImage = loadPhoto(filename: filename) else {
            return nil
        }
        
        return fullImage.resized(to: thumbnailSize)
    }
    
    /// Deletes a photo file
    /// - Parameter filename: The filename to delete
    func deletePhoto(filename: String) {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    /// Saves image to device's Camera Roll
    /// - Parameter image: The UIImage to save
    func saveToPhotoLibrary(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    /// Gets total storage used by photos
    /// - Returns: Size in bytes
    func getTotalPhotoSize() -> Int64 {
        guard let files = try? FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return files.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
}

// MARK: - UIImage Extension for Resizing

extension UIImage {
    /// Resizes image to fit within specified size while maintaining aspect ratio
    func resized(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

