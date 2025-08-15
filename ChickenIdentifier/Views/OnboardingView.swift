import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMainApp = false
    private let appProvider = AppProvider.shared
    private let totalPages = 4
    
    var body: some View {
        if showMainApp {
            ContentView()
        } else {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            appProvider.completeOnboarding()
                            showMainApp = true
                        }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    TabView(selection: $currentPage) {
                        OnboardingSlide(
                            iconName: "bird.fill",
                            iconColor: Color(red: 1.0, green: 0.8, blue: 0.4),
                            title: "Nearby Chickens",
                            description: "Explore chicken breeds spotted near you on an interactive map."
                        )
                        .tag(0)
                        
                        OnboardingSlide(
                            iconName: "bookmark.fill",
                            iconColor: Color(red: 0.3, green: 0.4, blue: 0.9),
                            title: "Save to Collection",
                            description: "Add your favorite chicken breeds to your personal collection for easy access."
                        )
                        .tag(1)
                        
                        OnboardingSlide(
                            iconName: "magnifyingglass",
                            iconColor: Color(red: 0.2, green: 0.6, blue: 0.9),
                            title: "Search over 500 chickens",
                            description: "Easily find detailed info on hundreds of chicken breeds and add favorites to your collection."
                        )
                        .tag(2)
                        
                        OnboardingSlide(
                            iconName: "bird",
                            iconColor: Color(red: 1.0, green: 0.8, blue: 0.2),
                            title: "Breed Details",
                            description: "Learn all about a chicken breed's characteristics, origin, and care tips."
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    Button(action: {
                        if currentPage < totalPages - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            appProvider.completeOnboarding()
                            showMainApp = true
                        }
                    }) {
                        Text(currentPage == totalPages - 1 ? "Get Started" : "Next")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.orange)
                            )
                            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

struct OnboardingSlide: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 60) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 50)
                    .fill(iconColor)
                    .frame(width: 240, height: 240)
                
                Image(systemName: iconName)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(.white)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView()
}