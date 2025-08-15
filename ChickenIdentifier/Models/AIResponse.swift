import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

struct ChickenIdentificationResult: Codable {
    let breedName: String
    let confidence: Double
    let origin: String
    let size: String
    let eggProduction: String
    let temperament: String
    let description: String
    let imageURL: String?
    let lifespan: String
    let weight: String
    let primaryUse: String
    let specialCharacteristics: String
    
    enum CodingKeys: String, CodingKey {
        case breedName = "breed_name"
        case confidence
        case origin
        case size
        case eggProduction = "egg_production"
        case temperament
        case description
        case imageURL = "image_url"
        case lifespan
        case weight
        case primaryUse = "primary_use"
        case specialCharacteristics = "special_characteristics"
    }
}