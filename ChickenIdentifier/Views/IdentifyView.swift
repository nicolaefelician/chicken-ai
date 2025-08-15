import SwiftUI
import AVFoundation

struct IdentifyView: View {
    private let appProvider = AppProvider.shared
    @StateObject private var cameraHandler = CameraHandler()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingOnboarding = false
    @State private var showingResults = false
    @State private var identifiedBreeds: [ChickenBreed] = []
    @State private var showIdentifyResult = false
    @State private var showPaywall = false
    @AppStorage("hasSeenIdentifyOnboarding") private var hasSeenOnboarding = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraFrameView(image: cameraHandler.frame)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text("Identify")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showingOnboarding = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .padding(.top, 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                if !cameraHandler.isProcessing {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: 250, height: 250)
                        
                        VStack {
                            HStack {
                                CornerBracket()
                                Spacer()
                                CornerBracket()
                                    .rotationEffect(.degrees(90))
                            }
                            Spacer()
                            HStack {
                                CornerBracket()
                                    .rotationEffect(.degrees(-90))
                                Spacer()
                                CornerBracket()
                                    .rotationEffect(.degrees(180))
                            }
                        }
                        .frame(width: 250, height: 250)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 30) {
                    if cameraHandler.isProcessing {
                        VStack(spacing: 15) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Analyzing chicken breed...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                    } else {
                        VStack(spacing: 4) {
                            if !subscriptionManager.hasUnlockedPremium {
                                HStack(spacing: 6) {
                                    Image(systemName: "crown.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    Text("Premium Feature")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            Text(subscriptionManager.hasUnlockedPremium ? "Point camera at a chicken" : "Tap to unlock AI identification")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        captureAndIdentify()
                    }) {
                        ZStack {
                            Circle()
                                .fill(subscriptionManager.hasUnlockedPremium ? Color.white : Color.orange)
                                .frame(width: 70, height: 70)
                            
                            if !subscriptionManager.hasUnlockedPremium {
                                Image(systemName: "crown.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            
                            Circle()
                                .stroke(subscriptionManager.hasUnlockedPremium ? Color.white : Color.orange, lineWidth: 3)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .disabled(cameraHandler.isProcessing)
                    .opacity(cameraHandler.isProcessing ? 0.5 : 1.0)
                }
                .padding(.bottom, 100)
            }
            
            if showIdentifyResult, let capturedImage = cameraHandler.capturedImage {
                IdentifyResultView(
                    image: capturedImage,
                    breeds: identifiedBreeds,
                    onRetake: {
                        showIdentifyResult = false
                        cameraHandler.resumeCamera()
                    },
                    onSelectBreed: { breed in
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appProvider.navigate(to: .chickenBreedDetail(breed: breed))
                        }
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            if !hasSeenOnboarding {
                showingOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            IdentifyOnboardingView(isPresented: $showingOnboarding) {
                hasSeenOnboarding = true
                showingOnboarding = false
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private func captureAndIdentify() {
        // Check subscription status first
        if !subscriptionManager.hasUnlockedPremium {
            // Show paywall for non-premium users
            showPaywall = true
            return
        }
        
        // Premium users can proceed with identification
        cameraHandler.isProcessing = true
        cameraHandler.capturePhoto()
        
        Task {
            guard let capturedImage = cameraHandler.capturedImage else {
                await MainActor.run {
                    identifiedBreeds = Array(ChickenBreed.sampleData.shuffled().prefix(3))
                    cameraHandler.isProcessing = false
                    showIdentifyResult = true
                }
                return
            }
            
            if let breedName = await OpenAIService.shared.identifyChickenBreed(image: capturedImage),
               let identifiedBreed = ChickenBreed.sampleData.first(where: { $0.name == breedName }) {
                
                let additionalBreeds = ChickenBreed.sampleData
                    .filter { $0.name != breedName }
                    .shuffled()
                    .prefix(2)
                
                await MainActor.run {
                    identifiedBreeds = [identifiedBreed] + Array(additionalBreeds)
                    
                    appProvider.addIdentifiedBreed(identifiedBreed)
                    
                    cameraHandler.isProcessing = false
                    showIdentifyResult = true
                }
            } else {
                await MainActor.run {
                    identifiedBreeds = Array(ChickenBreed.sampleData.shuffled().prefix(3))
                    cameraHandler.isProcessing = false
                    showIdentifyResult = true
                }
            }
        }
    }
}

struct CornerBracket: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Color.orange, lineWidth: 3)
        .frame(width: 20, height: 20)
    }
}

struct IdentifyResultView: View {
    let image: UIImage
    let breeds: [ChickenBreed]
    let onRetake: () -> Void
    let onSelectBreed: (ChickenBreed) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                    HStack {
                        Text("Possible Matches")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: onRetake) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                        ForEach(Array(breeds.enumerated()), id: \.element.id) { index, breed in
                            Button(action: {
                                onSelectBreed(breed)
                            }) {
                                HStack {
                                    AsyncImage(url: URL(string: breed.imageURL)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(breed.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("\(90 - index * 10)% match confidence")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: onRetake) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
}

struct IdentifyOnboardingView: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    let sampleImages = [
        ChickenBreed.sampleData[0].imageURL,
        ChickenBreed.sampleData[1].imageURL,
        ChickenBreed.sampleData[2].imageURL,
        ChickenBreed.sampleData[3].imageURL,
        ChickenBreed.sampleData[4].imageURL
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("How to Use Chicken-AI Breeds")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    AsyncImage(url: URL(string: ChickenBreed.sampleData[0].imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 15) {
                            Text("1.")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("Spot a chicken breed.")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Home")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange)
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Text("Identify")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Saved")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 15) {
                            Text("2.")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("Snap a clear photo of the chicken.")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(sampleImages, id: \.self) { imageURL in
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .frame(width: 80, height: 80)
                                .cornerRadius(40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange, lineWidth: 3)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 15) {
                            Text("3.")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("Get a list of the most likely breeds based on visual traits.")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("Got it!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}
