import SwiftUI
import PhotosUI
import CoreLocation

struct AddChickenBreedView: View {
    @Environment(\.dismiss) var dismiss
    private let appProvider = AppProvider.shared
    
    @State private var breedName = ""
    @State private var breedDescription = ""
    @State private var origin = ""
    @State private var habitat = ""
    @State private var eggProduction = ""
    @State private var temperament = ""
    @State private var size = ""
    @State private var purpose = ""
    @State private var lifespan = ""
    @State private var colorInput = ""
    @State private var colors: [String] = []
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var imageURL = ""
    
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Breed Image")) {
                    VStack {
                        if let imageData = selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    VStack(spacing: 10) {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.gray)
                                        Text("Select an image")
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        
                        PhotosPicker(selection: $selectedImage,
                                   matching: .images,
                                   photoLibrary: .shared()) {
                            Text("Choose Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                        .onChange(of: selectedImage) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    imageURL = "https://images.unsplash.com/photo-custom-breed"
                                }
                            }
                        }
                        
                        Text("Or enter image URL:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("https://example.com/image.jpg", text: $imageURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Basic Information")) {
                    TextField("Breed Name *", text: $breedName)
                    
                    VStack(alignment: .leading) {
                        Text("Description *")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $breedDescription)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                Section(header: Text("Origin & Location")) {
                    TextField("Country/Region of Origin *", text: $origin)
                    
                    HStack {
                        TextField("Latitude", text: $latitude)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", text: $longitude)
                            .keyboardType(.decimalPad)
                    }
                    
                    Text("Example: New York is 40.7128, -74.0060")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Characteristics")) {
                    TextField("Egg Production (e.g., 200-250 eggs per year) *", text: $eggProduction)
                    
                    TextField("Temperament (e.g., Friendly, calm) *", text: $temperament)
                    
                    TextField("Size (e.g., Large (7-9 lbs)) *", text: $size)
                    
                    TextField("Purpose (e.g., Dual-purpose) *", text: $purpose)
                    
                    TextField("Lifespan (e.g., 5-8 years) *", text: $lifespan)
                }
                
                Section(header: Text("Habitat & Care")) {
                    VStack(alignment: .leading) {
                        Text("Habitat Requirements")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $habitat)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                Section(header: Text("Color Varieties")) {
                    HStack {
                        TextField("Add color (e.g., Buff)", text: $colorInput)
                        Button(action: {
                            if !colorInput.isEmpty {
                                colors.append(colorInput)
                                colorInput = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if !colors.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(colors, id: \.self) { color in
                                    HStack(spacing: 4) {
                                        Text(color)
                                            .font(.caption)
                                        Button(action: {
                                            colors.removeAll { $0 == color }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(15)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Chicken Breed")
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
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                }
            }
            .alert("Missing Information", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveBreed() {
        guard !breedName.isEmpty else {
            alertMessage = "Please enter a breed name."
            showingAlert = true
            return
        }
        
        guard !breedDescription.isEmpty else {
            alertMessage = "Please enter a description."
            showingAlert = true
            return
        }
        
        guard !origin.isEmpty else {
            alertMessage = "Please enter the origin."
            showingAlert = true
            return
        }
        
        guard !eggProduction.isEmpty else {
            alertMessage = "Please enter egg production information."
            showingAlert = true
            return
        }
        
        guard !temperament.isEmpty else {
            alertMessage = "Please enter temperament information."
            showingAlert = true
            return
        }
        
        guard !size.isEmpty else {
            alertMessage = "Please enter size information."
            showingAlert = true
            return
        }
        
        guard !purpose.isEmpty else {
            alertMessage = "Please enter the breed's purpose."
            showingAlert = true
            return
        }
        
        guard !lifespan.isEmpty else {
            alertMessage = "Please enter lifespan information."
            showingAlert = true
            return
        }
        
        let lat = Double(latitude) ?? 0.0
        let lon = Double(longitude) ?? 0.0
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let finalImageURL = imageURL.isEmpty ? "https://images.unsplash.com/photo-1548550023-2bdb3c5beed7" : imageURL
        
        let newBreed = ChickenBreed(
            name: breedName,
            imageURL: finalImageURL,
            description: breedDescription,
            wikipediaLink: "https://en.wikipedia.org/wiki/\(breedName.replacingOccurrences(of: " ", with: "_"))_chicken",
            habitat: habitat.isEmpty ? "This breed adapts well to various environments." : habitat,
            origin: origin,
            originCoordinates: coordinates,
            eggProduction: eggProduction,
            temperament: temperament,
            size: size,
            purpose: purpose,
            lifespan: lifespan,
            colors: colors.isEmpty ? [breedName] : colors
        )
        
        appProvider.addCustomBreed(newBreed)
        
        dismiss()
    }
}

#Preview {
    AddChickenBreedView()
}