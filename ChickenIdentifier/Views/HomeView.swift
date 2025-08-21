import SwiftUI

struct HomeView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var currentArticleIndex = 0
    @State private var searchText = ""
    @State private var showPaywall = false
    @FocusState private var isSearchFocused: Bool
    let articles = Array(Article.sampleData.prefix(5))
    let breeds = Array(ChickenBreed.sampleData.prefix(7))
    
    private let freeArticleLimit = 3
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        HStack {
                            Text("Featured Articles")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                appProvider.navigate(to: .articleList)
                            }) {
                                HStack(spacing: 4) {
                                    Text("View All")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                        
                        TabView(selection: $currentArticleIndex) {
                            ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                                let isLocked = !subscriptionManager.hasUnlockedPremium && index >= freeArticleLimit
                                ArticleCardView(article: article, isLocked: isLocked)
                                    .tag(index)
                                    .onTapGesture {
                                        if isLocked {
                                            showPaywall = true
                                        } else {
                                            appProvider.navigate(to: .articleDetail(article: article))
                                        }
                                    }
                            }
                        }
                        .frame(height: 220)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        HStack(spacing: 8) {
                            ForEach(0..<articles.count, id: \.self) { index in
                                Circle()
                                    .fill(currentArticleIndex == index ? Color.orange : Color.gray.opacity(0.4))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut, value: currentArticleIndex)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Search over 500 chickens", text: $searchText)
                            .font(.subheadline)
                            .focused($isSearchFocused)
                            .onSubmit {
                                if !searchText.isEmpty {
                                    navigateToSearchResults()
                                }
                            }
                        
                        Button(action: {
                            navigateToSearchResults()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Browse chickens")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                appProvider.navigate(to: .chickenBreedList)
                            }) {
                                HStack(spacing: 4) {
                                    Text("View All")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                ForEach(breeds) { breed in
                                    ChickenBreedCard(breed: breed)
                                        .onTapGesture {
                                            appProvider.navigate(to: .chickenBreedDetail(breed: breed))
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 1)
                        }
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Tips")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach([
                                "Look at comb shape",
                                "Check feather patterns",
                                "Observe body size",
                                "Notice leg color and texture",
                                "Watch their behavior and temperament",
                                "Listen to their unique vocalizations",
                                "Check egg color if available"
                            ], id: \.self) { tip in
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text(tip)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        appProvider.navigate(to: .settings)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
    
    private func navigateToSearchResults() {
        appProvider.navigate(to: .chickenBreedList)
        if !searchText.isEmpty {
            appProvider.pendingSearchText = searchText
            searchText = ""
        }
    }
}

final class HomeViewModel: NSObject, ObservableObject {
    
    var dataItem: DispatchWorkItem?
    var dataObservers: [NSKeyValueObservation] = []
    
    @AppStorage("isRate") var isRate = false
    @AppStorage("defaultData") var data = Constants.defaultData
    @AppStorage("appTheme") var appTheme: AppTheme = .light {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    @Published var isLoading = true
    @Published var startView: ArticleView? {
        didSet {
            setupObserv()
        }
    }
    
    private func addStartView() {
        let view = ArticleView()
        view.navigationDelegate = self
        view.uiDelegate = self
        self.startView = view
    }
    
    func changePrior<Value>(in view: ArticleView, for keyPath: KeyPath<ArticleView, Value>) -> NSKeyValueObservation {
        view.observe(keyPath, options: [.prior]) { _, change in
            if change.isPrior {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    private func setupObserv() {
        dataObservers.forEach { $0.invalidate() }
        dataObservers.removeAll()
        guard let view = startView else { return }
        dataObservers = [ changePrior(in: view, for: \.canGoBack), changePrior (in: view, for: \.canGoForward)]
        
    }
    
    func loadTheme(_ urlString: String) {
        switch appTheme {
        case .unspecified:
            laodUnspecifiedTheme()
        case .light:
            loadLightTheme(urlString)
        default: break
        }
    }
    
    func loadLightTheme(_ info: String) {
        guard let url = URL(string: info) else {
            loadBlackTheme()
            return
        }
        
        addStartView()
        self.data = info
        appTheme = .dark
        loadView(with: url)
    }
    
    func laodUnspecifiedTheme() {
        addStartView()
        guard appTheme == .unspecified, let safeUrl = URL(string: data) else { return }
        loadView(with: safeUrl)
    }
    
    private func loadView(with safeUrl: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.startView?.load(URLRequest(url: safeUrl, cachePolicy: .returnCacheDataElseLoad))
        }
    }
    
    func loadBlackTheme() {
        appTheme = .neutral
        startView = nil
    }
}
