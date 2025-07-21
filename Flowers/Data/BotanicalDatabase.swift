import Foundation

// MARK: - Botanical Species Database

struct BotanicalSpecies: Codable {
    let scientificName: String
    let commonNames: [String]
    let family: String
    let nativeRegions: [String]
    let bloomingSeason: String
    let conservationStatus: String
    let uses: [String]
    let interestingFacts: [String]
    let careInstructions: String
    let rarityLevel: RarityLevel
    let continents: [Continent]
    let habitat: String
    let description: String
    let imagePrompt: String // For botanically accurate AI generation
    
    // Computed properties
    var primaryCommonName: String {
        commonNames.first ?? scientificName
    }
    
    var primaryContinent: Continent {
        continents.first ?? .northAmerica
    }
}

class BotanicalDatabase {
    static let shared = BotanicalDatabase()
    
    private init() {}
    
    // MARK: - Real Botanical Species Database
    
    lazy var allSpecies: [BotanicalSpecies] = [
        // ROSES (Rosaceae)
        BotanicalSpecies(
            scientificName: "Rosa damascena",
            commonNames: ["Damask Rose", "Bulgarian Rose", "Rose of Castile"],
            family: "Rosaceae",
            nativeRegions: ["Middle East", "Central Asia", "Bulgaria"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Essential oil production", "Perfumery", "Culinary", "Traditional medicine"],
            interestingFacts: [
                "Used to make the world's most expensive rose oil, Bulgarian rose oil",
                "Takes 4,000 kilograms of petals to produce 1 kilogram of oil",
                "Has been cultivated for over 1,300 years in Bulgaria's Valley of Roses",
                "The scent is so complex that no synthetic version can truly replicate it"
            ],
            careInstructions: "Prefers well-drained soil and full sun. Water regularly during growing season. Prune in late winter.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia],
            habitat: "Temperate gardens and hillsides",
            description: "Highly fragrant double pink flowers with velvety petals and a rich, complex scent",
            imagePrompt: "Rosa damascena damask rose with double pink fragrant flowers, velvety petals, botanical illustration style"
        ),
        
        BotanicalSpecies(
            scientificName: "Rosa gallica",
            commonNames: ["French Rose", "Rose of Provins", "Gallic Rose"],
            family: "Rosaceae",
            nativeRegions: ["Southern Europe", "Western Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Perfumery", "Traditional medicine", "Culinary", "Ornamental"],
            interestingFacts: [
                "One of the oldest roses in cultivation, grown since ancient times",
                "The ancestor of many modern garden roses",
                "Symbol of the Lancaster family in the War of the Roses",
                "Petals retain their fragrance even when dried"
            ],
            careInstructions: "Hardy and disease-resistant. Tolerates poor soils. Minimal pruning required.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Mediterranean climates and temperate regions",
            description: "Deep pink to red semi-double flowers with prominent golden stamens and strong fragrance",
            imagePrompt: "Rosa gallica French rose with deep pink red semi-double flowers, golden stamens, ancient variety botanical illustration"
        ),
        
        // ORCHIDS (Orchidaceae)
        BotanicalSpecies(
            scientificName: "Orchis italica",
            commonNames: ["Italian Orchid", "Naked Man Orchid"],
            family: "Orchidaceae",
            nativeRegions: ["Mediterranean Basin", "North Africa"],
            bloomingSeason: "Spring",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Traditional medicine"],
            interestingFacts: [
                "Gets its common name from the distinctive human-like shape of its flowers",
                "Each plant can live for decades and grows from underground tubers",
                "Flowers have a light vanilla scent to attract pollinators",
                "Was historically used in traditional love potions"
            ],
            careInstructions: "Requires well-drained alkaline soil and partial shade. Dormant in summer.",
            rarityLevel: .rare,
            continents: [.europe, .africa],
            habitat: "Mediterranean scrubland and grasslands",
            description: "Distinctive pale pink flowers shaped like tiny human figures on tall spikes",
            imagePrompt: "Orchis italica Italian orchid with pale pink human-shaped flowers on tall spikes, Mediterranean native botanical illustration"
        ),
        
        BotanicalSpecies(
            scientificName: "Dendrobium nobile",
            commonNames: ["Noble Dendrobium", "Noble Rock Orchid"],
            family: "Orchidaceae",
            nativeRegions: ["Himalayas", "Southeast Asia", "Southern China"],
            bloomingSeason: "Winter to spring",
            conservationStatus: "Least Concern",
            uses: ["Traditional Chinese medicine", "Ornamental"],
            interestingFacts: [
                "Can live for over 100 years with proper care",
                "Grows naturally on tree trunks and rocks at high altitudes",
                "Used in Traditional Chinese Medicine for over 2,000 years",
                "Can survive temperatures near freezing"
            ],
            careInstructions: "Epiphytic. Needs bright light, cool winter rest, and good air circulation.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "High-altitude tropical forests",
            description: "Fragrant white and purple flowers with yellow centers along bamboo-like stems",
            imagePrompt: "Dendrobium nobile orchid with white purple flowers yellow centers, bamboo-like stems, epiphytic botanical illustration"
        ),
        
        // LILIES (Liliaceae)
        BotanicalSpecies(
            scientificName: "Lilium regale",
            commonNames: ["Regal Lily", "Royal Lily", "King's Lily"],
            family: "Liliaceae",
            nativeRegions: ["Western China", "Sichuan Province"],
            bloomingSeason: "Mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers"],
            interestingFacts: [
                "Discovered by Ernest Wilson in 1903 in a remote Chinese valley",
                "Can produce up to 25 flowers on a single stem",
                "Extremely fragrant, especially in the evening",
                "Nearly went extinct in the wild but was saved through cultivation"
            ],
            careInstructions: "Plant bulbs in well-drained soil with good organic matter. Full sun to partial shade.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "Mountain slopes and river valleys",
            description: "Large white trumpet-shaped flowers with golden throats and purple exterior streaks",
            imagePrompt: "Lilium regale regal lily with large white trumpet flowers, golden throats, purple exterior streaks, botanical illustration"
        ),
        
        BotanicalSpecies(
            scientificName: "Zantedeschia aethiopica",
            commonNames: ["Calla Lily", "Arum Lily", "Copo De Leite"],
            family: "Araceae",
            nativeRegions: ["South Africa", "Lesotho", "Swaziland"],
            bloomingSeason: "Spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Wedding decorations"],
            interestingFacts: [
                "Not actually a lily but belongs to the arum family",
                "The 'flower' is actually a modified leaf called a spathe",
                "Symbol of rebirth and resurrection in many cultures",
                "Can grow in both wet and dry conditions"
            ],
            careInstructions: "Prefers moist, well-drained soil and partial shade. Protect from frost.",
            rarityLevel: .common,
            continents: [.africa],
            habitat: "Marshy areas and stream banks",
            description: "Pure white funnel-shaped spathe surrounding a golden yellow spadix",
            imagePrompt: "Zantedeschia aethiopica calla lily with white funnel spathe, golden yellow spadix center, elegant curves botanical illustration"
        ),
        
