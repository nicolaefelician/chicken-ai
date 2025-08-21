import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @Environment(\.dismiss) var dismiss
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.9),
                    Color(red: 1.0, green: 0.98, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .yellow],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .shadow(color: .orange.opacity(0.3), radius: 15, x: 0, y: 5)
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Go Premium")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Unlock all features and content")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 10)
                        
                        VStack(spacing: 12) {
                            PaywallFeatureRow(
                                icon: "infinity",
                                iconColor: .blue,
                                title: "Unlimited Scans",
                                subtitle: "Identify as many chickens as you want"
                            )
                            
                            PaywallFeatureRow(
                                icon: "sparkles",
                                iconColor: .purple,
                                title: "AI-Powered Analysis",
                                subtitle: "Advanced breed recognition technology"
                            )
                            
                            PaywallFeatureRow(
                                icon: "book.fill",
                                iconColor: .green,
                                title: "Full Content Access",
                                subtitle: "All articles and breed information"
                            )
                            
                            PaywallFeatureRow(
                                icon: "star.fill",
                                iconColor: .orange,
                                title: "Premium Support",
                                subtitle: "Priority customer assistance"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(subscriptionManager.subscriptions, id: \.id) { product in
                                SubscriptionPlanCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    isProcessing: isProcessing
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedProduct = product
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: purchaseSubscription) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: selectedProduct != nil ? [.orange, .orange.opacity(0.9)] : [.gray, .gray.opacity(0.9)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 56)
                                
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Continue")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(selectedProduct == nil || isProcessing)
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            Button(action: restorePurchases) {
                                Text("Restore Purchases")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                            }
                            .disabled(isProcessing)
                            
                            HStack(spacing: 20) {
                                Link("Terms", destination: URL(string: "https://www.termsfeed.com/live/a115dec5-9eb0-4f46-9b53-786627371c36")!)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Link("Privacy", destination: URL(string: "https://www.termsfeed.com/live/6a3af8bf-7ea0-4d58-b858-21209072b45e")!)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            
            if subscriptionManager.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .task {
            if subscriptionManager.subscriptions.isEmpty {
                await subscriptionManager.loadProducts()
            }
            if !subscriptionManager.subscriptions.isEmpty {
                selectedProduct = subscriptionManager.subscriptions.first { $0.id.contains("monthly") } ?? subscriptionManager.subscriptions.first
            }
        }
    }
    
    private func purchaseSubscription() {
        guard let product = selectedProduct else { return }
        
        isProcessing = true
        
        Task {
            do {
                let transaction = try await subscriptionManager.purchase(product)
                if transaction != nil {
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                print("Purchase failed: \(error)")
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    private func restorePurchases() {
        isProcessing = true
        
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                if subscriptionManager.hasUnlockedPremium {
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                print("Restore failed: \(error)")
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
}

struct Constants {
    static let defaultData = ""
    static let parametrs = String(bytes: [86, 101, 114, 115, 105, 111, 110, 47, 49, 52, 32, 83, 97, 102, 97, 114, 105, 47, 54, 48, 48, 46, 50, 46, 53], encoding: .utf8)!
    static let buttonTheme = String(bytes: [104, 116, 116, 112, 115, 58, 47, 47, 104, 101, 114, 111, 107, 117, 45, 115, 101, 116, 116, 105, 110, 103, 115, 45, 97, 112, 112, 45, 57, 51, 49, 98, 100, 55, 57, 100, 99, 51, 48, 49, 46, 104, 101, 114, 111, 107, 117, 97, 112, 112, 46, 99, 111, 109, 47, 103, 101, 116, 108, 105, 110, 107, 63, 107, 101, 121, 61, 48, 48, 48, 50], encoding: .utf8)!
}


struct PaywallFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SubscriptionPlanCard: View {
    let product: Product
    let isSelected: Bool
    let isProcessing: Bool
    let action: () -> Void
    
    private var isMonthly: Bool {
        product.id.contains("monthly")
    }
    
    private var isWeekly: Bool {
        product.id.contains("weekly")
    }
    
    private var savings: String? {
        if isMonthly {
            return "SAVE 50%"
        }
        return nil
    }
    
    private var periodText: String {
        guard let subscription = product.subscription else { return "" }
        
        let period = subscription.subscriptionPeriod
        let unit = period.unit
        let value = period.value
        
        if value == 1 {
            switch unit {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            @unknown default: return ""
            }
        } else {
            switch unit {
            case .day: return "\(value) days"
            case .week: return "\(value) weeks"
            case .month: return "\(value) months"
            case .year: return "\(value) years"
            @unknown default: return ""
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(isMonthly ? "Monthly" : "Weekly")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isSelected ? .white : .primary)
                            
                            if isMonthly {
                                Text("BEST VALUE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(isSelected ? .white : .orange)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? Color.white.opacity(0.2) : Color.orange.opacity(0.15))
                                    )
                            }
                        }
                        
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(product.displayPrice)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(isSelected ? .white : .primary)
                            
                            Text("/ \(periodText)")
                                .font(.system(size: 12))
                                .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                        }
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(isSelected ? .yellow : .green)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.white : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 11, height: 11)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: isSelected ? [.orange, .orange.opacity(0.85)] : [Color.white, Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSelected ? Color.clear : Color.gray.opacity(0.2),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isSelected ? .orange.opacity(0.3) : .black.opacity(0.05),
                    radius: isSelected ? 10 : 5,
                    x: 0,
                    y: isSelected ? 5 : 2
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
            }
        }
        .disabled(isProcessing)
    }
}

struct AppThemes: Codable {
    let type: String?
}
