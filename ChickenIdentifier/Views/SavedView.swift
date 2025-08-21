import SwiftUI
import CoreLocation

struct SavedView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingAddBreed = false
    @State private var showPaywall = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            Group {
                if appProvider.savedBreeds.isEmpty {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "heart.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 80, height: 80)
                                    )
                            }
                            
                            VStack(spacing: 12) {
                                Text("No Saved Breeds Yet")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Start exploring chicken breeds and save\nyour favorites to see them here")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Button(action: {
                                appProvider.popToRoot()
                                appProvider.navigate(to: .chickenBreedList)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Explore Breeds")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(appProvider.savedBreeds) { breed in
                                HStack(spacing: 15) {
                                    if editMode == .active {
                                        Button(action: {
                                            withAnimation {
                                                appProvider.removeBreed(breed)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title2)
                                        }
                                    }
                                    AsyncImage(url: URL(string: breed.imageURL)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay(
                                                ProgressView()
                                            )
                                    }
                                    .frame(width: 75, height: 75)
                                    .cornerRadius(12)
                                    .clipped()
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(breed.name)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "location.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                            
                                            Text(breed.origin)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Label("\(breed.eggProduction.components(separatedBy: " ").first ?? "")", systemImage: "circle.grid.2x2.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                            
                                            Label(breed.temperament, systemImage: "heart.fill")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if editMode == .inactive {
                                        appProvider.navigate(to: .chickenDetail(breed: breed))
                                    }
                                }
                                .contextMenu {
                                    Button(action: {
                                        appProvider.removeBreed(breed)
                                    }) {
                                        Label("Remove from Saved", systemImage: "heart.slash")
                                    }
                                    
                                    Button(action: {
                                        appProvider.navigate(to: .chickenDetail(breed: breed))
                                    }) {
                                        Label("View Details", systemImage: "info.circle")
                                    }
                                }
                            }
                            
                            if !subscriptionManager.hasUnlockedPremium {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Add Custom Breeds")
                                                .font(.headline)
                                            Text("Upgrade to premium to add your own breeds")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.orange.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .onTapGesture {
                                        showPaywall = true
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        appProvider.navigate(to: .settings)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !appProvider.savedBreeds.isEmpty {
                        Button(action: {
                            if editMode == .inactive {
                                withAnimation {
                                    editMode = .active
                                }
                            } else {
                                withAnimation {
                                    editMode = .inactive
                                }
                            }
                        }) {
                            Text(editMode == .active ? "Done" : "Edit")
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Button(action: {
                            if subscriptionManager.hasUnlockedPremium {
                                showingAddBreed = true
                            } else {
                                showPaywall = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                
                                if !subscriptionManager.hasUnlockedPremium {
                                    Image(systemName: "crown.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .sheet(isPresented: $showingAddBreed) {
            AddBreedView()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct AddBreedView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var appProvider = AppProvider.shared
    @State private var breedName = ""
    @State private var origin = ""
    @State private var characteristics = ""
    @State private var imageURL = ""
    @State private var eggProduction = "150-200 eggs/year"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Breed Name", text: $breedName)
                    TextField("Origin Country", text: $origin)
                    TextField("Image URL", text: $imageURL)
                }
                
                Section(header: Text("Characteristics")) {
                    TextEditor(text: $characteristics)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Production")) {
                    Picker("Egg Production", selection: $eggProduction) {
                        Text("50-100 eggs/year").tag("50-100 eggs/year")
                        Text("100-150 eggs/year").tag("100-150 eggs/year")
                        Text("150-200 eggs/year").tag("150-200 eggs/year")
                        Text("200-250 eggs/year").tag("200-250 eggs/year")
                        Text("250-300 eggs/year").tag("250-300 eggs/year")
                        Text("300+ eggs/year").tag("300+ eggs/year")
                    }
                }
            }
            .navigationTitle("Add Custom Breed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBreed()
                    }
                    .disabled(breedName.isEmpty || origin.isEmpty)
                }
            }
        }
    }
    
    private func saveBreed() {
        let customBreed = ChickenBreed(
            name: breedName,
            imageURL: imageURL.isEmpty ? "https://via.placeholder.com/300" : imageURL,
            description: characteristics,
            wikipediaLink: "",
            habitat: origin,
            origin: origin,
            originCoordinates: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            eggProduction: eggProduction,
            temperament: "Custom",
            size: "Medium",
            purpose: "Dual-purpose",
            lifespan: "5-8 years",
            colors: ["Various"]
        )
        
        appProvider.addCustomBreed(customBreed)
        dismiss()
    }
}

extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