        // SUNFLOWERS (Asteraceae)
        BotanicalSpecies(
            scientificName: "Helianthus annuus",
            commonNames: ["Common Sunflower", "Annual Sunflower"],
            family: "Asteraceae",
            nativeRegions: ["North America", "Mexico"],
            bloomingSeason: "Summer to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Oil production", "Food", "Bird seed", "Ornamental"],
            interestingFacts: [
                "Can grow up to 4 meters tall with flower heads 30cm across",
                "Follows the sun across the sky when young (heliotropism)",
                "A single flower head contains up to 2,000 individual flowers",
                "Seeds arranged in a perfect Fibonacci spiral pattern"
            ],
            careInstructions: "Plant in full sun with well-drained soil. Water regularly. Stake tall varieties.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Plains, prairies, and cultivated fields",
            description: "Large golden-yellow flower heads with dark centers and broad heart-shaped leaves",
            imagePrompt: "Helianthus annuus sunflower with large golden yellow petals, dark center, heart-shaped leaves botanical illustration"
        ),
        
        // PEONIES (Paeoniaceae)
        BotanicalSpecies(
            scientificName: "Paeonia lactiflora",
            commonNames: ["Chinese Peony", "Common Garden Peony", "White Peony"],
            family: "Paeoniaceae",
            nativeRegions: ["Northern China", "Eastern Siberia", "Mongolia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Traditional Chinese medicine", "Ornamental", "Cut flowers"],
            interestingFacts: [
                "Known as the 'Queen of Flowers' in Chinese culture",
                "Some plants can live for over 100 years",
                "Flowers can be up to 20cm across when fully open",
                "Used in Traditional Chinese Medicine for over 1,200 years"
            ],
            careInstructions: "Plant in well-drained soil with morning sun. Don't disturb established plants.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Temperate woodlands and grasslands",
            description: "Large, fragrant double flowers in shades of white, pink, and red with glossy foliage",
            imagePrompt: "Paeonia lactiflora Chinese peony with large double fragrant flowers, white pink red colors, glossy foliage botanical illustration"
        ),
        
        // HIBISCUS (Malvaceae)
        BotanicalSpecies(
            scientificName: "Hibiscus rosa-sinensis",
            commonNames: ["Chinese Hibiscus", "Hawaiian Hibiscus", "Shoe Flower"],
            family: "Malvaceae",
            nativeRegions: ["East Asia"],
            bloomingSeason: "Year-round in tropical climates",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Hair care", "Food coloring"],
            interestingFacts: [
                "Hawaii's state flower despite not being native to Hawaii",
                "Each flower typically lasts only one day",
                "Petals can be used to make natural red food coloring",
                "Over 200 species exist worldwide"
            ],
            careInstructions: "Needs warm temperatures, bright light, and consistent moisture. Prune regularly.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Tropical and subtropical gardens",
            description: "Large showy flowers with prominent stamens in colors ranging from white to deep red",
            imagePrompt: "Hibiscus rosa-sinensis Chinese hibiscus with large showy flowers, prominent stamens, tropical colors botanical illustration"
        ),
        
        // BIRDS OF PARADISE (Strelitziaceae)
        BotanicalSpecies(
            scientificName: "Strelitzia reginae",
            commonNames: ["Bird of Paradise", "Crane Flower"],
            family: "Strelitziaceae",
            nativeRegions: ["South Africa", "KwaZulu-Natal", "Eastern Cape"],
            bloomingSeason: "Year-round in suitable climates",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Landscape design"],
            interestingFacts: [
                "Named after Queen Charlotte of Mecklenburg-Strelitz",
                "The flower resembles a colorful bird in flight",
                "Can take 4-5 years to produce its first flower",
                "Pollinated by sunbirds in its native habitat"
            ],
            careInstructions: "Requires bright light, warm temperatures, and high humidity. Water regularly.",
            rarityLevel: .uncommon,
            continents: [.africa],
            habitat: "Coastal areas and river banks",
            description: "Striking orange and blue flowers that resemble tropical birds emerging from boat-shaped bracts",
            imagePrompt: "Strelitzia reginae bird of paradise with orange blue flowers, bird-like shape, boat-shaped bracts botanical illustration"
        ),
        
        // CHERRY BLOSSOMS (Rosaceae)
        BotanicalSpecies(
            scientificName: "Prunus serrulata",
            commonNames: ["Japanese Cherry", "Oriental Cherry", "Hill Cherry"],
            family: "Rosaceae",
            nativeRegions: ["Japan", "Korea", "China"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cultural ceremonies", "Traditional medicine"],
            interestingFacts: [
                "Central to Japanese hanami (flower viewing) tradition",
                "Flowers appear before the leaves in spring",
                "Symbol of the ephemeral nature of life in Japanese culture",
                "Over 200 varieties exist with different colors and forms"
            ],
            careInstructions: "Plant in well-drained soil with full sun. Prune after flowering.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Temperate forests and cultivated areas",
            description: "Delicate pink or white five-petaled flowers in abundant clusters before leaves emerge",
            imagePrompt: "Prunus serrulata Japanese cherry with delicate pink white five-petaled flowers, abundant clusters, spring blooming botanical illustration"
        ),
        
        // MAGNOLIAS (Magnoliaceae)
        BotanicalSpecies(
            scientificName: "Magnolia grandiflora",
            commonNames: ["Southern Magnolia", "Bull Bay", "Large-flower Magnolia"],
            family: "Magnoliaceae",
            nativeRegions: ["Southeastern United States"],
            bloomingSeason: "Late spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Timber", "Traditional medicine"],
            interestingFacts: [
                "State flower of Mississippi and Louisiana",
                "Flowers can reach 30cm in diameter",
                "Trees can live for over 100 years",
                "Fossil evidence shows magnolias existed 20 million years ago"
            ],
            careInstructions: "Plant in acidic, well-drained soil with partial shade. Mulch to keep roots cool.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Moist woodlands and swamps",
            description: "Large creamy-white fragrant flowers with thick waxy petals and glossy evergreen leaves",
            imagePrompt: "Magnolia grandiflora southern magnolia with large creamy white fragrant flowers, thick waxy petals, glossy leaves botanical illustration"
        ),
        
        // JASMINE (Oleaceae)
        BotanicalSpecies(
            scientificName: "Jasminum sambac",
            commonNames: ["Arabian Jasmine", "Sampaguita", "Pikake"],
            family: "Oleaceae",
            nativeRegions: ["South Asia", "Southeast Asia"],
            bloomingSeason: "Year-round in tropical climates",
            conservationStatus: "Least Concern",
            uses: ["Perfumery", "Essential oils", "Traditional medicine", "Religious ceremonies"],
            interestingFacts: [
                "National flower of the Philippines and Indonesia",
                "Flowers are most fragrant at night to attract nocturnal pollinators",
                "Used in jasmine tea and traditional garlands",
                "A single flower can perfume an entire room"
            ],
            careInstructions: "Needs warm temperatures, high humidity, and bright indirect light. Regular watering.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Tropical gardens and cultivated areas",
            description: "Small white star-shaped flowers with intense sweet fragrance on climbing vines",
            imagePrompt: "Jasminum sambac Arabian jasmine with small white star-shaped intensely fragrant flowers, climbing vines botanical illustration"
        ),
        
        // TULIPS (Liliaceae)
        BotanicalSpecies(
            scientificName: "Tulipa gesneriana",
            commonNames: ["Garden Tulip", "Didier's Tulip"],
            family: "Liliaceae",
            nativeRegions: ["Central Asia", "Turkey"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Bulb production"],
            interestingFacts: [
                "Caused 'Tulip Mania' in 17th century Netherlands",
                "Over 3,000 registered varieties exist today",
                "Bulbs were once more valuable than gold",
                "Symbol of the Netherlands despite originating in Turkey"
            ],
            careInstructions: "Plant bulbs in autumn in well-drained soil. Needs cold winter period to bloom.",
            rarityLevel: .common,
            continents: [.asia, .europe],
            habitat: "Temperate grasslands and cultivated gardens",
            description: "Cup-shaped flowers in brilliant colors with six petals and prominent stamens",
            imagePrompt: "Tulipa gesneriana garden tulip with cup-shaped brilliant colored flowers, six petals, prominent stamens botanical illustration"
        ),
        
        // DAFFODILS (Amaryllidaceae)
        BotanicalSpecies(
            scientificName: "Narcissus pseudonarcissus",
            commonNames: ["Daffodil", "Wild Daffodil", "Lent Lily"],
            family: "Amaryllidaceae",
            nativeRegions: ["Western Europe"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Naturalized plantings", "Traditional medicine"],
            interestingFacts: [
                "National flower of Wales",
                "Blooms announce the arrival of spring",
                "All parts of the plant are poisonous to animals",
                "Can naturalize and spread to form large colonies"
            ],
            careInstructions: "Plant bulbs in autumn. Tolerates various soil conditions. Allow foliage to die back naturally.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Woodlands, meadows, and naturalized areas",
            description: "Bright yellow flowers with trumpet-shaped corona surrounded by six petals",
            imagePrompt: "Narcissus pseudonarcissus daffodil with bright yellow trumpet corona, six surrounding petals, spring flowering botanical illustration"
        ),
        
        // IRISES (Iridaceae)
        BotanicalSpecies(
            scientificName: "Iris germanica",
            commonNames: ["German Iris", "Bearded Iris", "Common Iris"],
            family: "Iridaceae",
            nativeRegions: ["Southern Europe", "Middle East"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Perfumery", "Traditional medicine"],
            interestingFacts: [
                "Symbol of France (fleur-de-lis) and Florence",
                "Rhizomes called 'orris root' are used in perfumery",
                "Named after the Greek goddess of the rainbow",
                "Can bloom for several weeks with proper care"
            ],
            careInstructions: "Plant rhizomes in well-drained soil with full sun. Divide every 3-4 years.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Mediterranean hillsides and cultivated gardens",
            description: "Large flowers with six petals, three upright standards and three drooping falls, often bearded",
            imagePrompt: "Iris germanica German bearded iris with large six-petaled flowers, upright standards, drooping falls, bearded botanical illustration"
        ),
        
        // LAVENDER (Lamiaceae)
        BotanicalSpecies(
            scientificName: "Lavandula angustifolia",
            commonNames: ["English Lavender", "True Lavender", "Common Lavender"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean Basin"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Essential oils", "Aromatherapy", "Culinary", "Medicinal"],
            interestingFacts: [
                "Name comes from Latin 'lavare' meaning 'to wash'",
                "Used by ancient Romans to scent bath water",
                "Flowers retain fragrance even when dried",
                "Natural insect repellent and antiseptic properties"
            ],
            careInstructions: "Drought tolerant. Prefers well-drained soil and full sun. Prune after flowering.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Mediterranean scrubland and hillsides",
            description: "Fragrant purple flower spikes above narrow silvery-green aromatic foliage",
            imagePrompt: "Lavandula angustifolia English lavender with fragrant purple flower spikes, narrow silvery-green aromatic foliage botanical illustration"
        ),
        
        // LOTUS (Nelumbonaceae)
        BotanicalSpecies(
            scientificName: "Nelumbo nucifera",
            commonNames: ["Sacred Lotus", "Indian Lotus", "Pink Lotus"],
            family: "Nelumbonaceae",
            nativeRegions: ["Asia", "Australia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Religious ceremonies", "Food", "Traditional medicine", "Ornamental"],
            interestingFacts: [
                "Sacred flower in Buddhism and Hinduism",
                "Seeds can remain viable for over 1,000 years",
                "Leaves are completely water-repellent",
                "Flowers are thermogenic, generating their own heat"
            ],
            careInstructions: "Requires still water and full sun. Plant in large containers with rich soil.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "Ponds, lakes, and slow-moving waterways",
            description: "Large pink or white flowers with prominent seed pods, rising above circular floating leaves",
            imagePrompt: "Nelumbo nucifera sacred lotus with large pink white flowers, prominent seed pods, circular floating leaves botanical illustration"
        ),
        
        // PROTEAS (Proteaceae)
        BotanicalSpecies(
            scientificName: "Protea cynaroides",
            commonNames: ["King Protea", "Giant Protea", "Honeypot"],
            family: "Proteaceae",
            nativeRegions: ["South Africa", "Western Cape", "Eastern Cape"],
            bloomingSeason: "Autumn to spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Export floriculture"],
            interestingFacts: [
                "National flower of South Africa",
                "Largest flower head in the protea genus, up to 30cm across",
                "Named after Proteus, the Greek god who could change his form",
                "Can survive bush fires and regenerate from underground stems"
            ],
            careInstructions: "Requires well-drained, acidic soil and full sun. Drought tolerant once established.",
            rarityLevel: .rare,
            continents: [.africa],
            habitat: "Fynbos vegetation on mountain slopes",
            description: "Large crown-like flower heads with pointed bracts in shades of pink, red, and white",
            imagePrompt: "Protea cynaroides king protea with large crown-like flower heads, pointed bracts, pink red white colors botanical illustration"
        ),
        
        // WATER LILY (Nymphaeaceae)
        BotanicalSpecies(
            scientificName: "Nymphaea alba",
            commonNames: ["White Water Lily", "European White Water Lily"],
            family: "Nymphaeaceae",
            nativeRegions: ["Europe", "North Africa", "Western Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Flowers open in the morning and close in the afternoon",
                "Can live for decades with proper care",
                "Provides habitat for frogs, fish, and insects",
                "Symbol of purity in many cultures"
            ],
            careInstructions: "Requires still or slow-moving water and full sun. Plant in aquatic containers.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Ponds, lakes, and slow streams",
            description: "Pure white fragrant flowers floating on water surface with round lily pad leaves",
            imagePrompt: "Nymphaea alba white water lily with pure white fragrant floating flowers, round lily pad leaves botanical illustration"
        ),
        
        // BOUGAINVILLEA (Nyctaginaceae)
        BotanicalSpecies(
            scientificName: "Bougainvillea spectabilis",
            commonNames: ["Great Bougainvillea", "Paper Flower"],
            family: "Nyctaginaceae",
            nativeRegions: ["Brazil", "Peru", "Argentina"],
            bloomingSeason: "Year-round in tropical climates",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Hedging", "Erosion control"],
            interestingFacts: [
                "Named after French explorer Louis Antoine de Bougainville",
                "The colorful parts are actually modified leaves (bracts), not petals",
                "Can climb up to 12 meters high",
                "Extremely drought tolerant once established"
            ],
            careInstructions: "Requires full sun and well-drained soil. Prune regularly to maintain shape.",
            rarityLevel: .common,
            continents: [.southAmerica],
            habitat: "Tropical and subtropical coastal areas",
            description: "Vibrant magenta, purple, or white papery bracts surrounding small inconspicuous flowers",
            imagePrompt: "Bougainvillea spectabilis with vibrant magenta purple white papery bracts, climbing vine, small flowers botanical illustration"
        ),
        
        // CAMELLIAS (Theaceae)
        BotanicalSpecies(
            scientificName: "Camellia japonica",
            commonNames: ["Japanese Camellia", "Common Camellia"],
            family: "Theaceae",
            nativeRegions: ["China", "Japan", "Korea"],
            bloomingSeason: "Winter to early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Tea oil production", "Traditional medicine"],
            interestingFacts: [
                "State flower of Alabama",
                "Can live for hundreds of years",
                "Blooms during winter when few other flowers are available",
                "Seeds produce valuable camellia oil used in cooking and cosmetics"
            ],
            careInstructions: "Prefers acidic, well-drained soil and partial shade. Protect from strong winds.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Forest understory and cultivated gardens",
            description: "Large waxy flowers in shades of red, pink, or white with glossy evergreen foliage",
            imagePrompt: "Camellia japonica with large waxy flowers, red pink white colors, glossy evergreen foliage, winter blooming botanical illustration"
        ),
        
        // WISTERIA (Fabaceae)
        BotanicalSpecies(
            scientificName: "Wisteria sinensis",
            commonNames: ["Chinese Wisteria", "Purple Wisteria"],
            family: "Fabaceae",
            nativeRegions: ["China"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine"],
            interestingFacts: [
                "Vines can live for over 100 years and grow to enormous size",
                "Flowers appear before the leaves in spring",
                "Can produce thousands of flower clusters on a single plant",
                "All parts of the plant are toxic if ingested"
            ],
            careInstructions: "Requires strong support structure. Prune regularly to control growth. Full sun preferred.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Forest edges and cultivated areas",
            description: "Cascading clusters of fragrant purple flowers hanging from vigorous climbing vines",
            imagePrompt: "Wisteria sinensis Chinese wisteria with cascading purple flower clusters, fragrant hanging blooms, climbing vines botanical illustration"
        ),
    ]
    
    // MARK: - Helper Methods
    
    func getRandomSpecies(excluding: [String] = []) -> BotanicalSpecies? {
        let availableSpecies = allSpecies.filter { !excluding.contains($0.scientificName) }
        return availableSpecies.randomElement()
    }
    
    func getSpeciesByRarity(_ rarity: RarityLevel) -> [BotanicalSpecies] {
        return allSpecies.filter { $0.rarityLevel == rarity }
    }
    
    func getSpeciesByContinent(_ continent: Continent) -> [BotanicalSpecies] {
        return allSpecies.filter { $0.continents.contains(continent) }
    }
    
    func getSpeciesByFamily(_ family: String) -> [BotanicalSpecies] {
        return allSpecies.filter { $0.family == family }
    }
    
    func getSpeciesForSeason(_ season: String) -> [BotanicalSpecies] {
        return allSpecies.filter { species in
            species.bloomingSeason.localizedCaseInsensitiveContains(season)
        }
    }
    
    func searchSpecies(query: String) -> [BotanicalSpecies] {
        let lowercaseQuery = query.lowercased()
        return allSpecies.filter { species in
            species.scientificName.lowercased().contains(lowercaseQuery) ||
            species.commonNames.contains { $0.lowercased().contains(lowercaseQuery) } ||
            species.family.lowercased().contains(lowercaseQuery)
        }
    }
    
    // Get contextual species based on location and season
    func getContextualSpecies(continent: Continent?, season: String, existingSpecies: [String] = []) -> BotanicalSpecies? {
        var candidates = allSpecies.filter { !existingSpecies.contains($0.scientificName) }
        
        // Filter by continent if available
        if let continent = continent {
            let continentSpecies = candidates.filter { $0.continents.contains(continent) }
            if !continentSpecies.isEmpty {
                candidates = continentSpecies
            }
        }
        
        // Filter by season
        let seasonalSpecies = candidates.filter { 
            $0.bloomingSeason.localizedCaseInsensitiveContains(season)
        }
        
        if !seasonalSpecies.isEmpty {
            candidates = seasonalSpecies
        }
        
        return candidates.randomElement()
    }
}