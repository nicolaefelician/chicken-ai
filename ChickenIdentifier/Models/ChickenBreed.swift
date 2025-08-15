import Foundation
import CoreLocation

class ChickenBreed: Identifiable, Codable, ObservableObject, Hashable {
    static func == (lhs: ChickenBreed, rhs: ChickenBreed) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    @Published var name: String
    @Published var imageURL: String
    @Published var description: String
    @Published var wikipediaLink: String
    @Published var habitat: String
    @Published var origin: String
    @Published var originCoordinates: CLLocationCoordinate2D
    @Published var eggProduction: String
    @Published var temperament: String
    @Published var size: String
    @Published var purpose: String
    @Published var lifespan: String
    @Published var colors: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        imageURL: String,
        description: String,
        wikipediaLink: String,
        habitat: String,
        origin: String,
        originCoordinates: CLLocationCoordinate2D,
        eggProduction: String,
        temperament: String,
        size: String,
        purpose: String,
        lifespan: String,
        colors: [String]
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.description = description
        self.wikipediaLink = wikipediaLink
        self.habitat = habitat
        self.origin = origin
        self.originCoordinates = originCoordinates
        self.eggProduction = eggProduction
        self.temperament = temperament
        self.size = size
        self.purpose = purpose
        self.lifespan = lifespan
        self.colors = colors
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, imageURL, description, wikipediaLink, habitat, origin
        case latitude, longitude
        case eggProduction, temperament, size, purpose, lifespan, colors
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        description = try container.decode(String.self, forKey: .description)
        wikipediaLink = try container.decode(String.self, forKey: .wikipediaLink)
        habitat = try container.decode(String.self, forKey: .habitat)
        origin = try container.decode(String.self, forKey: .origin)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        originCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        eggProduction = try container.decode(String.self, forKey: .eggProduction)
        temperament = try container.decode(String.self, forKey: .temperament)
        size = try container.decode(String.self, forKey: .size)
        purpose = try container.decode(String.self, forKey: .purpose)
        lifespan = try container.decode(String.self, forKey: .lifespan)
        colors = try container.decode([String].self, forKey: .colors)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(description, forKey: .description)
        try container.encode(wikipediaLink, forKey: .wikipediaLink)
        try container.encode(habitat, forKey: .habitat)
        try container.encode(origin, forKey: .origin)
        try container.encode(originCoordinates.latitude, forKey: .latitude)
        try container.encode(originCoordinates.longitude, forKey: .longitude)
        try container.encode(eggProduction, forKey: .eggProduction)
        try container.encode(temperament, forKey: .temperament)
        try container.encode(size, forKey: .size)
        try container.encode(purpose, forKey: .purpose)
        try container.encode(lifespan, forKey: .lifespan)
        try container.encode(colors, forKey: .colors)
    }
}

