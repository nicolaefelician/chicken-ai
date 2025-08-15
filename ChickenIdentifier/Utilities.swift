import Foundation
import UIKit

class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}

class Consts {
    static let shared = Consts()
    
    private init() {}
    
    let openAiApiKey = ""
}
