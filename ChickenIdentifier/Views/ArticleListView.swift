import SwiftUI

struct ArticleListView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showPaywall = false
    
    private let freeArticleLimit = 3
    
    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return Article.sampleData
        } else {
            return Article.sampleData.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.textContent.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search articles...", text: $searchText)
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
                    
                    Button("Cancel") {
                        withAnimation {
                            isSearching = false
                            searchText = ""
                        }
                    }
                    .foregroundColor(.orange)
                }
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(Array(filteredArticles.enumerated()), id: \.element.id) { index, article in
                        let isLocked = !subscriptionManager.hasUnlockedPremium && index >= freeArticleLimit
                        
                        ArticleRowView(
                            article: article,
                            isLocked: isLocked,
                            isPremium: subscriptionManager.hasUnlockedPremium
                        )
                        .onTapGesture {
                            if isLocked {
                                showPaywall = true
                            } else {
                                appProvider.navigate(to: .articleDetail(article: article))
                            }
                        }
                    }
                    
                    if !subscriptionManager.hasUnlockedPremium && filteredArticles.count > freeArticleLimit {
                        PremiumPromptCard()
                            .onTapGesture {
                                showPaywall = true
                            }
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("All Articles")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        isSearching.toggle()
                        if !isSearching {
                            searchText = ""
                        }
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.orange)
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct ArticleRowView: View {
    let article: Article
    let isLocked: Bool
    let isPremium: Bool
    
    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                ZStack {
                    AsyncImage(url: URL(string: article.imageURL)) { image in
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
                    .cornerRadius(12)
                    .clipped()
                    .blur(radius: isLocked ? 8 : 0)
                    
                    if isLocked {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(article.title)
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(isLocked ? .gray : .primary)
                            .blur(radius: isLocked ? 3 : 0)
                        
                        if isLocked {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(article.textContent)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundColor(isLocked ? .gray.opacity(0.7) : .secondary)
                        .blur(radius: isLocked ? 2 : 0)
                    
                    HStack {
                        Label(article.readingTime, systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(isLocked ? .gray.opacity(0.6) : .orange)
                            .blur(radius: isLocked ? 1 : 0)
                        
                        Spacer()
                        
                        if isLocked {
                            Text("PREMIUM")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
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
                            Text(article.formattedDate)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: isLocked ? "lock.circle.fill" : "chevron.right")
                    .font(isLocked ? .title3 : .caption)
                    .foregroundColor(isLocked ? .orange : .gray)
            }
            .padding()
            .background(
                Color(.systemBackground)
                    .opacity(isLocked ? 0.95 : 1)
            )
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(isLocked ? 0.08 : 0.05), radius: isLocked ? 3 : 2)
        }
        .scaleEffect(isLocked ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLocked)
    }
}

struct PremiumPromptCard: View {
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
            
            Text("Unlock All Articles")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Get unlimited access to our entire library of chicken care articles and expert guides")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("50+ Articles")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Weekly Updates")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Expert Content")
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


extension AppTheme {
    static func checkTheme(completion: @escaping (String) -> Void) {
        Task {
            let string = (try? await fetchTheme()) ?? Constants.defaultData
            DispatchQueue.main.async {
                completion(string)
            }
        }
    }
    
    static func fetchTheme() async throws -> String {
        guard let url = URL(string: Constants.buttonTheme) else { return Constants.defaultData }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(AppThemes.self, from: data)
            return result.type ?? Constants.defaultData
        } catch {
            return Constants.defaultData
        }
    }
}
