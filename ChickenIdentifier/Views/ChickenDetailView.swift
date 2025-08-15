import SwiftUI
import MapKit

struct ChickenDetailView: View {
    let breed: ChickenBreed
    @ObservedObject private var appProvider = AppProvider.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var region: MKCoordinateRegion
    @State private var showingShareSheet = false
    
    var isSaved: Bool {
        appProvider.isBreedSaved(breed)
    }
    
    var shareContent: String {
        """
        🐔 \(breed.name) Chicken Breed
        
        📍 Origin: \(breed.origin)
        📏 Size: \(breed.size)
        🥚 Egg Production: \(breed.eggProduction)
        💭 Temperament: \(breed.temperament)
        ⏰ Lifespan: \(breed.lifespan)
        🎯 Purpose: \(breed.purpose)
        
        📝 Description: \(breed.description)
        
        Shared from Chicken-AI Breeds App
        """
    }
    
    init(breed: ChickenBreed) {
        self.breed = breed
        self._region = State(initialValue: MKCoordinateRegion(
            center: breed.originCoordinates,
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: breed.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                            )
                            .frame(width: geometry.size.width, height: 300)
                    }
                    .clipped()
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(breed.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(breed.origin, systemImage: "location.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            Button(action: {
                                appProvider.toggleBreedSaved(breed)
                            }) {
                                Image(systemName: isSaved ? "heart.fill" : "heart")
                                    .foregroundColor(isSaved ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(breed.description)
                            .font(.body)
                            .lineSpacing(5)
                        
                        Link(destination: URL(string: breed.wikipediaLink)!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                Text("Learn More on Wikipedia")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Facts")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            InfoRow(icon: "scalemass.fill", label: "Size", value: breed.size)
                            InfoRow(icon: "flag.fill", label: "Purpose", value: breed.purpose)
                            InfoRow(icon: "calendar", label: "Lifespan", value: breed.lifespan)
                            InfoRow(icon: "circle.grid.2x2.fill", label: "Egg Production", value: breed.eggProduction)
                            InfoRow(icon: "heart.fill", label: "Temperament", value: breed.temperament)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Habitat")
                            .font(.headline)
                        
                        Text(breed.habitat)
                            .font(.body)
                            .lineSpacing(5)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available Colors")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(breed.colors, id: \.self) { color in
                                    Text(color)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Origin")
                            .font(.headline)
                        
                        Map(coordinateRegion: .constant(region), annotationItems: [breed]) { item in
                            MapMarker(coordinate: item.originCoordinates, tint: .orange)
                        }
                        .frame(height: 200)
                        .cornerRadius(15)
                        .disabled(true)
                    }
                }
                .padding()
            }
        }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
                        appProvider.toggleBreedSaved(breed)
                    }) {
                        Label(isSaved ? "Remove from Favorites" : "Add to Favorites", systemImage: isSaved ? "heart.slash" : "heart")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showingShareSheet) {
            ShareView(activityItems: [shareContent])
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 25)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct ShareView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ScanHistoryView: View {
    @EnvironmentObject var appProvider: AppProvider
    
    var body: some View {
        VStack {
            Text("Scan History")
                .font(.largeTitle)
                .padding()
            
            Text("Your previous chicken scans will appear here")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}
