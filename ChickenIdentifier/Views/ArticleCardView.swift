import SwiftUI

struct ArticleCardView: View {
    let article: Article
    let isLocked: Bool
    
    init(article: Article, isLocked: Bool = false) {
        self.article = article
        self.isLocked = isLocked
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
            .frame(width: UIScreen.main.bounds.width - 40, height: 220)
            .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(isLocked ? 0.8 : 0.7),
                    Color.black.opacity(isLocked ? 0.5 : 0.3),
                    Color.clear
                ]),
                startPoint: .bottom,
                endPoint: .center
            )
            
            if isLocked {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            
                            Text("PREMIUM")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
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
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Behavior")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(isLocked ? Color.gray : Color.white)
                        .foregroundColor(isLocked ? .white : .black)
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    if isLocked {
                        Image(systemName: "lock.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(article.readingTime) • \(article.formattedDate)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(article.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if isLocked {
                            Text("Subscribe to read this article")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 220)
        .cornerRadius(20)
        .shadow(radius: 5)
        .scaleEffect(isLocked ? 0.98 : 1.0)
        .overlay(
            isLocked ?
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.orange.opacity(0.5), .yellow.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            : nil
        )
    }
}