extension ChickenBreed {
    static func from(aiResult: ChickenIdentificationResult) -> ChickenBreed {
        var coordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        let originLower = aiResult.origin.lowercased()
        if originLower.contains("united states") || originLower.contains("usa") {
            coordinates = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795)
        } else if originLower.contains("united kingdom") || originLower.contains("britain") || originLower.contains("england") {
            coordinates = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        } else if originLower.contains("china") {
            coordinates = CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954)
        } else if originLower.contains("italy") {
            coordinates = CLLocationCoordinate2D(latitude: 43.7711, longitude: 11.2486)
        } else if originLower.contains("france") {
            coordinates = CLLocationCoordinate2D(latitude: 46.2276, longitude: 2.2137)
        } else if originLower.contains("germany") {
            coordinates = CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515)
        }
        
        return ChickenBreed(
            name: aiResult.breedName,
            imageURL: aiResult.imageURL ?? "https://images.unsplash.com/photo-1548550023-2bdb3c5beed7",
            description: aiResult.description,
            wikipediaLink: "https://en.wikipedia.org/wiki/\(aiResult.breedName.replacingOccurrences(of: " ", with: "_"))_chicken",
            habitat: "This breed adapts well to various environments and is suitable for backyard keeping.",
            origin: aiResult.origin,
            originCoordinates: coordinates,
            eggProduction: aiResult.eggProduction,
            temperament: aiResult.temperament,
            size: aiResult.size,
            purpose: aiResult.primaryUse,
            lifespan: aiResult.lifespan,
            colors: [aiResult.breedName]
        )
    }
    
    static var sampleData: [ChickenBreed] {
        [
            ChickenBreed(
                name: "Sussex",
                imageURL: "https://images.unsplash.com/photo-1548550023-2bdb3c5beed7",
                description: "The Sussex is a British breed of dual-purpose chicken, reared both for its meat and for its eggs. Eight colours are recognised for both standard-sized and bantam fowl. A breed association, the Sussex Breed Club, was organised in 1903.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Sussex_chicken",
                habitat: "The Sussex chicken thrives in a variety of environments, from rural farmlands to suburban backyards. It is well-suited to free-range conditions but can also be kept in confined spaces if necessary. The breed is adaptable to different climates, though it performs best in temperate conditions.",
                origin: "United Kingdom",
                originCoordinates: CLLocationCoordinate2D(latitude: 50.9097, longitude: -0.1276),
                eggProduction: "250-280 eggs per year",
                temperament: "Calm, friendly, curious",
                size: "Large (7-9 lbs)",
                purpose: "Dual-purpose (meat and eggs)",
                lifespan: "5-8 years",
                colors: ["Light", "Red", "Speckled", "Brown", "Buff", "Silver", "White", "Coronation"]
            ),
            ChickenBreed(
                name: "Rhode Island Red",
                imageURL: "https://i0.wp.com/valleyhatchery.com/wp-content/uploads/2021/11/Rhode-Island-Red-Chicks.webp",
                description: "Rhode Island Red chickens are an American breed developed in the late 19th century. They are renowned for their hardiness, excellent egg-laying abilities, and rich mahogany red feathers. These birds are dual-purpose, suitable for both egg and meat production.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Rhode_Island_Red",
                habitat: "Rhode Island Reds are extremely adaptable birds that thrive in various climates. They do well in both free-range and confined settings. These hardy chickens can tolerate cold winters and hot summers, making them ideal for backyard flocks across different regions.",
                origin: "United States (Rhode Island)",
                originCoordinates: CLLocationCoordinate2D(latitude: 41.5801, longitude: -71.4774),
                eggProduction: "200-300 eggs per year",
                temperament: "Hardy, docile, sometimes aggressive",
                size: "Large (6.5-8.5 lbs)",
                purpose: "Dual-purpose (meat and eggs)",
                lifespan: "5-8 years",
                colors: ["Deep red", "Mahogany"]
            ),
            ChickenBreed(
                name: "Leghorn",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSk_mG8DPfn_7qVAxz038iLzFbSPetd2bpGSA&s",
                description: "Leghorns are a Mediterranean breed originating from Italy. They are the world's most prolific egg layers, with some hens producing over 300 large white eggs per year. Despite their smaller size, they are incredibly feed-efficient.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Leghorn_chicken",
                habitat: "Leghorns prefer warm climates but can adapt to various conditions. They are excellent foragers and do best with plenty of space to roam. These active birds can fly well and may need higher fencing. They tolerate confinement but are happiest when free-ranging.",
                origin: "Italy (Tuscany)",
                originCoordinates: CLLocationCoordinate2D(latitude: 43.7711, longitude: 11.2486),
                eggProduction: "280-320 eggs per year",
                temperament: "Active, nervous, flighty",
                size: "Medium (4-6 lbs)",
                purpose: "Egg production",
                lifespan: "4-6 years",
                colors: ["White", "Brown", "Black", "Buff", "Silver"]
            ),
            ChickenBreed(
                name: "Silkie",
                imageURL: "https://images.unsplash.com/photo-1612170153139-6f881ff067e0",
                description: "Silkie chickens are an ancient breed from China, known for their incredibly soft, fluffy plumage that feels like silk or fur. They have black skin and bones, five toes, and distinctive turquoise earlobes. Silkies are beloved for their gentle nature.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Silkie",
                habitat: "Silkies adapt well to various climates but need protection from wet conditions as their fluffy feathers aren't waterproof. They do well in smaller spaces and are perfect for urban settings. These birds cannot fly and need lower perches. They thrive in covered runs.",
                origin: "China",
                originCoordinates: CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954),
                eggProduction: "100-120 eggs per year",
                temperament: "Docile, friendly, calm",
                size: "Small (2-3 lbs)",
                purpose: "Ornamental, brooding",
                lifespan: "7-9 years",
                colors: ["White", "Black", "Blue", "Splash", "Partridge", "Gray", "Buff"]
            ),
            ChickenBreed(
                name: "Plymouth Rock",
                imageURL: "https://cdn.shopify.com/s/files/1/1407/3744/articles/DSC_9544.jpg?v=1715880318",
                description: "Plymouth Rock chickens, especially the Barred variety, are an iconic American breed. Known for their distinctive black and white striped plumage, they are calm, friendly birds that make excellent backyard chickens for families.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Plymouth_Rock_chicken",
                habitat: "Plymouth Rocks are hardy birds that adapt to various climates and environments. They do well in cold weather due to their dense feathering. These chickens are content in confinement but enjoy free-ranging. They're perfect for small farms and backyard settings.",
                origin: "United States (Massachusetts)",
                originCoordinates: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
                eggProduction: "200-280 eggs per year",
                temperament: "Calm, friendly, easy-going",
                size: "Large (7.5-9.5 lbs)",
                purpose: "Dual-purpose (meat and eggs)",
                lifespan: "6-8 years",
                colors: ["Barred", "White", "Buff", "Silver Penciled", "Partridge", "Columbian", "Blue"]
            ),
            ChickenBreed(
                name: "Brahma",
                imageURL: "https://www.somerzby.com.au/wp-content/uploads/2019/04/Large-Black-and-White-Brahma-Pair.jpg",
                description: "Brahma chickens are gentle giants of the poultry world, with roosters reaching up to 18 pounds. Despite their imposing size, they are known for their calm temperament. These feather-footed beauties excel in cold climates.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Brahma_chicken",
                habitat: "Brahmas thrive in cold climates thanks to their dense feathering and small pea combs that resist frostbite. They need spacious coops due to their large size but don't require high fencing as they can't fly. These gentle giants do well in confinement and are perfect for northern regions.",
                origin: "United States (developed from Shanghai birds)",
                originCoordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                eggProduction: "150-200 eggs per year",
                temperament: "Gentle, calm, friendly",
                size: "Extra Large (10-18 lbs)",
                purpose: "Dual-purpose (meat and eggs)",
                lifespan: "5-8 years",
                colors: ["Light", "Dark", "Buff"]
            ),
            ChickenBreed(
                name: "Orpington",
                imageURL: "https://upload.wikimedia.org/wikipedia/commons/3/32/Buff_Orpington_chicken%2C_UK.jpg",
                description: "Orpingtons are large, friendly birds developed in England by William Cook in the 1880s. These fluffy, round chickens are known for their exceptional cold hardiness, calm disposition, and excellent mothering abilities. Their dense feathering makes them appear even larger than they are.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Orpington_chicken",
                habitat: "Orpingtons adapt well to confinement and free-range conditions. Their heavy feathering makes them excellent for cold climates but may struggle in extreme heat. They need sturdy coops due to their size and prefer lower roosts as they're poor fliers.",
                origin: "United Kingdom (Kent)",
                originCoordinates: CLLocationCoordinate2D(latitude: 51.2787, longitude: 0.5217),
                eggProduction: "200-280 eggs per year",
                temperament: "Gentle, docile, friendly",
                size: "Large (8-10 lbs)",
                purpose: "Dual-purpose (meat and eggs)",
                lifespan: "5-8 years",
                colors: ["Buff", "Black", "White", "Blue", "Lavender"]
            ),
            ChickenBreed(
                name: "Australorp",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK866KNEACe1viNkEnC4mFhN7Qp-chZaJxqw&s",
                description: "Australorps hold world records for egg production, with one hen laying 364 eggs in 365 days! Developed in Australia from Black Orpingtons, these glossy black birds with green-purple sheen are incredibly productive while maintaining a calm, friendly demeanor.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Australorp",
                habitat: "Australorps are highly adaptable, thriving in both hot and cold climates. They do well in confinement but love to forage when free-ranging. These quiet birds are perfect for urban and suburban settings with noise restrictions.",
                origin: "Australia",
                originCoordinates: CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751),
                eggProduction: "250-300 eggs per year",
                temperament: "Quiet, gentle, friendly",
                size: "Large (6.5-8.5 lbs)",
                purpose: "Dual-purpose (eggs primarily)",
                lifespan: "6-10 years",
                colors: ["Black", "Blue", "White"]
            ),
            ChickenBreed(
                name: "Wyandotte",
                imageURL: "https://images.unsplash.com/photo-1556316918-880f9e893822",
                description: "Wyandottes are stunning American birds known for their beautiful laced feather patterns and rose combs. Created in the 1870s, they're excellent dual-purpose birds that lay well through winter. Their rose combs make them particularly cold-hardy.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Wyandotte_chicken",
                habitat: "Wyandottes excel in cold climates thanks to their rose combs and dense feathering. They're good foragers but adapt well to confinement. These birds are known for being excellent winter layers when other breeds slow down.",
                origin: "United States (New York)",
                originCoordinates: CLLocationCoordinate2D(latitude: 43.0481, longitude: -76.1474),
                eggProduction: "180-260 eggs per year",
                temperament: "Calm, friendly, assertive",
                size: "Large (6-9 lbs)",
                purpose: "Dual-purpose (meat and eggs)",
                lifespan: "6-12 years",
                colors: ["Silver Laced", "Golden Laced", "Blue", "Black", "White", "Buff", "Partridge", "Columbian"]
            ),
            ChickenBreed(
                name: "Polish",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMdCUJuFqHRI-twL9T1lYhxoadWxuHBWyGvA&s",
                description: "Polish chickens are the comedians of the poultry world with their extraordinary feather crests that often cover their eyes! Despite their name, they likely originated in the Netherlands. These ornamental birds are gentle and make great pets.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Polish_chicken",
                habitat: "Polish chickens need special care due to their crests blocking vision. They do best in covered runs to protect their head feathers from rain. These birds startle easily and need calm environments with lower perches.",
                origin: "Netherlands/Poland",
                originCoordinates: CLLocationCoordinate2D(latitude: 52.1326, longitude: 5.2913),
                eggProduction: "150-200 eggs per year",
                temperament: "Gentle, flighty, quirky",
                size: "Medium (4.5-6 lbs)",
                purpose: "Ornamental and eggs",
                lifespan: "7-8 years",
                colors: ["White Crested Black", "Golden", "Silver", "Buff Laced", "White", "Black"]
            ),
            ChickenBreed(
                name: "Ameraucana",
                imageURL: "https://static.wixstatic.com/media/222cc3_b60ec4e4e95b44eea6390358f99d5422~mv2.jpg/v1/fill/w_568,h_378,al_c,q_80,usm_0.66_1.00_0.01,enc_avif,quality_auto/222cc3_b60ec4e4e95b44eea6390358f99d5422~mv2.jpg",
                description: "Ameraucanas are famous for laying beautiful blue eggs! Developed in the 1970s from Araucanas, they have distinctive muffs and beards. These hardy birds are excellent foragers and add colorful eggs to any basket.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Ameraucana",
                habitat: "Ameraucanas are extremely hardy, adapting to both hot and cold climates. They're active foragers who do best with room to roam but can tolerate confinement. Their pea combs resist frostbite in winter.",
                origin: "United States",
                originCoordinates: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                eggProduction: "200-250 eggs per year",
                temperament: "Friendly, curious, active",
                size: "Medium (5-7 lbs)",
                purpose: "Egg production (blue eggs)",
                lifespan: "7-10 years",
                colors: ["Black", "Blue", "Brown Red", "Buff", "Silver", "Wheaten", "White"]
            ),
            ChickenBreed(
                name: "Cochin",
                imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Partridge_Cochin_cockerel_%28cropped%29.jpg/1200px-Partridge_Cochin_cockerel_%28cropped%29.jpg",
                description: "Cochins are gentle giants with feathers covering even their feet! Imported from China in the 1840s, they sparked 'Hen Fever' in America and Europe. These massive, fluffy birds are more pets than production birds but make excellent mothers.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Cochin_chicken",
                habitat: "Cochins need spacious, dry coops due to their size and feathered feet. They're poor fliers and need low roosts. Their foot feathering requires dry conditions to prevent problems. They're extremely cold-hardy but struggle in heat.",
                origin: "China (Shanghai)",
                originCoordinates: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
                eggProduction: "150-180 eggs per year",
                temperament: "Calm, friendly, docile",
                size: "Giant (8.5-11 lbs)",
                purpose: "Ornamental and brooding",
                lifespan: "5-8 years",
                colors: ["Buff", "Partridge", "White", "Black", "Blue", "Golden Laced", "Silver Laced"]
            ),
            ChickenBreed(
                name: "Marans",
                imageURL: "https://cdn.shopify.com/s/files/1/1007/8326/files/Black-Copper-Marans-Hen.webp?v=1737263713",
                description: "Marans are French chickens famous for laying the darkest brown eggs of any breed - often described as chocolate-colored! Developed in the marshy areas of Marans, these birds are robust, active foragers with striking copper and black plumage.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Marans",
                habitat: "Marans thrive in free-range conditions and are excellent foragers. They adapt well to various climates but prefer moderate conditions. These active birds need space to roam and can be kept in wet conditions better than most breeds.",
                origin: "France (Marans)",
                originCoordinates: CLLocationCoordinate2D(latitude: 46.0833, longitude: -1.0833),
                eggProduction: "150-200 eggs per year",
                temperament: "Active, friendly, quiet",
                size: "Large (7-8 lbs)",
                purpose: "Dual-purpose (dark eggs)",
                lifespan: "6-8 years",
                colors: ["Black Copper", "Blue Copper", "Wheaten", "Black", "White", "Cuckoo"]
            ),
            ChickenBreed(
                name: "Barnevelder",
                imageURL: "https://www.chickencoopcompany.com/cdn/shop/files/Barnevelder_1.jpg?v=1724563615&width=800",
                description: "Barnevelders are Dutch chickens known for their beautiful double-laced feather pattern and dark brown eggs. These hardy birds were developed for egg production and continue laying well through winter months.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Barnevelder",
                habitat: "Barnevelders are cold-hardy birds that adapt well to confinement but enjoy foraging. They tolerate wet conditions better than many breeds and are excellent for temperate climates. These calm birds are perfect for backyard flocks.",
                origin: "Netherlands (Barneveld)",
                originCoordinates: CLLocationCoordinate2D(latitude: 52.1384, longitude: 5.5869),
                eggProduction: "180-200 eggs per year",
                temperament: "Calm, friendly, active",
                size: "Large (6-7 lbs)",
                purpose: "Egg production (brown eggs)",
                lifespan: "4-7 years",
                colors: ["Double Laced", "Black", "White", "Blue Double Laced", "Partridge"]
            ),
            ChickenBreed(
                name: "Hamburg",
                imageURL: "https://livestockconservancy.org/wp-content/uploads/2022/08/Hamburgs.jpg",
                description: "Hamburgs are alert, active chickens nicknamed 'everyday layers' for their prolific egg production. Despite their name, they originated in Holland. These elegant birds with rose combs are excellent fliers and love to roost in trees.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Hamburg_chicken",
                habitat: "Hamburgs need space to roam and high fencing as they fly well. They prefer free-range conditions and often roost in trees if allowed. These hardy birds tolerate cold well but are too active for close confinement.",
                origin: "Netherlands/Germany",
                originCoordinates: CLLocationCoordinate2D(latitude: 53.5511, longitude: 9.9937),
                eggProduction: "200-250 eggs per year",
                temperament: "Active, flighty, alert",
                size: "Small (4-5 lbs)",
                purpose: "Egg production",
                lifespan: "8-10 years",
                colors: ["Silver Spangled", "Golden Spangled", "Golden Penciled", "Silver Penciled", "Black", "White"]
            ),
            ChickenBreed(
                name: "Faverolles",
                imageURL: "https://cdn.shopify.com/s/files/1/0039/4647/9689/files/faverolle-hen-and-chicks.jpg",
                description: "Faverolles are French chickens with distinctive fluffy beards, muffs, and five toes! The Salmon variety has stunning coloring. These gentle giants are excellent winter layers and make wonderful family pets with their docile, comical personalities.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Faverolles_chicken",
                habitat: "Faverolles adapt well to confinement and are perfect for small spaces. Their feathered feet require dry conditions. These calm birds are cold-hardy but need shade in summer. They're poor fliers and need low perches.",
                origin: "France (Faverolles)",
                originCoordinates: CLLocationCoordinate2D(latitude: 48.3833, longitude: 3.0167),
                eggProduction: "180-240 eggs per year",
                temperament: "Docile, gentle, curious",
                size: "Large (6.5-8 lbs)",
                purpose: "Dual-purpose",
                lifespan: "5-7 years",
                colors: ["Salmon", "White", "Black", "Blue", "Buff", "Cuckoo"]
            ),
            ChickenBreed(
                name: "Campine",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnd5TjQosIrqIsvgxHnwDDgakFJTWbu3vmTA&s",
                description: "Campines are ancient Belgian chickens with striking penciled plumage. These active, alert birds are excellent foragers and lay white eggs consistently. They're known for their intelligence and independence.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Campine_chicken",
                habitat: "Campines need plenty of space to forage and fly. They don't tolerate confinement well and prefer free-range conditions. These hardy birds adapt to various climates but need secure fencing as they're excellent fliers.",
                origin: "Belgium (Campine region)",
                originCoordinates: CLLocationCoordinate2D(latitude: 51.3167, longitude: 5.0333),
                eggProduction: "150-200 eggs per year",
                temperament: "Active, independent, flighty",
                size: "Small (4-6 lbs)",
                purpose: "Egg production",
                lifespan: "7-10 years",
                colors: ["Silver", "Golden"]
            ),
            ChickenBreed(
                name: "Minorca",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdALCpgJKk0BYMmhm65xLSUfXE1tvXuFPrLQ&s",
                description: "Minorcas are Mediterranean chickens with enormous white earlobes and impressive large white eggs. These elegant black birds with glossy green sheen are heat-tolerant and active. Roosters have spectacular large single combs.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Minorca_chicken",
                habitat: "Minorcas thrive in warm climates but need protection from frostbite on their large combs in winter. They're excellent foragers who prefer free-range but tolerate confinement. These active birds need high roosts as they fly well.",
                origin: "Spain (Menorca)",
                originCoordinates: CLLocationCoordinate2D(latitude: 39.9496, longitude: 4.1104),
                eggProduction: "200-280 eggs per year",
                temperament: "Active, alert, friendly",
                size: "Large (7.5-9 lbs)",
                purpose: "Egg production (large eggs)",
                lifespan: "5-8 years",
                colors: ["Black", "White", "Blue"]
            ),
            ChickenBreed(
                name: "Jersey Giant",
                imageURL: "https://upload.wikimedia.org/wikipedia/commons/7/7f/OntarioCountyFair2018JerseyGiantCockerel.jpg",
                description: "Jersey Giants are the world's largest chicken breed, with roosters reaching 15 pounds! Developed in New Jersey to replace turkeys, these gentle giants take 6-8 months to mature. Despite their size, they're calm and friendly.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Jersey_Giant",
                habitat: "Jersey Giants need extra-large coops with sturdy, low roosts due to their weight. They tolerate cold well but need shade in summer. These calm birds do well in confinement but enjoy foraging. Strong fencing is needed as they're heavy.",
                origin: "United States (New Jersey)",
                originCoordinates: CLLocationCoordinate2D(latitude: 40.0583, longitude: -74.4057),
                eggProduction: "150-200 eggs per year",
                temperament: "Gentle, calm, docile",
                size: "Giant (11-15 lbs)",
                purpose: "Meat production primarily",
                lifespan: "6-10 years",
                colors: ["Black", "White", "Blue"]
            ),
            ChickenBreed(
                name: "Andalusian",
                imageURL: "https://cluckin.net/media/posts/59/Blue-Andalusian-Chicken-header-image.jpg",
                description: "Andalusians are stunning Spanish chickens with unique blue plumage created by a dilution gene. These active, hardy birds are excellent layers of large white eggs. They're known for being noisy but productive.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Andalusian_chicken",
                habitat: "Andalusians thrive in warm climates and are heat-tolerant. They're active foragers who need space and don't do well in confinement. These excellent fliers need tall fencing and prefer to roost high.",
                origin: "Spain (Andalusia)",
                originCoordinates: CLLocationCoordinate2D(latitude: 37.5443, longitude: -4.7278),
                eggProduction: "160-200 eggs per year",
                temperament: "Active, noisy, independent",
                size: "Medium (5-7 lbs)",
                purpose: "Egg production",
                lifespan: "5-8 years",
                colors: ["Blue", "Black", "Splash"]
            ),
            ChickenBreed(
                name: "Welsummer",
                imageURL: "https://img.hobbyfarms.com/wp-content/uploads/2011/02/12132754/welsummer-SarahIvy-flickr.jpg",
                description: "Welsummers are Dutch chickens famous for laying beautiful terracotta-colored eggs with dark speckles. The Kellogg's Corn Flakes rooster is modeled after a Welsummer! These intelligent birds are excellent foragers.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Welsummer",
                habitat: "Welsummers are hardy birds that adapt to various climates. They're excellent free-range chickens but tolerate confinement. These intelligent birds are good at avoiding predators and prefer having space to forage.",
                origin: "Netherlands (Welsum)",
                originCoordinates: CLLocationCoordinate2D(latitude: 52.3333, longitude: 6.0833),
                eggProduction: "160-250 eggs per year",
                temperament: "Friendly, intelligent, active",
                size: "Medium (6-7 lbs)",
                purpose: "Dual-purpose (dark eggs)",
                lifespan: "6-9 years",
                colors: ["Red Partridge", "Silver Duckwing", "Gold Duckwing"]
            ),
            ChickenBreed(
                name: "Serama",
                imageURL: "https://img.hobbyfarms.com/serama.jpg",
                description: "Seramas are the world's smallest chicken breed, with some weighing less than a pound! These Malaysian bantams have upright posture, puffed chests, and vertical tail feathers. Despite their size, they're confident and friendly.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Serama",
                habitat: "Seramas need protection from cold and wet weather due to their small size. They're perfect for indoor keeping or small urban spaces. These tiny birds can't defend themselves from predators and need secure housing.",
                origin: "Malaysia",
                originCoordinates: CLLocationCoordinate2D(latitude: 4.2105, longitude: 101.9758),
                eggProduction: "100-180 eggs per year",
                temperament: "Friendly, confident, personable",
                size: "Bantam (0.5-1.5 lbs)",
                purpose: "Ornamental and pets",
                lifespan: "5-7 years",
                colors: ["White", "Black", "Blue", "Wheaten", "Mille Fleur", "Various"]
            ),
            ChickenBreed(
                name: "Araucana",
                imageURL: "https://homesteadontherange.com/wp-content/uploads/2021/04/e2c4e-araucana2-resized.jpg",
                description: "Araucanas are the original blue egg layers from Chile, known for their unique rumpless (tailless) appearance and ear tufts. These rare birds are the ancestors of Ameraucanas and Easter Eggers. They're hardy and active foragers.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Araucana",
                habitat: "Araucanas are extremely hardy and adapt to various climates. They're excellent foragers who prefer free-range conditions. Being rumpless affects their balance, so they need lower perches. These active birds are good at predator evasion.",
                origin: "Chile",
                originCoordinates: CLLocationCoordinate2D(latitude: -35.6751, longitude: -71.5430),
                eggProduction: "150-180 eggs per year",
                temperament: "Active, friendly, alert",
                size: "Medium (5-7 lbs)",
                purpose: "Egg production (blue eggs)",
                lifespan: "6-8 years",
                colors: ["Black", "Black Red", "Golden Duckwing", "Silver Duckwing", "White"]
            ),
            ChickenBreed(
                name: "Speckled Sussex",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTM8Q6PxOWi1a90gJ5J5ZSHZRSE5wg6w4GpHw&s",
                description: "Speckled Sussex are beautiful British birds with mahogany feathers tipped in white, creating a speckled appearance that gets more pronounced with each molt. These curious, friendly chickens are excellent foragers and cold-hardy.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Sussex_chicken",
                habitat: "Speckled Sussex thrive in free-range environments where their camouflage coloring helps protect them. They're cold-hardy and adapt well to confinement. These docile birds are perfect for families and mix well with other breeds.",
                origin: "United Kingdom (Sussex)",
                originCoordinates: CLLocationCoordinate2D(latitude: 50.8650, longitude: -0.0885),
                eggProduction: "200-250 eggs per year",
                temperament: "Curious, friendly, docile",
                size: "Large (7-8 lbs)",
                purpose: "Dual-purpose",
                lifespan: "5-8 years",
                colors: ["Speckled (mahogany with white tips)"]
            ),
            ChickenBreed(
                name: "Buckeye",
                imageURL: "https://www.cacklehatchery.com/wp-content/uploads/2015/01/Buckeye-Hen-Cackle-1.jpg",
                description: "Buckeyes are the only American breed developed entirely by a woman (Nettie Metcalf). These deep red chickens from Ohio are extremely cold-hardy with pea combs. They're known for their friendly disposition and mouse-hunting abilities!",
                wikipediaLink: "https://en.wikipedia.org/wiki/Buckeye_chicken",
                habitat: "Buckeyes excel in cold climates with their pea combs and dense feathering. They're active foragers who thrive in free-range settings. These adaptable birds tolerate confinement but prefer space to hunt and forage.",
                origin: "United States (Ohio)",
                originCoordinates: CLLocationCoordinate2D(latitude: 40.4173, longitude: -82.9071),
                eggProduction: "180-260 eggs per year",
                temperament: "Friendly, active, curious",
                size: "Large (6.5-9 lbs)",
                purpose: "Dual-purpose",
                lifespan: "5-8 years",
                colors: ["Deep mahogany red"]
            ),
            ChickenBreed(
                name: "Langshan",
                imageURL: "https://livestockconservancy.org/wp-content/uploads/2022/08/langshan-pullet.jpg",
                description: "Langshans are tall, elegant Chinese chickens with distinctive long legs and deep bodies. These ancient birds have soft, close-fitting plumage and lay eggs with a unique plum bloom. They're gentle giants with excellent flying abilities despite their size.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Langshan_chicken",
                habitat: "Langshans adapt well to various climates and are particularly cold-hardy. Despite their size, they fly well and need tall fencing. These calm birds do well in confinement but enjoy foraging. They need spacious coops due to their height.",
                origin: "China (Langshan district)",
                originCoordinates: CLLocationCoordinate2D(latitude: 32.0617, longitude: 120.8658),
                eggProduction: "150-200 eggs per year",
                temperament: "Gentle, calm, intelligent",
                size: "Large (7-10 lbs)",
                purpose: "Dual-purpose",
                lifespan: "6-8 years",
                colors: ["Black", "White", "Blue"]
            ),
            ChickenBreed(
                name: "Cream Legbar",
                imageURL: "https://images.squarespace-cdn.com/content/v1/56c89f3c22482e3c93f7d3cb/1641409983679-MQHCCGF20WXFEF045736/CAR_1656.jpg",
                description: "Cream Legbars are British auto-sexing chickens that lay beautiful sky-blue eggs! Developed at Cambridge University, chicks can be sexed at hatching by their markings. These crested birds are active, friendly, and excellent foragers.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Cream_Legbar",
                habitat: "Cream Legbars are hardy birds that adapt to various climates. They're excellent foragers who prefer free-range but tolerate confinement. These active birds fly well and need secure fencing. They're perfect for those wanting blue eggs.",
                origin: "United Kingdom (Cambridge)",
                originCoordinates: CLLocationCoordinate2D(latitude: 52.2053, longitude: 0.1218),
                eggProduction: "180-200 eggs per year",
                temperament: "Active, friendly, curious",
                size: "Medium (5.5-7.5 lbs)",
                purpose: "Egg production (blue eggs)",
                lifespan: "5-7 years",
                colors: ["Cream with gray barring"]
            ),
            ChickenBreed(
                name: "Dominique",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNIYSlfD9MiXCTNHCzi0ZoYQenRG2tml-XCQ&s",
                description: "Dominiques are America's oldest chicken breed, dating to colonial times. These barred birds were nearly extinct but have made a comeback. They're excellent foragers, cold-hardy, and known for their calm temperament and hawk-like barring pattern.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Dominique_chicken",
                habitat: "Dominiques are incredibly hardy and thrive in harsh conditions. They're excellent free-range birds but adapt to confinement. Their rose combs make them frost-resistant. These resourceful birds are perfect for sustainable farming.",
                origin: "United States (Colonial America)",
                originCoordinates: CLLocationCoordinate2D(latitude: 38.5616, longitude: -77.4501),
                eggProduction: "230-275 eggs per year",
                temperament: "Calm, gentle, reliable",
                size: "Medium (5-7 lbs)",
                purpose: "Dual-purpose",
                lifespan: "6-8 years",
                colors: ["Barred (black and white)"]
            ),
            ChickenBreed(
                name: "Egyptian Fayoumi",
                imageURL: "https://pictureanimal.com/wiki-image/1080/387828133726519296.jpeg",
                description: "Fayoumis are ancient Egyptian chickens that have been raised along the Nile for thousands of years. These silver-penciled birds are incredibly disease-resistant, heat-tolerant, and mature quickly. They're wild-acting but efficient foragers.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Fayoumi",
                habitat: "Fayoumis excel in hot, dry climates and are extremely heat-tolerant. They're independent foragers who need space and don't do well in confinement. These flighty birds roost in trees and need tall fencing. They're very predator-aware.",
                origin: "Egypt (Fayoum)",
                originCoordinates: CLLocationCoordinate2D(latitude: 29.3084, longitude: 30.8428),
                eggProduction: "150-220 eggs per year",
                temperament: "Active, flighty, independent",
                size: "Small (3.5-4.5 lbs)",
                purpose: "Egg production",
                lifespan: "5-7 years",
                colors: ["Silver Penciled"]
            ),
            ChickenBreed(
                name: "La Fleche",
                imageURL: "https://upload.wikimedia.org/wikipedia/commons/0/09/Poule_de_La_Flèche_%28cropped%29.jpg",
                description: "La Fleche are rare French chickens known as 'Devil Birds' due to their distinctive V-shaped combs that look like horns! These black birds with metallic green sheen are excellent layers and were once considered the finest table fowl in France.",
                wikipediaLink: "https://en.wikipedia.org/wiki/La_Fleche_chicken",
                habitat: "La Fleche chickens prefer moderate climates and need protection from extreme cold due to their unique combs. They're active foragers who don't tolerate confinement well. These excellent fliers need very tall fencing or covered runs.",
                origin: "France (La Fleche)",
                originCoordinates: CLLocationCoordinate2D(latitude: 47.6981, longitude: -0.0761),
                eggProduction: "150-200 eggs per year",
                temperament: "Active, wild, aloof",
                size: "Large (6.5-8 lbs)",
                purpose: "Dual-purpose (gourmet meat)",
                lifespan: "6-8 years",
                colors: ["Black with green sheen"]
            ),
            ChickenBreed(
                name: "Houdan",
                imageURL: "https://www.mcmurrayhatchery.com/images/global/mc/McMurrayHatchery-Mottled-Houdan.jpg",
                description: "Houdans are ornamental French chickens with spectacular crests, beards, muffs, and five toes! Dating to the 1200s, these mottled birds were once France's premier meat bird. Their crests often need trimming to help them see.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Houdan_chicken",
                habitat: "Houdans need special care due to their vision-blocking crests. They do best in covered, predator-proof runs. These docile birds tolerate confinement well but enjoy foraging. Their foot feathering requires dry conditions.",
                origin: "France (Houdan)",
                originCoordinates: CLLocationCoordinate2D(latitude: 48.7906, longitude: 1.6005),
                eggProduction: "150-230 eggs per year",
                temperament: "Docile, sweet, gentle",
                size: "Large (6-8 lbs)",
                purpose: "Dual-purpose and ornamental",
                lifespan: "7-8 years",
                colors: ["Mottled (black and white)", "White", "Black"]
            ),
            ChickenBreed(
                name: "Yokohama",
                imageURL: "https://livestockconservancy.org/wp-content/uploads/2022/08/red-shouldered-yokohama-cockerel-2.jpg",
                description: "Yokohamas are ornamental Japanese chickens famous for their extraordinarily long tail feathers that can grow several feet long! These elegant birds have walnut combs and pheasant-like appearance. They require special housing to protect their tails.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Yokohama_chicken",
                habitat: "Yokohamas need specialized housing with high perches and clean conditions to protect their long tails. They're active foragers but need protection from wet, muddy conditions. These birds do best in dry climates with spacious aviaries.",
                origin: "Japan (developed in Germany)",
                originCoordinates: CLLocationCoordinate2D(latitude: 35.4437, longitude: 139.6380),
                eggProduction: "80-100 eggs per year",
                temperament: "Active, gentle, ornamental",
                size: "Small (4-5.5 lbs)",
                purpose: "Ornamental exhibition",
                lifespan: "5-7 years",
                colors: ["Red Saddled", "White", "Black-Red", "Silver Duckwing"]
            ),
            ChickenBreed(
                name: "Buff Brahma",
                imageURL: "https://www.mypetchicken.com/cdn/shop/products/buff-brahma-chicken2-mpc.jpg?v=1735939732&width=1946",
                description: "Buff Brahmas are a color variety of the gentle giant Brahma breed. These massive, docile birds have beautiful buff-colored plumage with darker hackles and tail feathers. Their feathered feet and calm nature make them excellent pets.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Brahma_chicken",
                habitat: "Buff Brahmas excel in cold climates with their heavy feathering and pea combs. They need spacious coops due to their large size but are content in confinement. These gentle birds are perfect for families with children.",
                origin: "United States",
                originCoordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                eggProduction: "150-200 eggs per year",
                temperament: "Extremely gentle, calm, friendly",
                size: "Extra Large (10-12 lbs)",
                purpose: "Dual-purpose and pets",
                lifespan: "5-8 years",
                colors: ["Buff with darker accents"]
            ),
            ChickenBreed(
                name: "Olive Egger",
                imageURL: "https://images.north40.com/images/1999397/BA_olive_egger__1999397__.jpg?width=900&format=pjpg",
                description: "Olive Eggers are hybrid chickens bred specifically to lay olive-colored eggs. Created by crossing blue egg layers with dark brown egg layers, these birds produce eggs in various shades of olive green, making them highly sought after.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Easter_Egger",
                habitat: "Olive Eggers are hardy hybrids that adapt to various climates. They're active foragers who do well in free-range settings but tolerate confinement. These friendly birds are perfect for colorful egg baskets.",
                origin: "United States (Hybrid)",
                originCoordinates: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
                eggProduction: "180-250 eggs per year",
                temperament: "Friendly, active, curious",
                size: "Medium (5-7 lbs)",
                purpose: "Egg production (olive eggs)",
                lifespan: "5-8 years",
                colors: ["Various mixed patterns"]
            ),
            ChickenBreed(
                name: "Black Copper Marans",
                imageURL: "https://i0.wp.com/sunbirdfarms.com/wp-content/uploads/2016/01/DSC04045.jpg?fit=4592%2C2576&ssl=1",
                description: "Black Copper Marans are the most prized variety of Marans, known for laying the darkest chocolate-brown eggs. These French birds have glossy black plumage with striking copper hackles on roosters, making them both beautiful and productive.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Marans",
                habitat: "Black Copper Marans are hardy birds that thrive in free-range conditions. They tolerate wet weather better than most breeds and are excellent foragers. These active birds prefer space but adapt to confinement.",
                origin: "France",
                originCoordinates: CLLocationCoordinate2D(latitude: 46.0833, longitude: -1.0833),
                eggProduction: "150-200 eggs per year",
                temperament: "Active, friendly, alert",
                size: "Large (7-8 lbs)",
                purpose: "Dual-purpose (dark eggs)",
                lifespan: "6-8 years",
                colors: ["Black with copper neck"]
            ),
            ChickenBreed(
                name: "Sapphire Gem",
                imageURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXzJTea9AH76suNNOzdySpzWFETOOpKCIatQ&s",
                description: "Sapphire Gems are sex-linked hybrid chickens that are excellent egg layers. These blue-gray birds can be sexed at hatching, with males being lighter than females. They're known for consistent production of large brown eggs.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Sex_link",
                habitat: "Sapphire Gems are adaptable hybrids that thrive in various climates. They're excellent foragers but do well in confinement. These hardy birds are perfect for beginners wanting reliable egg production.",
                origin: "Czech Republic (Hybrid)",
                originCoordinates: CLLocationCoordinate2D(latitude: 49.7500, longitude: 15.5000),
                eggProduction: "280-300 eggs per year",
                temperament: "Calm, friendly, easy-going",
                size: "Medium (5-6 lbs)",
                purpose: "Egg production",
                lifespan: "4-6 years",
                colors: ["Blue-gray, lavender"]
            ),
            ChickenBreed(
                name: "Ayam Cemani",
                imageURL: "https://www.backyardchickens.com/articles/ayam-cemani-facts-you-didnt-know.72991/cover-image",
                description: "Ayam Cemani are the world's most unique chickens, completely black inside and out - including organs, bones, and meat! These rare Indonesian birds are considered mystical in their homeland and are among the most expensive chickens globally.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Ayam_Cemani",
                habitat: "Ayam Cemani prefer warm climates but adapt to various conditions with proper shelter. They're active foragers who need space to roam. These exotic birds require secure housing as they're valuable and attract attention.",
                origin: "Indonesia (Java)",
                originCoordinates: CLLocationCoordinate2D(latitude: -7.6145, longitude: 110.7122),
                eggProduction: "80-120 eggs per year",
                temperament: "Active, alert, intelligent",
                size: "Medium (4-6 lbs)",
                purpose: "Ornamental and meat",
                lifespan: "6-8 years",
                colors: ["Solid black (hyperpigmentation)"]
            ),
            ChickenBreed(
                name: "Bielefelder",
                imageURL: "https://i0.wp.com/www.happywifeacres.com/wp-content/uploads/2021/05/word-image-1.jpeg?resize=740%2C497&ssl=1",
                description: "Bielefelders are auto-sexing German chickens that combine beauty, size, and productivity. Chicks can be sexed at hatching by their markings. These gentle giants lay large brown eggs and have stunning crele plumage patterns.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Bielefelder_chicken",
                habitat: "Bielefelders are cold-hardy birds that excel in free-range settings. They're calm enough for confinement but prefer foraging. These docile giants are perfect for families wanting friendly, productive chickens.",
                origin: "Germany (Bielefeld)",
                originCoordinates: CLLocationCoordinate2D(latitude: 52.0306, longitude: 8.5324),
                eggProduction: "200-280 eggs per year",
                temperament: "Gentle, calm, friendly",
                size: "Large (8-10 lbs)",
                purpose: "Dual-purpose",
                lifespan: "6-10 years",
                colors: ["Crele (barred red-brown)"]
            ),
            ChickenBreed(
                name: "Swedish Flower Hen",
                imageURL: "https://thepasturefarms.com/wp-content/uploads/2020/09/Swedish-Flower-Hen-Pullets-scaled.jpg",
                description: "Swedish Flower Hens (Skånsk blommehöna) are Sweden's landrace chickens with no two birds looking alike! Each has unique 'flower' patterns. Nearly extinct in the 1970s, these hardy birds are now treasured for their beauty and personality.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Swedish_Flower_chicken",
                habitat: "Swedish Flower Hens are extremely cold-hardy, developed to survive Scandinavian winters. They're excellent foragers who thrive in free-range settings. These independent birds are perfect for harsh climates.",
                origin: "Sweden (Skåne)",
                originCoordinates: CLLocationCoordinate2D(latitude: 55.9904, longitude: 13.5958),
                eggProduction: "150-200 eggs per year",
                temperament: "Friendly, independent, hardy",
                size: "Medium (5-7 lbs)",
                purpose: "Dual-purpose",
                lifespan: "6-10 years",
                colors: ["Unique patterns - no two alike"]
            ),
            ChickenBreed(
                name: "Lavender Orpington",
                imageURL: "https://images.squarespace-cdn.com/content/v1/627d40aafe1d5273d74d7fee/df9398e3-7e39-4b15-afc5-72dee959dfae/Lavender+Chicken+Blog-7.png",
                description: "Lavender Orpingtons are a rare color variety with beautiful silvery-lavender plumage. These fluffy, gentle giants maintain all the wonderful Orpington qualities while sporting this unique self-blue coloring that breeds true.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Orpington_chicken",
                habitat: "Lavender Orpingtons excel in cold climates with their dense feathering. They're content in confinement but enjoy foraging. These docile birds are perfect for families and do well in small spaces.",
                origin: "United Kingdom",
                originCoordinates: CLLocationCoordinate2D(latitude: 51.2787, longitude: 0.5217),
                eggProduction: "175-200 eggs per year",
                temperament: "Very gentle, calm, friendly",
                size: "Large (8-10 lbs)",
                purpose: "Dual-purpose and pets",
                lifespan: "5-8 years",
                colors: ["Lavender (self-blue)"]
            ),
            ChickenBreed(
                name: "Icelandic",
                imageURL: "https://themodernhomestead.us/wp-content/uploads/2021/09/icelandics-in-snow-LR.jpg",
                description: "Icelandic chickens are ancient Viking birds brought to Iceland 1,000 years ago. These hardy landrace chickens have survived centuries in harsh conditions, developing incredible foraging abilities and cold resistance.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Icelandic_chicken",
                habitat: "Icelandic chickens are the hardiest breed, thriving in extreme cold and harsh conditions. They're exceptional foragers who need minimal supplemental feed. These independent birds prefer free-range and can be semi-feral.",
                origin: "Iceland",
                originCoordinates: CLLocationCoordinate2D(latitude: 64.9631, longitude: -19.0208),
                eggProduction: "180-250 eggs per year",
                temperament: "Independent, alert, hardy",
                size: "Small to Medium (3-5.5 lbs)",
                purpose: "Dual-purpose",
                lifespan: "7-12 years",
                colors: ["Varied - all colors possible"]
            ),
            ChickenBreed(
                name: "Dong Tao",
                imageURL: "https://www.horizonstructures.com/wp-content/uploads/2022/09/dong-tao-chicken-red-1024x801.jpg",
                description: "Dong Tao chickens from Vietnam are famous for their massive dragon-like legs that can be as thick as a human wrist! Once reserved for royalty, these rare birds are prized for their meat and can cost thousands of dollars.",
                wikipediaLink: "https://en.wikipedia.org/wiki/Dong_Tao_chicken",
                habitat: "Dong Tao chickens need special housing accommodations for their large feet. They require soft bedding and low perches. These tropical birds need protection from cold and their valuable legs need careful monitoring.",
                origin: "Vietnam (Dong Tao)",
                originCoordinates: CLLocationCoordinate2D(latitude: 20.9804, longitude: 105.8847),
                eggProduction: "60-80 eggs per year",
                temperament: "Calm, docile, slow-moving",
                size: "Giant (10-15 lbs)",
                purpose: "Meat (delicacy)",
                lifespan: "5-6 years",
                colors: ["Red, white, mixed"]
            )
        ]
    }
}
