import SwiftUI

struct ChickenBreedListView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingAddBreed = false
    @State private var showPaywall = false
    
    private let freeBreedLimit = 3
    
    var allBreeds: [ChickenBreed] {
        ChickenBreed.sampleData + appProvider.customBreeds
    }
    
    var filteredBreeds: [ChickenBreed] {
        if searchText.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { breed in
                breed.name.localizedCaseInsensitiveContains(searchText) ||
                breed.description.localizedCaseInsensitiveContains(searchText) ||
                breed.origin.localizedCaseInsensitiveContains(searchText) ||
                breed.temperament.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search chickens...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(Array(filteredBreeds.enumerated()), id: \.element.id) { index, breed in
                        let isLocked = !subscriptionManager.hasUnlockedPremium && index >= freeBreedLimit
                        
                        ChickenBreedRowView(
                            breed: breed,
                            isLocked: isLocked,
                            isPremium: subscriptionManager.hasUnlockedPremium
                        )
                        .onTapGesture {
                            if isLocked {
                                showPaywall = true
                            } else {
                                appProvider.navigate(to: .chickenBreedDetail(breed: breed))
                            }
                        }
                    }
                    
                    if !subscriptionManager.hasUnlockedPremium && filteredBreeds.count > freeBreedLimit {
                        PremiumBreedPromptCard()
                            .onTapGesture {
                                showPaywall = true
                            }
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
            
            if filteredBreeds.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No chickens found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Try searching with different keywords")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .navigationTitle("All Chicken Breeds")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if subscriptionManager.hasUnlockedPremium {
                        showingAddBreed = true
                    } else {
                        showPaywall = true
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }
        }
        .fullScreenCover(isPresented: $showingAddBreed) {
            AddChickenBreedView()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            if !appProvider.pendingSearchText.isEmpty {
                searchText = appProvider.pendingSearchText
                appProvider.pendingSearchText = ""
            }
        }
    }
}

struct ChickenBreedRowView: View {
    let breed: ChickenBreed
    let isLocked: Bool
    let isPremium: Bool
    
    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                ZStack {
                    AsyncImage(url: URL(string: breed.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
                    .clipped()
                    .blur(radius: isLocked ? 8 : 0)
                    
                    if isLocked {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(breed.name)
                            .font(.headline)
                            .foregroundColor(isLocked ? .gray : .primary)
                            .blur(radius: isLocked ? 3 : 0)
                        
                        if isLocked {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(isLocked ? .gray.opacity(0.5) : .orange)
                        
                        Text(breed.origin)
                            .font(.caption)
                            .foregroundColor(isLocked ? .gray.opacity(0.5) : .orange)
                            .lineLimit(1)
                            .blur(radius: isLocked ? 2 : 0)
                    }
                    
                    if isLocked {
                        Text("PREMIUM BREED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    } else {
                        Text(breed.temperament)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: isLocked ? "lock.circle.fill" : "chevron.right")
                    .font(.system(size: isLocked ? 20 : 14))
                    .foregroundColor(isLocked ? .orange : .gray.opacity(0.5))
            }
            .padding()
            .background(
                Color(.systemBackground)
                    .opacity(isLocked ? 0.95 : 1)
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(isLocked ? 0.08 : 0.05), radius: 5, x: 0, y: 2)
            
            if isLocked {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .allowsHitTesting(false)
            }
        }
        .scaleEffect(isLocked ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLocked)
    }
}

struct PremiumBreedPromptCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.largeTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Unlock All Breeds")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Get access to our complete database of chicken breeds with detailed information")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "bird.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("50+ Breeds")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Add Custom")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Full Details")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
            }
            .padding(.vertical, 10)
            
            Text("Get Premium")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.5), .yellow.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .orange.opacity(0.2), radius: 10, y: 5)
    }
}

struct EntryScreen: View {
    
    @AppStorage("selectedTheme") private var selectedTheme = "System"
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var appProvider = AppProvider.shared
    
    @EnvironmentObject var startVM: HomeViewModel
    
    @State private var isAnimating = false
    
    var body: some View {
        if startVM.isLoading {
            preloader
        } else {
            main
        }
    }
    
    private var main: some View {
        VStack {
            if startVM.appTheme == .unspecified {
                ConfigurationScreen()
                    .environmentObject(startVM)
            } else {
                SplashScreenView()
                    .environmentObject(subscriptionManager)
                    .environmentObject(appProvider)
                    .onAppear {
                        applyTheme()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        Task {
                            appProvider.syncPremiumStatus()
                        }
                    }
            }
        }
    }
    
    private var preloader: some View {
        SplashView(isAnimating: $isAnimating, loadingText: .constant("Loading..."))
            .onAppear {
                isAnimating = true
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
