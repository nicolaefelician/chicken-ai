import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    
    private init() {}
    
    func identifyChickenBreed(image: UIImage) async -> String? {
        guard let base64Image = Utilities.shared.convertImageToBase64(image: image) else {
            print("Failed to convert image to Base64")
            return nil
        }
        
        let apiKey: String
        do {
            apiKey = try await APIKeyManager.shared.getAPIKeyAsync()
        } catch {
            print("Failed to get API key: \(error)")
            return nil
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let breedNames = ChickenBreed.sampleData.map { $0.name }.joined(separator: ", ")
        
        let systemPrompt = """
        You are an expert poultry specialist. Analyze the provided image and identify which chicken breed it most closely matches from this specific list of breeds ONLY:
        
        \(breedNames)
        
        You MUST select ONE breed name from the above list that best matches the chicken in the image based on:
        - Feather color and patterns
        - Body size and shape
        - Comb type and size
        - Leg color and feathering
        - Overall appearance
        
        Return ONLY the breed name exactly as it appears in the list above. Do not add any additional text or formatting.
        If the image doesn't clearly show a chicken or is unclear, select the breed that seems most likely based on any visible features.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Identify the chicken breed in this image. Return only the breed name from the provided list."],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 50,
            "temperature": 0.3
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        return await fetchApiResponse(request: request)
    }
    
    private func fetchApiResponse(request: URLRequest) async -> String? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("HTTP Error: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return nil
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let content = openAIResponse.choices.first?.message.content else {
                print("No content in response")
                return nil
            }
            
            let breedName = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if ChickenBreed.sampleData.contains(where: { $0.name == breedName }) {
                return breedName
            }
            
            print("Breed not found in sample data: \(breedName)")
            return ChickenBreed.sampleData.randomElement()?.name
            
        } catch {
            print("API Error: \(error)")
            return nil
        }
    }
    
    private func extractJSONFromContent(_ content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("```json") && trimmed.hasSuffix("```") {
            let startIndex = trimmed.index(trimmed.startIndex, offsetBy: 7)
            let endIndex = trimmed.index(trimmed.endIndex, offsetBy: -3)
            return String(trimmed[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if trimmed.hasPrefix("```") && trimmed.hasSuffix("```") {
            let startIndex = trimmed.index(trimmed.startIndex, offsetBy: 3)
            let endIndex = trimmed.index(trimmed.endIndex, offsetBy: -3)
            return String(trimmed[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return trimmed
    }
}
