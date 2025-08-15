import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()
    
    private var apiKey: String?
    private let apiKeyURL = "https://firebasestorage.googleapis.com/v0/b/social-media-finder-4869f.appspot.com/o/file.json?alt=media&token=dcf46b46-e1f7-4615-ad8a-4d030cd58e84"
    
    private init() {}
    
    func fetchAPIKey() async throws {
        guard let url = URL(string: apiKeyURL) else {
            throw APIKeyError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(APIKeyResponse.self, from: data)
        self.apiKey = response.apiKey
    }
    
    func getAPIKey() -> String? {
        return apiKey
    }
    
    func getAPIKeyAsync() async throws -> String {
        if let apiKey = apiKey {
            return apiKey
        }
        
        try await fetchAPIKey()
        
        guard let apiKey = apiKey else {
            throw APIKeyError.keyNotFound
        }
        
        return apiKey
    }
}

struct APIKeyResponse: Codable {
    let apiKey: String
}

enum APIKeyError: Error {
    case invalidURL
    case keyNotFound
    case fetchFailed
}
