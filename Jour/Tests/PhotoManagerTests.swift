
import Foundation
import UIKit

// Mock testing script
func testPhotoManager() {
    print("📸 Starting PhotoManager Test...")
    
    // 1. Create a dummy image
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
    let image = renderer.image { ctx in
        UIColor.red.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    // 2. Test Saving
    PhotoManager.shared.savePhoto(image) { filename in
        guard let filename = filename else {
            print("❌ Initial Save Failed")
            return
        }
        print("✅ Save Success: \(filename)")
        
        // 3. Test Loading
        if let loadedImage = PhotoManager.shared.loadPhoto(filename: filename) {
            print("✅ Load Success. Size: \(loadedImage.size)")
        } else {
            print("❌ Load Failed")
        }
        
        // 4. Test Thumbnail
        if let thumbnail = PhotoManager.shared.loadThumbnail(filename: filename) {
            print("✅ Thumbnail Success. Size: \(thumbnail.size)")
        } else {
            print("❌ Thumbnail Failed")
        }
        
        // 5. Test Deletion
        PhotoManager.shared.deletePhoto(filename: filename)
        if PhotoManager.shared.loadPhoto(filename: filename) == nil {
            print("✅ Delete Success")
        } else {
            print("❌ Delete Failed (File still exists)")
        }
    }
}
