import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    private let appProvider = AppProvider.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var isSaved = false
    @State private var showingShareSheet = false
    
    var shareContent: String {
        """
        \(article.title)
        
        \(article.textContent)
        
        Reading time: \(article.readingTime)
        
        Shared from Chicken-AI Breeds App
        """
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Behavior")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    
                    Text(article.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(article.readingTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 5) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(article.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text(article.textContent)
                        .font(.body)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Related Topics")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(["Egg Production", "Breed Care", "Feeding", "Health", "Housing"], id: \.self) { topic in
                                    Text(topic)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            isSaved.toggle()
                        }) {
                            Label(isSaved ? "Saved" : "Save Article", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isSaved ? Color.green : Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.headline)
                        }
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.headline)
                        }
                        .frame(width: 50)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareContent])
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {
                        isSaved.toggle()
                    }) {
                        Label(isSaved ? "Remove from Saved" : "Save", systemImage: isSaved ? "bookmark.slash" : "bookmark")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ConfigurationScreen: View {
        
    @EnvironmentObject var vm: HomeViewModel
        
    var body: some View {
        ZStack {
            background
            
            controls
        }
        .onAppear {
            if ChickenIdentifierApp.orientMask != .all {
                ChickenIdentifierApp.orientMask = .all
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
    
    private var background: some View {
        Color.black
            .ignoresSafeArea()
    }
    
    private var controls: some View {
        VStack(spacing: 8) {
            if let view = vm.startView {
                ArticleDetailRepresentable(view: view)
                
                HStack(spacing: 14) {
                    ArrowButton(arrow: .left) {
                        vm.startView?.goBack()
                    }
                    .disabled(view.canGoBack)
                    
                    ArrowButton(arrow: .right) {
                        vm.startView?.goForward()
                    }
                    .disabled(view.canGoForward)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                progress
            }
        }
    }
    
    private var progress: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
