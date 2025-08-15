import Foundation

class Article: Identifiable, Codable, ObservableObject, Hashable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    @Published var imageURL: String
    @Published var title: String
    @Published var textContent: String
    @Published var date: Date
    @Published var timeToRead: Int
    
    init(
        id: UUID = UUID(),
        imageURL: String,
        title: String,
        textContent: String,
        date: Date = Date(),
        timeToRead: Int
    ) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.textContent = textContent
        self.date = date
        self.timeToRead = timeToRead
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURL
        case title
        case textContent
        case date
        case timeToRead
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        title = try container.decode(String.self, forKey: .title)
        textContent = try container.decode(String.self, forKey: .textContent)
        date = try container.decode(Date.self, forKey: .date)
        timeToRead = try container.decode(Int.self, forKey: .timeToRead)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(title, forKey: .title)
        try container.encode(textContent, forKey: .textContent)
        try container.encode(date, forKey: .date)
        try container.encode(timeToRead, forKey: .timeToRead)
    }
}

extension Article {
    static var sampleData: [Article] {
        [
            Article(
                imageURL: "https://images.unsplash.com/photo-1548550023-2bdb3c5beed7",
                title: "The Fascinating World of Rare Black Chickens",
                textContent: "The Ayam Cemani is one of the most extraordinary chicken breeds in the world - a breed that is completely black inside and out. Native to Indonesia, these mystical birds have jet black feathers, skin, bones, and even internal organs due to a genetic condition called fibromelanosis. In Indonesia, they were historically thought to have mystical properties and were often raised exclusively for royalty. Their black meat is considered a delicacy, and a single bird can cost up to $2,500 in the United States. Despite their exotic appearance, Ayam Cemani chickens are surprisingly hardy and friendly, making them excellent additions to backyard flocks for those seeking something truly unique.",
                timeToRead: 5
            ),
            Article(
                imageURL: "https://images.unsplash.com/photo-1612170153139-6f881ff067e0",
                title: "Silkie Chickens: The Ultimate Family Pet",
                textContent: "Silkie chickens are among the most beloved poultry breeds, known for their incredibly soft, fluffy feathers that feel more like silk or fur than traditional feathers. These unique birds have five toes instead of four, black skin and bones, and distinctive turquoise earlobes. Originating from ancient China, Silkies have captured hearts worldwide with their gentle, docile nature that makes them perfect for families with children. They're often described as the 'lap dogs' of the chicken world. While they only lay about 100-120 small cream-colored eggs per year, Silkies excel as mothers - they'll happily hatch and raise any eggs placed under them, even duck or goose eggs! Their broody nature is so strong that many breeders keep Silkies specifically as incubators for other breeds.",
                timeToRead: 6
            ),
            Article(
                imageURL: "https://images.unsplash.com/photo-1569466896818-335b1bedfcce",
                title: "Easter Eggers: Nature's Rainbow Egg Layers",
                textContent: "Easter Egger chickens bring excitement to any egg basket with their colorful array of eggs in shades of blue, green, pink, and olive. These hybrid chickens result from crossing blue egg-laying breeds like Ameraucanas or Araucanas with brown egg layers. Each Easter Egger hen lays eggs of only one color throughout her life, but that color is unique to each bird - you won't know what color eggs you'll get until she starts laying! They can produce over 200 eggs per year and are incredibly hardy, adapting well to both hot and cold climates. Easter Eggers sport adorable poofy cheeks and beards, come in an infinite variety of feather colors, and have sweet, friendly personalities. They're perfect for families wanting a productive, colorful, and personable addition to their flock.",
                timeToRead: 5
            ),
            Article(
                imageURL: "https://www.chartleychucks.co.uk/cdn/shop/files/large-brahma-gold-gentle-giants-6750206_grande.jpg?v=1753458381",
                title: "Brahma Chickens: The Gentle Giants",
                textContent: "Brahma chickens are truly the gentle giants of the poultry world, with roosters reaching up to 18 pounds and standing nearly 30 inches tall. Despite their imposing size, Brahmas are known for their incredibly calm and friendly temperament, earning them the nickname 'gentle giants.' These feather-footed beauties excel in cold climates thanks to their dense feathering and small pea combs that resist frostbite. What makes Brahmas particularly special is their unique laying pattern - while most chickens slow production in winter, Brahmas lay the majority of their eggs from October through May, keeping egg cartons full when other breeds stop. Originally developed in America from birds imported from China, Brahmas were once so popular they were called the 'King of All Poultry.' Their docile nature and inability to fly make them perfect for families with children and small backyards.",
                timeToRead: 5
            ),
            Article(
                imageURL: "https://s.yimg.com/ny/api/res/1.2/xAnMnAI7CLPs_wQZvNf_Ug--/YXBwaWQ9aGlnaGxhbmRlcjt3PTY0MDtoPTM4NA--/https://media.zenfs.com/en/a_z_animals_articles_974/bb188401e263e53fe70bf8fad2e92114",
                title: "The Record-Breaking Leghorn Legacy",
                textContent: "Leghorn chickens hold the crown as the world's most prolific egg layers, with some hens producing over 300 large white eggs per year. The breed's egg-laying prowess is so remarkable that a Leghorn hen once held the world record by laying 371 eggs in 364 days! Originating from Italy and refined in America, these active, intelligent birds have become the foundation of commercial egg production worldwide. The Isabella Leghorn, a rare variety, is particularly prized for laying up to 300 eggs annually while sporting beautiful cream and brown feathers. Despite their smaller size, Leghorns are incredibly feed-efficient, converting food to eggs better than almost any other breed. They're excellent foragers and can be quite independent, though their active nature means they need plenty of space to roam. Fun fact: the famous cartoon character Foghorn Leghorn was inspired by this breed!",
                timeToRead: 4
            ),
            Article(
                imageURL: "https://a-z-animals.com/media/2023/09/shutterstock-2117203517-huge-licensed-scaled-1024x683.jpg",
                title: "Naked Neck Chickens: Nature's Oddball",
                textContent: "At first glance, Naked Neck chickens (also called Turkens) might make you do a double-take - these unusual birds appear to be half chicken, half turkey! Native to Transylvania, these chickens have a genetic mutation that causes them to have 40% fewer feathers than regular chickens, with completely bare necks that often turn bright red in the sun. Despite persistent myths, they are NOT a chicken-turkey hybrid (which is genetically impossible). Their reduced feathering actually gives them surprising advantages: they tolerate heat better than fully-feathered breeds, require less protein in their diet since they don't need to grow as many feathers, and are easier to pluck for meat production. Naked Necks are excellent dual-purpose birds, laying about 180 light brown eggs per year and producing tender, flavorful meat. Their unique appearance often makes them conversation starters in any backyard flock!",
                timeToRead: 4
            ),
            Article(
                id: UUID(),
                imageURL: "https://smartchickendoor.b-cdn.net/wp-content/uploads/Blog/Chicken-Coop-Essentials/chicken-run-3-1400x933.jpg",
                title: "Essential Coop Requirements for Happy Chickens",
                textContent: "A well-designed chicken coop is crucial for maintaining healthy, productive birds. Each hen needs 3-4 square feet of floor space inside the coop, while the outdoor run should provide at least 10 square feet per bird. Proper ventilation is essential - install vents near the roof to allow moisture and ammonia to escape while preventing drafts at roost level. Your coop should include one nesting box for every 3-4 hens, positioned lower than the roosts to discourage sleeping in them. Roosts should be 2-3 feet off the ground with 8-10 inches of space per bird. Security is paramount: use hardware cloth instead of chicken wire, bury it 12 inches deep to prevent digging predators, and install automatic door closers for consistent protection. Regular cleaning is vital - remove droppings weekly, replace bedding monthly, and perform deep cleans quarterly. Consider adding windows for natural light, which promotes egg laying and overall health.",
                timeToRead: 6
            ),
            Article(
                id: UUID(),
                imageURL: "https://images.unsplash.com/photo-1612170153139-6f881ff067e0?ixlib=rb-4.0.3",
                title: "Common Chicken Diseases: Prevention and Treatment",
                textContent: "Understanding common poultry diseases is essential for every chicken keeper. Coccidiosis, one of the most prevalent issues in young birds, causes bloody diarrhea and lethargy - prevent it with medicated starter feed and maintaining dry, clean bedding. Newcastle Disease, a highly contagious viral infection, can devastate unvaccinated flocks with mortality rates near 100%. Marek's Disease affects the nervous system and is best prevented through vaccination at the hatchery. Fowl Pox appears as wart-like lesions and spreads through mosquitoes - vaccination is available for endemic areas. Respiratory infections like Infectious Bronchitis cause wheezing, nasal discharge, and reduced egg production. Prevention is always better than treatment: implement strict biosecurity measures, quarantine new birds for 30 days, maintain proper ventilation, provide clean water and balanced nutrition, and establish a relationship with a poultry veterinarian. Watch for warning signs including ruffled feathers, decreased appetite, abnormal droppings, respiratory distress, or sudden drops in egg production.",
                timeToRead: 7
            ),
            Article(
                id: UUID(),
                imageURL: "https://hpj.com/wp-content/uploads/2024/08/iStock-1601543516.jpg",
                title: "Maximizing Egg Production: A Complete Guide",
                textContent: "Optimal egg production requires attention to multiple factors working in harmony. Hens need 14-16 hours of daylight to maintain peak laying - supplement with artificial lighting during winter months. Nutrition is critical: layer feed should contain 16-18% protein and 3-4% calcium for strong shells. Fresh, clean water must always be available as eggs are 75% water. Stress reduction is vital - minimize loud noises, sudden changes, and overcrowding. Collect eggs 2-3 times daily to prevent broodiness and egg eating. Peak production typically occurs at 6-18 months of age, with most hens laying 250-280 eggs in their first year. Production naturally declines by 10-20% each subsequent year. Factors that decrease laying include molting (annual feather replacement), extreme temperatures, illness, poor nutrition, and shortened daylight. Some breeds like Leghorns excel at egg production (300+ eggs/year), while ornamental breeds may only lay 100-150. Keep production records to identify issues early and cull non-productive hens to maintain flock efficiency.",
                timeToRead: 8
            ),
            Article(
                id: UUID(),
                imageURL: "https://kajabi-storefronts-production.kajabi-cdn.com/kajabi-storefronts-production/file-uploads/blogs/2147938708/images/b233cae-eb86-7a06-2358-3acc2d413_blog_post_for_kajabi_6_.png",
                title: "Winter Chicken Care: Keeping Your Flock Thriving in Cold Weather",
                textContent: "Winter chicken keeping requires special considerations to maintain health and productivity. While chickens are remarkably cold-hardy, proper preparation ensures their comfort and continued egg production. Insulation is important but never seal the coop completely - ventilation prevents moisture buildup that causes frostbite. Deep litter method works wonderfully in winter: allow bedding to build up 12+ inches deep, turning it occasionally to promote composting which generates natural heat. Prevent water from freezing with heated waterers or by refreshing multiple times daily. Increase feed by 10% as chickens burn extra calories staying warm. Apply petroleum jelly to large combs and wattles to prevent frostbite. Collect eggs frequently to prevent freezing and cracking. Provide wind breaks in the run and consider clear plastic sheeting to create a greenhouse effect while maintaining ventilation. Most importantly, resist the urge to add heat lamps - they're fire hazards and prevent natural cold adaptation. Chickens acclimate beautifully to cold when given proper shelter, dry conditions, and adequate nutrition.",
                timeToRead: 6
            ),
            Article(
                id: UUID(),
                imageURL: "https://ogden_images.s3.amazonaws.com/www.iamcountryside.com/images/sites/3/2019/03/13153821/AdobeStock_301966048-scaled-e1660941668735.jpeg",
                title: "Heritage Breeds: Preserving Poultry Biodiversity",
                textContent: "Heritage chicken breeds represent centuries of selective breeding and cultural history, yet many face extinction as commercial hybrids dominate modern farming. These traditional breeds offer unique advantages: superior foraging ability, natural disease resistance, longer productive lives, and the ability to successfully reproduce naturally. Breeds like the Buckeye, developed in Ohio in the 1890s, thrive in cold climates and are excellent mouse hunters. The Java, America's second-oldest breed, nearly went extinct but is prized for its exceptional meat quality. Dominiques, America's oldest breed, possess remarkable hardiness and beautiful barred plumage. Heritage breeds often excel in backyard settings where their self-sufficiency shines - they're better mothers, more predator-aware, and adapt to various climates. By raising heritage breeds, small-scale farmers preserve genetic diversity crucial for future food security. The Livestock Conservancy maintains a priority list of endangered breeds needing conservation. While heritage breeds may lay fewer eggs than commercial layers, they offer sustainability, flavor, and a living connection to agricultural history that makes them invaluable.",
                timeToRead: 7
            )
        ]
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var readingTime: String {
        "\(timeToRead) min read"
    }
}
