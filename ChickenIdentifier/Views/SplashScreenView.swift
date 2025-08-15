import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showMainContent = false
    @State private var loadingText = "Loading..."
    @ObservedObject private var appProvider = AppProvider.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        if showMainContent {
            if appProvider.hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image("icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .rotationEffect(.degrees(isAnimating ? 0 : -5))
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    VStack(spacing: 10) {
                        Text("Chicken-AI")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Breeds")
                            .font(.system(size: 38, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(
                        Animation.easeOut(duration: 0.8).delay(0.3),
                        value: isAnimating
                    )
                    
                    VStack(spacing: 15) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text(loadingText)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(
                        Animation.easeIn(duration: 0.5).delay(0.8),
                        value: isAnimating
                    )
                }
                .padding()
            }
            .onAppear {
                isAnimating = true
                loadData()
            }
        }
    }
    
    private func loadData() {
        Task {
            await MainActor.run {
                loadingText = "Initializing..."
            }
            
            // Fetch API key from Firebase
            do {
                try await APIKeyManager.shared.fetchAPIKey()
            } catch {
                print("Failed to fetch API key: \(error)")
            }
            
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            await MainActor.run {
                loadingText = "Checking subscription..."
            }
            
            await subscriptionManager.loadProducts()
            await subscriptionManager.updateCustomerProductStatus()
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await MainActor.run {
                loadingText = "Loading saved breeds..."
            }
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await MainActor.run {
                loadingText = "Preparing camera..."
            }
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await MainActor.run {
                loadingText = "Almost ready..."
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                appProvider.syncPremiumStatus()
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMainContent = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
