import SwiftUI

struct CameraFrameView: View {
    var image: CGImage?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(image, scale: 1.0, orientation: .up, label: Text("Camera frame"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Initializing Camera...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}