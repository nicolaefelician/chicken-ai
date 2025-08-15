import SwiftUI
import Combine

enum NavigationDestination: Hashable {
    case chickenDetail(breed: ChickenBreed)
    case scanHistory
    case settings
    case articleList
    case articleDetail(article: Article)
    case chickenBreedList
    case chickenBreedDetail(breed: ChickenBreed)
}

final class AppProvider: ObservableObject {
    static let shared = AppProvider()
    
    @Published var navigationPath: [NavigationDestination] = []
    @Published var savedBreeds: [ChickenBreed] = []
    @Published var identifiedBreeds: [ChickenBreed] = []
    @Published var customBreeds: [ChickenBreed] = []
    @Published var hasSeenOnboarding: Bool = false
    @Published var pendingSearchText: String = ""
    @Published var isPremiumUser: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private let savedBreedsKey = "SavedChickenBreeds"
    private let identifiedBreedsKey = "IdentifiedChickenBreeds"
    private let customBreedsKey = "CustomChickenBreeds"
    private let onboardingKey = "HasSeenOnboarding"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var savedBreedsURL: URL {
        documentsDirectory.appendingPathComponent("savedBreeds.json")
    }
    
    private var identifiedBreedsURL: URL {
        documentsDirectory.appendingPathComponent("identifiedBreeds.json")
    }
    
    private var customBreedsURL: URL {
        documentsDirectory.appendingPathComponent("customBreeds.json")
    }
    
    private init() {
        loadSavedBreeds()
        loadIdentifiedBreeds()
        loadCustomBreeds()
        loadOnboardingState()
    }
    
    @MainActor
    func syncPremiumStatus() {
        let subscriptionManager = SubscriptionManager.shared
        isPremiumUser = subscriptionManager.hasUnlockedPremium
    }
    
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func popToRoot() {
        navigationPath.removeAll()
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func saveBreed(_ breed: ChickenBreed) {
        if !savedBreeds.contains(where: { $0.id == breed.id }) {
            savedBreeds.append(breed)
            saveBreedsToStorage()
        }
    }
    
    func removeBreed(_ breed: ChickenBreed) {
        savedBreeds.removeAll { $0.id == breed.id }
        saveBreedsToStorage()
    }
    
    func isBreedSaved(_ breed: ChickenBreed) -> Bool {
        savedBreeds.contains { $0.id == breed.id }
    }
    
    func toggleBreedSaved(_ breed: ChickenBreed) {
        if isBreedSaved(breed) {
            removeBreed(breed)
        } else {
            saveBreed(breed)
        }
    }
    
    func addIdentifiedBreed(_ breed: ChickenBreed) {
        if !identifiedBreeds.contains(where: { $0.name == breed.name }) {
            identifiedBreeds.append(breed)
            saveIdentifiedBreedsToStorage()
            
            saveBreed(breed)
        }
    }
    
    func removeIdentifiedBreed(_ breed: ChickenBreed) {
        identifiedBreeds.removeAll { $0.id == breed.id }
        saveIdentifiedBreedsToStorage()
    }
    
    func completeOnboarding() {
        hasSeenOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func addCustomBreed(_ breed: ChickenBreed) {
        customBreeds.append(breed)
        saveCustomBreedsToStorage()
    }
    
    func removeCustomBreed(_ breed: ChickenBreed) {
        customBreeds.removeAll { $0.id == breed.id }
        saveCustomBreedsToStorage()
    }
    
    private func saveBreedsToStorage() {
        do {
            let encoded = try JSONEncoder().encode(savedBreeds)
            try encoded.write(to: savedBreedsURL)
            UserDefaults.standard.set(encoded, forKey: savedBreedsKey)
        } catch {
            print("Failed to save breeds: \(error)")
        }
    }
    
    private func saveIdentifiedBreedsToStorage() {
        do {
            let encoded = try JSONEncoder().encode(identifiedBreeds)
            try encoded.write(to: identifiedBreedsURL)
            UserDefaults.standard.set(encoded, forKey: identifiedBreedsKey)
        } catch {
            print("Failed to save identified breeds: \(error)")
        }
    }
    
    private func loadSavedBreeds() {
        do {
            let data = try Data(contentsOf: savedBreedsURL)
            savedBreeds = try JSONDecoder().decode([ChickenBreed].self, from: data)
        } catch {
            if let data = UserDefaults.standard.data(forKey: savedBreedsKey),
               let decoded = try? JSONDecoder().decode([ChickenBreed].self, from: data) {
                savedBreeds = decoded
                saveBreedsToStorage()
            }
        }
    }
    
    private func loadIdentifiedBreeds() {
        do {
            let data = try Data(contentsOf: identifiedBreedsURL)
            identifiedBreeds = try JSONDecoder().decode([ChickenBreed].self, from: data)
        } catch {
            if let data = UserDefaults.standard.data(forKey: identifiedBreedsKey),
               let decoded = try? JSONDecoder().decode([ChickenBreed].self, from: data) {
                identifiedBreeds = decoded
                saveIdentifiedBreedsToStorage()
            }
        }
    }
    
    private func loadOnboardingState() {
        hasSeenOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    private func saveCustomBreedsToStorage() {
        do {
            let encoded = try JSONEncoder().encode(customBreeds)
            try encoded.write(to: customBreedsURL)
            UserDefaults.standard.set(encoded, forKey: customBreedsKey)
        } catch {
            print("Failed to save custom breeds: \(error)")
        }
    }
    
    private func loadCustomBreeds() {
        do {
            let data = try Data(contentsOf: customBreedsURL)
            customBreeds = try JSONDecoder().decode([ChickenBreed].self, from: data)
        } catch {
            if let data = UserDefaults.standard.data(forKey: customBreedsKey),
               let decoded = try? JSONDecoder().decode([ChickenBreed].self, from: data) {
                customBreeds = decoded
                saveCustomBreedsToStorage()
            }
        }
    }
}
