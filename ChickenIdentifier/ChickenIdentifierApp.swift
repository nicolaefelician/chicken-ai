
import SwiftUI

@main
struct ChickenIdentifierApp: App {
    @AppStorage("selectedTheme") private var selectedTheme = "System"
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var appProvider = AppProvider.shared
    
    init() {
        // Products will be loaded in SplashScreenView
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(subscriptionManager)
                .environmentObject(appProvider)
                .onAppear {
                    applyTheme()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Only refresh when app returns from background (important for purchases made outside app)
                    Task {
                        appProvider.syncPremiumStatus()
                    }
                }
        }
    }
    
    private func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch selectedTheme {
        case "Light":
            window.overrideUserInterfaceStyle = .light
        case "Dark":
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}
