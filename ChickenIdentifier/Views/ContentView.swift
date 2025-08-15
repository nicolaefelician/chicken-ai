import SwiftUI

struct ContentView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    @State private var selectedTab = 0
    @State private var showIdentifyView = false
    @State private var cachedSizeClass: UserInterfaceSizeClass = .compact
    
    var body: some View {
        NavigationStack(path: $appProvider.navigationPath) {
            ZStack {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .environment(\.horizontalSizeClass, cachedSizeClass)
                        .tabItem {
                            VStack {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20))
                                Text("Home")
                                    .font(.system(size: 12))
                            }
                        }
                        .tag(0)
                    
                    SavedView()
                        .environment(\.horizontalSizeClass, cachedSizeClass)
                        .background(
                            GeometryReader { _ in
                                Color.clear
                            }
                        )
                        .tag(1)
                    
                    SavedView()
                        .environment(\.horizontalSizeClass, cachedSizeClass)
                        .tabItem {
                            VStack {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 20))
                                Text("Saved")
                                    .font(.system(size: 12))
                            }
                        }
                        .tag(2)
                }
                .accentColor(.orange)
                .tabViewStyle(DefaultTabViewStyle())
                .onPreferenceChange(SizeClassPreferenceKey.self) { value in
                    cachedSizeClass = value ?? .compact
                }
                .onChange(of: selectedTab) { _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                .transformEnvironment(\.horizontalSizeClass) { sizeClass in
                    sizeClass = .compact
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showIdentifyView = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    Color.orange
                                )
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -13)
                }
            }
            .fullScreenCover(isPresented: $showIdentifyView) {
                IdentifyView()
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .chickenDetail(let breed):
                    ChickenDetailView(breed: breed)
                case .scanHistory:
                    ScanHistoryView()
                case .settings:
                    SettingsView()
                case .articleList:
                    ArticleListView()
                case .articleDetail(let article):
                    ArticleDetailView(article: article)
                case .chickenBreedList:
                    ChickenBreedListView()
                case .chickenBreedDetail(let breed):
                    ChickenDetailView(breed: breed)
                }
            }
        }
    }
}
