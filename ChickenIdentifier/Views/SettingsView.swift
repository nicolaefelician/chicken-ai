import SwiftUI
import StoreKit
import MessageUI

struct SettingsView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("selectedTheme") private var selectedTheme = "System"
    @State private var showPaywall = false
    @Environment(\.requestReview) var requestReview
    
    let themes = ["System", "Light", "Dark"]
    
    var body: some View {
        Form {
            Section {
                if subscriptionManager.hasUnlockedPremium {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Premium Member")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            Text("All features unlocked")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else {
                    Button(action: { showPaywall = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                    Text("Get Premium")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                Text("Unlock all features")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            
            Section(header: Text("General")) {
                HStack {
                    Label {
                        Text("Theme")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.orange)
                    }
                    Spacer()
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.orange)
                    .onChange(of: selectedTheme) { _ in
                        applyTheme()
                    }
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Label {
                        Text("Version")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                    }
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink(destination: AboutView()) {
                    Label {
                        Text("About Chicken-AI Breeds")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Link(destination: URL(string: "https://www.termsfeed.com/live/6a3af8bf-7ea0-4d58-b858-21209072b45e")!) {
                    HStack {
                        Label {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://www.termsfeed.com/live/a115dec5-9eb0-4f46-9b53-786627371c36")!) {
                    HStack {
                        Label {
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Support")) {
                Button(action: contactSupport) {
                    Label {
                        Text("Contact Support")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Button(action: {
                    requestReview()
                }) {
                    Label {
                        Text("Rate App")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                    }
                }
                
            }
            
            Section {
                Button(action: restorePurchases) {
                    HStack {
                        Spacer()
                        Text("Restore Purchases")
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
                .foregroundColor(.orange)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            applyTheme()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await subscriptionManager.restorePurchases()
            } catch {
                print("Failed to restore purchases: \(error)")
            }
        }
    }
    
    private func contactSupport() {
        let email = "graysonhale@fitness-depotgyms.cfd"
        let subject = "Chicken-AI Breeds Support"
        let body = "Hello,\n\nI need help with...\n\n---\nApp Version: 1.0\nDevice: \(UIDevice.current.model)\niOS Version: \(UIDevice.current.systemVersion)"
        
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
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

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "bird.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .padding(.top, 40)
                
                Text("Chicken-AI Breeds")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Chicken-AI Breeds is your comprehensive guide to identifying and learning about different chicken breeds. Using advanced AI technology, our app helps you identify chicken breeds instantly.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Features:")
                        .font(.headline)
                    
                    FeatureRow(icon: "camera.fill", text: "Instant breed identification")
                    FeatureRow(icon: "book.fill", text: "Comprehensive breed database")
                    FeatureRow(icon: "map.fill", text: "Origin and habitat information")
                    FeatureRow(icon: "clock.fill", text: "Scan history tracking")
                    FeatureRow(icon: "newspaper.fill", text: "Educational articles")
                }
                .padding()
                
                Text("© 2024 Chicken-AI Breeds. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30)
            Text(text)
                .font(.subheadline)
        }
    }
}


