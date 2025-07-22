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
            imagePrompt: "Rosa damascena damask rose with double pink fragrant flowers, velvety petals"
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
            imagePrompt: "Rosa gallica French rose with deep pink red semi-double flowers, golden stamens, ancient variety"
        ),
        
        // More ROSES (Rosaceae)
        BotanicalSpecies(
            scientificName: "Rosa rubiginosa",
            commonNames: ["Sweet Briar", "Eglantine", "Sweet Brier"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Western Asia", "Northwestern Africa"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Wildlife habitat", "Traditional medicine", "Perfumery"],
            interestingFacts: [
                "Leaves smell of green apples when crushed",
                "Popular in Shakespearean literature and poetry",
                "Hips are rich in vitamin C and used for jellies",
                "Naturalized widely in temperate regions worldwide"
            ],
            careInstructions: "Very hardy and drought tolerant. Thrives in poor soils. Self-seeding.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa],
            habitat: "Wild hedgerows, scrubland, and hillsides",
            description: "Single pink flowers with apple-scented foliage and bright red hips",
            imagePrompt: "Rosa rubiginosa sweet briar with single pink flowers, apple-scented leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Rosa canina",
            commonNames: ["Dog Rose", "Wild Rose", "Hip Rose"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Northwest Africa", "Western Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Wildlife food", "Traditional medicine", "Rootstock for garden roses", "Culinary"],
            interestingFacts: [
                "Most common wild rose in Europe",
                "Hips contain 20 times more vitamin C than oranges",
                "Used as rootstock for most commercial roses",
                "Can live for over 100 years"
            ],
            careInstructions: "Extremely hardy and adaptable. Requires no care in suitable climates.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Woods, hedges, scrubland",
            description: "Pale pink to white single flowers with prominent hips in autumn",
            imagePrompt: "Rosa canina dog rose with pale pink white single flowers, prominent red hips"
        ),
        
        BotanicalSpecies(
            scientificName: "Rosa moschata",
            commonNames: ["Musk Rose", "Autumn Rose"],
            family: "Rosaceae",
            nativeRegions: ["Himalayas", "Western Asia"],
            bloomingSeason: "Late summer to autumn",
            conservationStatus: "Near Threatened",
            uses: ["Perfumery", "Traditional medicine", "Ornamental"],
            interestingFacts: [
                "Blooms later than most roses, in autumn",
                "Strong musky fragrance, especially in evening",
                "Ancestor of many modern climbing roses",
                "Can climb up to 4 meters high"
            ],
            careInstructions: "Prefers warm climates. Needs support for climbing. Prune lightly in winter.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "Mountain slopes and forest edges",
            description: "Creamy white flowers in clusters with intense musky evening fragrance",
            imagePrompt: "Rosa moschata musk rose with creamy white clustered flowers, climbing habit"
        ),
        
        BotanicalSpecies(
            scientificName: "Rosa foetida",
            commonNames: ["Austrian Yellow", "Persian Yellow Rose"],
            family: "Rosaceae",
            nativeRegions: ["Central Asia", "Caucasus"],
            bloomingSeason: "Late spring",
            conservationStatus: "Vulnerable",
            uses: ["Ornamental", "Rose breeding"],
            interestingFacts: [
                "One of the few naturally yellow roses",
                "Introduced yellow color to modern roses",
                "Strong, unpleasant scent when flowers first open",
                "Very susceptible to black spot disease"
            ],
            careInstructions: "Needs excellent drainage. Susceptible to fungal diseases. Plant in full sun.",
            rarityLevel: .rare,
            continents: [.asia],
            habitat: "Dry hillsides and steppes",
            description: "Bright yellow single flowers with unpleasant fragrance",
            imagePrompt: "Rosa foetida Austrian yellow rose with bright yellow single flowers"
        ),
        
        BotanicalSpecies(
            scientificName: "Rosa banksiae",
            commonNames: ["Banks' Rose", "Lady Banks' Rose", "Banksia Rose"],
            family: "Rosaceae",
            nativeRegions: ["Central China", "Western China"],
            bloomingSeason: "Late spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Landscape screening"],
            interestingFacts: [
                "Nearly thornless climbing rose",
                "Can grow up to 20 feet tall and wide",
                "One of the first Chinese roses introduced to Europe",
                "Blooms only on old wood"
            ],
            careInstructions: "Very vigorous. Needs strong support. Prune immediately after flowering.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "Forest edges and slopes",
            description: "Masses of small white or yellow double flowers in clusters",
            imagePrompt: "Rosa banksiae Banks rose with masses of small white double flowers, thornless climbing"
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
            imagePrompt: "Orchis italica Italian orchid with pale pink human-shaped flowers on tall spikes, Mediterranean native"
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
            imagePrompt: "Dendrobium nobile orchid with white purple flowers yellow centers, bamboo-like stems, epiphytic"
        ),
        
        BotanicalSpecies(
            scientificName: "Paphiopedilum sukhakulii",
            commonNames: ["Slipper Orchid", "Lady Slipper Orchid"],
            family: "Orchidaceae",
            nativeRegions: ["Thailand", "Myanmar"],
            bloomingSeason: "Year-round in cultivation",
            conservationStatus: "Endangered",
            uses: ["Ornamental", "Conservation breeding"],
            interestingFacts: [
                "Named after Thai orchid enthusiast Sukhakul",
                "Pouch-shaped lip traps insects for pollination",
                "Takes 5-7 years to bloom from seed",
                "Threatened by habitat loss and illegal collection"
            ],
            careInstructions: "Requires high humidity, filtered light, and excellent drainage. Cool nights preferred.",
            rarityLevel: .endangered,
            continents: [.asia],
            habitat: "Limestone cliffs and forest floors",
            description: "Distinctive slipper-shaped flowers with mottled green and purple patterns",
            imagePrompt: "Paphiopedilum sukhakulii slipper orchid with mottled green purple pouch-shaped flowers"
        ),
        
        BotanicalSpecies(
            scientificName: "Cypripedium calceolus",
            commonNames: ["Lady's Slipper", "Yellow Lady Slipper"],
            family: "Orchidaceae",
            nativeRegions: ["Northern Europe", "Asia", "Northern North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Vulnerable",
            uses: ["Ornamental", "Traditional medicine", "Conservation"],
            interestingFacts: [
                "Can live for over 100 years",
                "Takes up to 16 years to produce first flower",
                "Near extinction in Britain with only one known wild plant",
                "Symbol of several conservation programs"
            ],
            careInstructions: "Extremely difficult to cultivate. Requires specific soil fungi and cool conditions.",
            rarityLevel: .veryRare,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Calcareous woodlands and meadows",
            description: "Bright yellow inflated pouch with maroon petals and twisted sepals",
            imagePrompt: "Cypripedium calceolus lady slipper orchid with bright yellow pouch, maroon petals"
        ),
        
        BotanicalSpecies(
            scientificName: "Vanilla planifolia",
            commonNames: ["Vanilla Orchid", "Flat-leaved Vanilla"],
            family: "Orchidaceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Year-round in tropics",
            conservationStatus: "Vulnerable",
            uses: ["Spice production", "Flavoring", "Perfumery", "Traditional medicine"],
            interestingFacts: [
                "Source of natural vanilla flavoring",
                "Climbing orchid that can reach 30 meters",
                "Flowers must be hand-pollinated outside native range",
                "Second most expensive spice after saffron"
            ],
            careInstructions: "Requires tropical conditions, high humidity, and climbing support. Hand pollination needed.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Tropical rainforest edges and clearings",
            description: "Creamy white fragrant flowers that develop into vanilla pods",
            imagePrompt: "Vanilla planifolia vanilla orchid with creamy white fragrant flowers, climbing vine"
        ),
        
        BotanicalSpecies(
            scientificName: "Orchis mascula",
            commonNames: ["Early Purple Orchid", "Male Orchid"],
            family: "Orchidaceae",
            nativeRegions: ["Europe", "North Africa", "Western Asia"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "One of the first orchids to bloom in spring",
                "Leaves often have dark purple spots",
                "Ancient Greeks used tubers as aphrodisiac",
                "Important food source for early pollinators"
            ],
            careInstructions: "Hardy woodland orchid. Prefers chalky soils and partial shade.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Woodlands, grasslands, and scrubland",
            description: "Magenta to purple flower spikes with spotted leaves",
            imagePrompt: "Orchis mascula early purple orchid with magenta purple flower spikes, spotted leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Ophrys apifera",
            commonNames: ["Bee Orchid", "Bumblebee Orchid"],
            family: "Orchidaceae",
            nativeRegions: ["Europe", "Mediterranean", "North Africa"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Wildlife observation", "Research"],
            interestingFacts: [
                "Lip mimics female bee to attract male pollinators",
                "Can self-pollinate when bee pollination fails",
                "Flowers have furry lip with intricate patterns",
                "Each population has slightly different bee mimicry"
            ],
            careInstructions: "Requires chalky, well-drained soil and full sun. Difficult to cultivate.",
            rarityLevel: .uncommon,
            continents: [.europe, .africa],
            habitat: "Calcareous grasslands and scrub",
            description: "Pink sepals with furry brown lip that resembles a bee",
            imagePrompt: "Ophrys apifera bee orchid with pink sepals, furry brown bee-like lip"
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
            imagePrompt: "Lilium regale regal lily with large white trumpet flowers, golden throats, purple exterior streaks"
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
            imagePrompt: "Zantedeschia aethiopica calla lily with white funnel spathe, golden yellow spadix center, elegant curves"
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
            imagePrompt: "Helianthus annuus sunflower with large golden yellow petals, dark center, heart-shaped leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Helianthus maximiliani",
            commonNames: ["Maximilian Sunflower", "Prairie Sunflower"],
            family: "Asteraceae",
            nativeRegions: ["Central North America", "Great Plains"],
            bloomingSeason: "Late summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Pollinator gardens", "Ornamental"],
            interestingFacts: [
                "Can grow up to 10 feet tall with hundreds of small sunflowers",
                "Important late-season food source for migrating birds",
                "Spreads by underground rhizomes to form colonies",
                "Named after Prince Maximilian of Wied-Neuwied"
            ],
            careInstructions: "Full sun, tolerates poor soils. Very drought tolerant. Can be invasive in gardens.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Prairies, roadsides, and disturbed areas",
            description: "Tall stems with numerous small yellow sunflowers and narrow leaves",
            imagePrompt: "Helianthus maximiliani Maximilian sunflower with tall stems, numerous small yellow flowers, prairie native"
        ),
        
        BotanicalSpecies(
            scientificName: "Bellis perennis",
            commonNames: ["English Daisy", "Common Daisy", "Lawn Daisy"],
            family: "Asteraceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Edible flowers", "Traditional medicine"],
            interestingFacts: [
                "Flowers close at night and in cloudy weather",
                "Name 'daisy' comes from 'day's eye'",
                "Used in children's daisy chain crafts",
                "Edible flowers taste slightly bitter but nutritious"
            ],
            careInstructions: "Adapts to most soils. Prefers cool, moist conditions. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Lawns, meadows, and grassy areas",
            description: "Small white flowers with yellow centers on short stems",
            imagePrompt: "Bellis perennis English daisy with small white flowers, yellow centers, lawn growing, children's flower chains"
        ),
        
        BotanicalSpecies(
            scientificName: "Rudbeckia hirta",
            commonNames: ["Black-eyed Susan", "Brown-eyed Susan"],
            family: "Asteraceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Summer to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Wildflower gardens", "Cut flowers"],
            interestingFacts: [
                "State flower of Maryland",
                "Popular with butterflies and beneficial insects",
                "Seeds are favorite food of goldfinches",
                "Can bloom continuously for months with deadheading"
            ],
            careInstructions: "Full sun, well-drained soil. Drought tolerant. Deadhead for continued blooming.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Prairies, meadows, and open woodlands",
            description: "Bright golden-yellow petals surrounding dark brown centers",
            imagePrompt: "Rudbeckia hirta black-eyed Susan with golden yellow petals, dark brown centers, wildflower meadows"
        ),
        
        BotanicalSpecies(
            scientificName: "Echinacea purpurea",
            commonNames: ["Purple Coneflower", "Eastern Purple Coneflower"],
            family: "Asteraceae",
            nativeRegions: ["Central and Eastern United States"],
            bloomingSeason: "Summer to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Ornamental", "Wildlife habitat"],
            interestingFacts: [
                "Widely used in herbal medicine to boost immunity",
                "Native Americans used it for various medicinal purposes",
                "Drought tolerant once established",
                "Attracts butterflies, bees, and goldfinches to seeds"
            ],
            careInstructions: "Full sun, well-drained soil. Very drought tolerant. Leave seed heads for birds.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Prairies, open woodlands, and roadsides",
            description: "Pink-purple drooping petals around prominent orange-brown cones",
            imagePrompt: "Echinacea purpurea purple coneflower with pink purple drooping petals, orange-brown cone centers"
        ),
        
        BotanicalSpecies(
            scientificName: "Taraxacum officinale",
            commonNames: ["Common Dandelion", "Lion's Tooth", "Piss-en-lit"],
            family: "Asteraceae",
            nativeRegions: ["Eurasia"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Edible greens", "Traditional medicine", "Wine making"],
            interestingFacts: [
                "Entirely edible from root to flower",
                "One of the first flowers to bloom in spring, vital for early pollinators",
                "Seeds can travel up to 100 kilometers on the wind",
                "Name comes from French 'dent de lion' meaning lion's tooth"
            ],
            careInstructions: "Extremely hardy and adaptable. Grows almost anywhere with minimal care.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Lawns, fields, roadsides, and waste places",
            description: "Bright yellow composite flowers that turn into spherical white seed heads",
            imagePrompt: "Taraxacum officinale dandelion with bright yellow flowers, white fluffy seed heads, jagged leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Leucanthemum vulgare",
            commonNames: ["Ox-eye Daisy", "Common Daisy", "White Daisy"],
            family: "Asteraceae",
            nativeRegions: ["Europe", "Temperate Asia"],
            bloomingSeason: "Late spring to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Traditional flower for 'loves me, loves me not' games",
                "Can produce up to 26,000 seeds per plant",
                "Forms extensive colonies through underground rhizomes",
                "Important nectar source for many butterfly species"
            ],
            careInstructions: "Full sun, well-drained soil. Very hardy and drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Meadows, roadsides, and disturbed ground",
            description: "Classic white daisy with bright yellow center and toothed leaves",
            imagePrompt: "Leucanthemum vulgare ox-eye daisy with white petals, bright yellow center, classic daisy form"
        ),
        
        BotanicalSpecies(
            scientificName: "Solidago canadensis",
            commonNames: ["Canada Goldenrod", "Common Goldenrod"],
            family: "Asteraceae",
            nativeRegions: ["North America"],
            bloomingSeason: "Late summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Traditional medicine", "Dye plant"],
            interestingFacts: [
                "One of the most important late-season nectar sources",
                "Supports over 115 species of butterflies and moths",
                "Often blamed for hay fever but pollen is too heavy to be wind-borne",
                "Can form dense colonies that exclude other plants"
            ],
            careInstructions: "Full sun to partial shade. Adapts to various soils. Can be aggressive spreader.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Fields, prairies, roadsides, and forest edges",
            description: "Tall plumes of tiny bright yellow flowers in dense clusters",
            imagePrompt: "Solidago canadensis Canada goldenrod with tall plumes, tiny bright yellow flowers, dense autumn clusters"
        ),
        
        BotanicalSpecies(
            scientificName: "Chrysanthemum morifolium",
            commonNames: ["Garden Mum", "Florist's Chrysanthemum"],
            family: "Asteraceae",
            nativeRegions: ["China", "Northeast Asia"],
            bloomingSeason: "Autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Traditional medicine", "Tea"],
            interestingFacts: [
                "National flower of Japan and symbol of autumn",
                "Over 40 different flower forms exist",
                "Used in Traditional Chinese Medicine for over 2,000 years",
                "Flowers are edible and used in Asian cuisine"
            ],
            careInstructions: "Full sun, well-drained soil. Pinch tips in summer for bushier plants.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Cultivated gardens and commercial flower production",
            description: "Dense, multi-layered flowers in various colors and forms",
            imagePrompt: "Chrysanthemum morifolium garden mum with dense layered petals, autumn colors, various flower forms"
        ),
        
        BotanicalSpecies(
            scientificName: "Aster novae-angliae",
            commonNames: ["New England Aster", "Michaelmas Daisy"],
            family: "Asteraceae",
            nativeRegions: ["Eastern and Central North America"],
            bloomingSeason: "Late summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Wildlife habitat", "Pollinator gardens"],
            interestingFacts: [
                "Supports over 112 species of butterfly and moth caterpillars",
                "Blooms when few other flowers are available",
                "Can reach 6 feet tall in ideal conditions",
                "Important fall nectar source for monarch butterflies"
            ],
            careInstructions: "Full sun to partial shade. Moist, fertile soil preferred. May need staking.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Meadows, prairies, and moist open areas",
            description: "Purple or pink daisy-like flowers with yellow centers in dense clusters",
            imagePrompt: "Aster novae-angliae New England aster with purple pink flowers, yellow centers, dense autumn clusters"
        ),
        
        BotanicalSpecies(
            scientificName: "Gerbera jamesonii",
            commonNames: ["Gerbera Daisy", "Barberton Daisy", "Transvaal Daisy"],
            family: "Asteraceae",
            nativeRegions: ["South Africa", "Mpumalanga", "Limpopo"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Cut flowers", "Ornamental", "Commercial floriculture"],
            interestingFacts: [
                "Fifth most popular cut flower in the world",
                "Can bloom continuously for up to 10 months",
                "Named after German botanist Traugott Gerber",
                "Bred in thousands of color combinations"
            ],
            careInstructions: "Bright light, well-drained soil. Water at soil level to prevent crown rot.",
            rarityLevel: .common,
            continents: [.africa],
            habitat: "Grasslands and rocky outcrops",
            description: "Large, colorful daisy-like flowers with prominent centers in soft colors",
            imagePrompt: "Gerbera jamesonii gerbera daisy with large colorful petals, prominent centers, soft pastel colors"
        ),
        
        BotanicalSpecies(
            scientificName: "Centaurea cyanus",
            commonNames: ["Cornflower", "Bachelor's Button", "Bluebottle"],
            family: "Asteraceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early autumn",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Edible flowers", "Traditional medicine"],
            interestingFacts: [
                "National flower of Estonia and Germany",
                "Nearly extinct in the wild due to intensive farming",
                "Flowers are edible with a sweet, spicy flavor",
                "Symbol of delicacy and refinement in Victorian flower language"
            ],
            careInstructions: "Full sun, poor to moderate soil. Drought tolerant. Self-seeds in suitable conditions.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Cornfields, meadows, and waste ground",
            description: "Brilliant blue fringed flowers on slender stems with narrow gray-green leaves",
            imagePrompt: "Centaurea cyanus cornflower with brilliant blue fringed flowers, slender stems, German national flower"
        ),
        
        BotanicalSpecies(
            scientificName: "Dahlia pinnata",
            commonNames: ["Garden Dahlia", "Common Dahlia"],
            family: "Asteraceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Summer to first frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Traditional food"],
            interestingFacts: [
                "National flower of Mexico",
                "Over 50,000 registered cultivars exist",
                "Tubers were originally grown as food by Aztecs",
                "Flowers range from 2 inches to over 1 foot across"
            ],
            careInstructions: "Full sun, rich well-drained soil. Stake tall varieties. Lift tubers in cold climates.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Mountain meadows and cultivated gardens",
            description: "Showy flowers in countless forms and colors from simple to fully double",
            imagePrompt: "Dahlia pinnata garden dahlia with showy flowers, countless forms and colors, Mexican national flower"
        ),
        
        BotanicalSpecies(
            scientificName: "Calendula officinalis",
            commonNames: ["Pot Marigold", "English Marigold", "Calendula"],
            family: "Asteraceae",
            nativeRegions: ["Southern Europe", "Mediterranean"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Cosmetics", "Edible flowers", "Natural dye"],
            interestingFacts: [
                "Petals are edible with a slightly bitter, tangy flavor",
                "Used in skincare products for its healing properties",
                "Flowers close at night and in cloudy weather",
                "Self-seeds readily and can bloom until hard frost"
            ],
            careInstructions: "Full sun to partial shade. Tolerates poor soils. Cool weather extends bloom time.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Cultivated gardens and naturalized areas",
            description: "Bright orange or yellow daisy-like flowers with sticky aromatic foliage",
            imagePrompt: "Calendula officinalis pot marigold with bright orange yellow flowers, sticky aromatic foliage, medicinal herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Coreopsis tinctoria",
            commonNames: ["Plains Coreopsis", "Calliopsis", "Tickseed"],
            family: "Asteraceae",
            nativeRegions: ["North America", "Great Plains"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Natural dye", "Ornamental"],
            interestingFacts: [
                "Used by Native Americans to make red and orange dyes",
                "Self-seeds prolifically in suitable habitats",
                "Flowers attract beneficial insects and butterflies",
                "Can bloom continuously from spring until frost"
            ],
            careInstructions: "Full sun, well-drained soil. Very drought tolerant. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Prairies, roadsides, and disturbed areas",
            description: "Small flowers with yellow petals marked with red-brown at the base",
            imagePrompt: "Coreopsis tinctoria plains coreopsis with yellow petals, red-brown markings, prairie wildflower"
        ),
        
        BotanicalSpecies(
            scientificName: "Zinnia elegans",
            commonNames: ["Common Zinnia", "Youth-and-age", "Elegant Zinnia"],
            family: "Asteraceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Summer to first frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Butterfly gardens"],
            interestingFacts: [
                "Named after German botanist Johann Gottfried Zinn",
                "Flowers last up to 24 days when cut",
                "Excellent butterfly and hummingbird plant",
                "Available in nearly every color except blue"
            ],
            careInstructions: "Full sun, well-drained soil. Water at base to prevent powdery mildew.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Dry scrublands and cultivated gardens",
            description: "Colorful flowers in solid colors or bi-colors with papery texture",
            imagePrompt: "Zinnia elegans common zinnia with soft colored papery textured flowers, butterfly garden favorite"
        ),
        
        BotanicalSpecies(
            scientificName: "Arctium lappa",
            commonNames: ["Greater Burdock", "Gobo", "Bardane"],
            family: "Asteraceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Edible root", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Root is commonly eaten as a vegetable in Japan (gobo)",
                "Inspired the invention of Velcro from its burr-like seeds",
                "Can grow up to 9 feet tall in second year",
                "Used in traditional herbal medicine for centuries"
            ],
            careInstructions: "Rich, deep soil preferred. Biennial - flowers in second year. Full sun to partial shade.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Waste ground, roadsides, and woodland edges",
            description: "Purple thistle-like flowers surrounded by hooked bracts that form burrs",
            imagePrompt: "Arctium lappa greater burdock with purple thistle-like flowers, hooked bracts, large leaves, biennial"
        ),
        
        BotanicalSpecies(
            scientificName: "Tagetes patula",
            commonNames: ["French Marigold", "Dwarf Marigold"],
            family: "Asteraceae",
            nativeRegions: ["Mexico", "Guatemala"],
            bloomingSeason: "Spring to first frost",
            conservationStatus: "Least Concern",
            uses: ["Companion planting", "Ornamental", "Natural pest control"],
            interestingFacts: [
                "Repels many garden pests including nematodes",
                "Popular companion plant for tomatoes and other vegetables",
                "Flowers are edible with a citrusy, slightly bitter taste",
                "Can bloom continuously for months with minimal care"
            ],
            careInstructions: "Full sun, well-drained soil. Very easy to grow from seed. Deadhead for continued blooming.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Cultivated gardens and naturalized areas",
            description: "Small, dense flowers in yellow, orange, red, or bi-colored combinations",
            imagePrompt: "Tagetes patula French marigold with small dense flowers, yellow orange red colors, companion plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Cosmos bipinnatus",
            commonNames: ["Garden Cosmos", "Mexican Aster", "Common Cosmos"],
            family: "Asteraceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Summer to first frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Wildlife habitat"],
            interestingFacts: [
                "Self-seeds readily and can naturalize in suitable climates",
                "Attracts beneficial insects including lacewings and parasitic wasps",
                "Tolerates poor soils better than rich, fertile soils",
                "Name 'cosmos' means 'ordered universe' in Greek"
            ],
            careInstructions: "Full sun, poor to moderate soil. Too much fertilizer reduces flowering.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Fields, roadsides, and cultivated gardens",
            description: "Delicate flowers in pink, white, or red with feathery foliage",
            imagePrompt: "Cosmos bipinnatus garden cosmos with delicate pink white flowers, feathery foliage, simple elegant form"
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
            imagePrompt: "Paeonia lactiflora Chinese peony with large double fragrant flowers, white pink red colors, glossy foliage"
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
            imagePrompt: "Hibiscus rosa-sinensis Chinese hibiscus with large showy flowers, prominent stamens, tropical colors"
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
            imagePrompt: "Strelitzia reginae bird of paradise with orange blue flowers, bird-like shape, boat-shaped bracts"
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
            imagePrompt: "Prunus serrulata Japanese cherry with delicate pink white five-petaled flowers, abundant clusters, spring blooming"
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
            imagePrompt: "Magnolia grandiflora southern magnolia with large creamy white fragrant flowers, thick waxy petals, glossy leaves"
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
            imagePrompt: "Jasminum sambac Arabian jasmine with small white star-shaped intensely fragrant flowers, climbing vines"
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
            imagePrompt: "Tulipa gesneriana garden tulip with cup-shaped brilliant colored flowers, six petals, prominent stamens"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium candidum",
            commonNames: ["Madonna Lily", "White Lily", "Bourbon Lily"],
            family: "Liliaceae",
            nativeRegions: ["Eastern Mediterranean", "Balkans"],
            bloomingSeason: "Early summer",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Religious ceremonies", "Traditional medicine", "Perfumery"],
            interestingFacts: [
                "One of the oldest cultivated plants, grown for over 3,500 years",
                "Symbol of purity and resurrection in Christian tradition",
                "Featured in ancient Minoan frescoes and Egyptian art",
                "Can produce up to 20 flowers per stem when mature"
            ],
            careInstructions: "Plant bulbs shallowly in alkaline, well-drained soil. Prefers cool roots and warm tops.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Rocky hillsides and mountain meadows",
            description: "Pure white trumpet-shaped flowers with golden stamens and intense sweet fragrance",
            imagePrompt: "Lilium candidum Madonna lily with pure white trumpet flowers, golden stamens, intense sweet fragrance, ancient variety"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium martagon",
            commonNames: ["Martagon Lily", "Turk's Cap Lily", "Common Turk's Cap"],
            family: "Liliaceae",
            nativeRegions: ["Europe", "Mongolia", "Central Asia"],
            bloomingSeason: "Mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Petals curve backwards to form distinctive turban shape",
                "Can produce up to 50 flowers on a single 6-foot stem",
                "Takes 4-7 years from seed to first flowering",
                "One of the most cold-hardy lilies, surviving -40°C"
            ],
            careInstructions: "Very hardy. Prefers partial shade and well-drained, slightly alkaline soil.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia],
            habitat: "Mountain woodlands and alpine meadows",
            description: "Nodding flowers with recurved petals in pink to purple with dark spots",
            imagePrompt: "Lilium martagon Turk's cap lily with recurved spotted petals, nodding pink purple flowers, tall stems"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium lancifolium",
            commonNames: ["Tiger Lily", "Orange Lily", "Leopard Lily"],
            family: "Liliaceae",
            nativeRegions: ["China", "Japan", "Korea"],
            bloomingSeason: "Late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Food (bulbs edible)", "Traditional medicine"],
            interestingFacts: [
                "Bulbs are edible and considered a delicacy in East Asian cuisine",
                "Reproduces through small black bulbils that form in leaf axils",
                "Can grow up to 5 feet tall with dozens of flowers",
                "Orange petals with purple-black spots inspired the common name"
            ],
            careInstructions: "Tolerates various conditions. Plant bulbs deep with good drainage. Full to partial sun.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Grasslands, forest edges, and cultivated areas",
            description: "Bright orange recurved petals covered in dark purple-black spots with prominent stamens",
            imagePrompt: "Lilium lancifolium tiger lily with bright orange recurved petals, dark purple spots, prominent stamens"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium auratum",
            commonNames: ["Golden-rayed Lily", "Mountain Lily", "Gold Band Lily"],
            family: "Liliaceae",
            nativeRegions: ["Japan", "Honshu", "Kyushu"],
            bloomingSeason: "Late summer to early autumn",
            conservationStatus: "Vulnerable",
            uses: ["Ornamental", "Cut flowers", "Traditional medicine"],
            interestingFacts: [
                "Called 'Queen of Lilies' for its spectacular appearance",
                "Flowers can reach 25cm across with intense fragrance",
                "Golden ray down center of each white petal",
                "Nearly extinct in wild due to overcollection and habitat loss"
            ],
            careInstructions: "Acidic, well-drained soil with excellent organic matter. Partial shade preferred.",
            rarityLevel: .veryRare,
            continents: [.asia],
            habitat: "Volcanic mountain slopes and forest clearings",
            description: "Massive white flowers with golden central stripe and crimson spots, intensely fragrant",
            imagePrompt: "Lilium auratum golden-rayed lily with massive white flowers, golden stripes, crimson spots, intensely fragrant"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium superbum",
            commonNames: ["American Turk's Cap Lily", "Swamp Lily", "Lily Royal"],
            family: "Liliaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Native plant restoration", "Traditional medicine"],
            interestingFacts: [
                "Can reach heights of 8 feet with up to 40 flowers per stem",
                "Native American tribes used bulbs for food",
                "Prefers wet soils unlike most lilies",
                "State wildflower of New Hampshire"
            ],
            careInstructions: "Prefers moist, acidic soil and partial shade. Excellent for bog gardens.",
            rarityLevel: .rare,
            continents: [.northAmerica],
            habitat: "Wet meadows, swamps, and stream sides",
            description: "Orange-red recurved petals with dark purple spots on tall stems",
            imagePrompt: "Lilium superbum American Turk's cap lily with orange-red recurved petals, dark spots, tall swamp lily"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium bulbiferum",
            commonNames: ["Orange Lily", "Fire Lily", "Tiger Lily"],
            family: "Liliaceae",
            nativeRegions: ["Central Europe", "Southern Europe"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Produces small bulbils in leaf axils for reproduction",
                "One of the few European native orange lilies",
                "Declining in wild due to habitat destruction",
                "Popular in medieval monastery gardens"
            ],
            careInstructions: "Well-drained, alkaline soil in full sun. Hardy and drought tolerant when established.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Mountain meadows and limestone grasslands",
            description: "Upward-facing bright orange flowers with dark spots and prominent stamens",
            imagePrompt: "Lilium bulbiferum orange fire lily with upward-facing bright orange flowers, dark spots, bulbils in leaf axils"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium henryi",
            commonNames: ["Henry's Lily", "Orange Speciosum Lily"],
            family: "Liliaceae",
            nativeRegions: ["Central China", "Hubei Province"],
            bloomingSeason: "Late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Hybridization", "Cut flowers"],
            interestingFacts: [
                "Named after Irish plant collector Augustine Henry",
                "Can produce up to 20 orange flowers per stem",
                "Important parent of many modern hybrid lilies",
                "Extremely hardy and long-lived in cultivation"
            ],
            careInstructions: "Adaptable to various soils. Prefers partial shade and good drainage.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "Forest edges and rocky slopes",
            description: "Nodding orange flowers with recurved petals and dark papillae",
            imagePrompt: "Lilium henryi Henry's lily with nodding orange recurved petals, dark papillae, Chinese native"
        ),
        
        BotanicalSpecies(
            scientificName: "Lilium pyrenaicum",
            commonNames: ["Pyrenean Lily", "Yellow Turk's Cap"],
            family: "Liliaceae",
            nativeRegions: ["Pyrenees Mountains", "Northern Spain"],
            bloomingSeason: "Early summer",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Alpine gardening", "Conservation"],
            interestingFacts: [
                "Smallest of the Turk's cap lilies",
                "Strong unpleasant scent described as 'foxy'",
                "Extremely hardy, surviving mountain conditions",
                "Rare in cultivation despite beautiful flowers"
            ],
            careInstructions: "Excellent drainage essential. Cool, moist conditions. Partial shade preferred.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Mountain meadows and forest clearings",
            description: "Small yellow nodding flowers with recurved spotted petals and strong scent",
            imagePrompt: "Lilium pyrenaicum Pyrenean lily with small yellow nodding flowers, recurved spotted petals, mountain native"
        ),
        
        BotanicalSpecies(
            scientificName: "Fritillaria imperialis",
            commonNames: ["Crown Imperial", "Kaiser's Crown", "Imperial Fritillary"],
            family: "Liliaceae",
            nativeRegions: ["Turkey", "Iran", "Kashmir"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Spring gardens", "Cut flowers"],
            interestingFacts: [
                "Distinctive crown of leaves above drooping flowers",
                "Strong musky scent deters rodents and deer",
                "Bulbs can weigh up to 1 kilogram",
                "Symbol of power in Ottoman and Persian gardens"
            ],
            careInstructions: "Plant bulbs on their side to prevent rot. Well-drained soil, full sun.",
            rarityLevel: .uncommon,
            continents: [.asia],
            habitat: "Mountain slopes and rocky areas",
            description: "Orange or yellow bell-shaped flowers hanging beneath crown of leaves",
            imagePrompt: "Fritillaria imperialis crown imperial with orange bell flowers, crown of leaves, musky scent, spring blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Fritillaria meleagris",
            commonNames: ["Snake's Head Fritillary", "Chess Flower", "Leper Lily"],
            family: "Liliaceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Spring",
            conservationStatus: "Vulnerable",
            uses: ["Ornamental", "Naturalized plantings", "Conservation"],
            interestingFacts: [
                "Distinctive checkerboard pattern on petals",
                "Name comes from resemblance to guinea fowl feathers",
                "Nearly extinct in Britain, found in only a few meadows",
                "Can produce both purple and white forms"
            ],
            careInstructions: "Moist, well-drained soil. Naturalizes well in grass. Cool conditions preferred.",
            rarityLevel: .rare,
            continents: [.europe, .asia],
            habitat: "Water meadows and damp grasslands",
            description: "Nodding bell-shaped flowers with distinctive checkerboard pattern in purple or white",
            imagePrompt: "Fritillaria meleagris snake's head fritillary with checkerboard pattern, nodding bell flowers, purple white forms"
        ),
        
        BotanicalSpecies(
            scientificName: "Erythronium americanum",
            commonNames: ["Trout Lily", "Dogtooth Violet", "Adder's Tongue"],
            family: "Liliaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Native plant gardens", "Traditional food"],
            interestingFacts: [
                "Leaves have distinctive mottled pattern resembling trout",
                "Takes 7 years from seed to first flowering",
                "Bulbs are edible and were used by Native Americans",
                "Forms large colonies through underground bulb offsets"
            ],
            careInstructions: "Woodland conditions with moist, rich soil. Partial to full shade.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Rich deciduous forests and woodland floors",
            description: "Yellow recurved lily-like flowers above mottled green leaves",
            imagePrompt: "Erythronium americanum trout lily with yellow recurved flowers, mottled green leaves, woodland spring ephemeral"
        ),
        
        BotanicalSpecies(
            scientificName: "Colchicum autumnale",
            commonNames: ["Autumn Crocus", "Meadow Saffron", "Naked Ladies"],
            family: "Liliaceae",
            nativeRegions: ["Europe", "North Africa", "Western Asia"],
            bloomingSeason: "Autumn",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Traditional medicine", "Research"],
            interestingFacts: [
                "Flowers appear without leaves in autumn, leaves in spring",
                "Contains colchicine, used in medical research and gout treatment",
                "All parts extremely poisonous if ingested",
                "Often mistaken for true crocuses"
            ],
            careInstructions: "Plant in summer. Well-drained soil, full sun to partial shade. Very low maintenance.",
            rarityLevel: .uncommon,
            continents: [.europe, .africa, .asia],
            habitat: "Meadows and woodland edges",
            description: "Pink to purple crocus-like flowers emerging directly from ground in autumn",
            imagePrompt: "Colchicum autumnale autumn crocus with pink purple flowers, leafless stems, autumn blooming, meadow saffron"
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
            imagePrompt: "Narcissus pseudonarcissus daffodil with bright yellow trumpet corona, six surrounding petals, spring flowering"
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
            imagePrompt: "Iris germanica German bearded iris with large six-petaled flowers, upright standards, drooping falls, bearded"
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
            imagePrompt: "Lavandula angustifolia English lavender with fragrant purple flower spikes, narrow silvery-green aromatic foliage"
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
            imagePrompt: "Nelumbo nucifera sacred lotus with large pink white flowers, prominent seed pods, circular floating leaves"
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
            imagePrompt: "Protea cynaroides king protea with large crown-like flower heads, pointed bracts, pink red white colors"
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
            imagePrompt: "Nymphaea alba white water lily with pure white fragrant floating flowers, round lily pad leaves"
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
            description: "Soft magenta, purple, or white papery bracts surrounding small inconspicuous flowers",
            imagePrompt: "Bougainvillea spectabilis with soft pastel magenta purple white papery bracts, climbing vine, small flowers"
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
            imagePrompt: "Camellia japonica with large waxy flowers, red pink white colors, glossy evergreen foliage, winter blooming"
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
            imagePrompt: "Wisteria sinensis Chinese wisteria with cascading purple flower clusters, fragrant hanging blooms, climbing vines"
        ),
        
        // MORE FABACEAE (Legumes)
        BotanicalSpecies(
            scientificName: "Lupinus polyphyllus",
            commonNames: ["Garden Lupin", "Russell Lupin", "Large-leaved Lupin"],
            family: "Fabaceae",
            nativeRegions: ["Western North America"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Soil improvement", "Wildlife habitat"],
            interestingFacts: [
                "Fixes nitrogen in soil through root nodules",
                "Can improve poor, acidic soils dramatically",
                "Tall flower spikes can reach 4 feet high",
                "Seeds are toxic to humans and livestock"
            ],
            careInstructions: "Well-drained, slightly acidic soil. Full sun to partial shade. Cut back after flowering.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Mountain meadows and roadsides",
            description: "Tall spikes of densely packed flowers in blue, purple, pink, white, or yellow",
            imagePrompt: "Lupinus polyphyllus garden lupin with tall flower spikes, densely packed blue purple flowers, palmately compound leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Lathyrus odoratus",
            commonNames: ["Sweet Pea", "Fragrant Pea"],
            family: "Fabaceae",
            nativeRegions: ["Sicily", "Southern Italy"],
            bloomingSeason: "Spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Fragrance"],
            interestingFacts: [
                "One of the most fragrant flowers in the garden",
                "Seeds are poisonous if eaten in quantity",
                "Climbing variety can reach 6 feet tall",
                "Over 1,000 cultivars have been developed"
            ],
            careInstructions: "Cool, moist conditions. Rich, well-drained soil. Support for climbing varieties.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Mediterranean hillsides and cultivated gardens",
            description: "Delicate butterfly-like flowers in pastel colors with intense sweet fragrance",
            imagePrompt: "Lathyrus odoratus sweet pea with delicate butterfly-like flowers, pastel colors, intense sweet fragrance, climbing vine"
        ),
        
        BotanicalSpecies(
            scientificName: "Robinia pseudoacacia",
            commonNames: ["Black Locust", "False Acacia", "White Locust"],
            family: "Fabaceae",
            nativeRegions: ["Eastern United States", "Appalachian Mountains"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Timber", "Ornamental", "Soil stabilization", "Honey production"],
            interestingFacts: [
                "Wood is naturally rot-resistant and extremely hard",
                "Flowers produce excellent honey with light color and mild flavor",
                "Can fix up to 200 pounds of nitrogen per acre annually",
                "Spreads aggressively through root suckers"
            ],
            careInstructions: "Adapts to poor soils. Full sun preferred. Can be invasive in some areas.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Woodlands, disturbed areas, and slopes",
            description: "Drooping clusters of fragrant white flowers on thorny trees",
            imagePrompt: "Robinia pseudoacacia black locust with drooping white flower clusters, fragrant blooms, thorny branches"
        ),
        
        BotanicalSpecies(
            scientificName: "Cytisus scoparius",
            commonNames: ["Scotch Broom", "Common Broom"],
            family: "Fabaceae",
            nativeRegions: ["Western Europe", "Northwestern Africa"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Erosion control", "Traditional crafts"],
            interestingFacts: [
                "Branches were historically used to make brooms",
                "Can fix nitrogen even in very poor soils",
                "Explosive seed pods can shoot seeds up to 15 feet",
                "Considered invasive in many temperate regions"
            ],
            careInstructions: "Poor, well-drained soils preferred. Full sun. Very drought tolerant once established.",
            rarityLevel: .common,
            continents: [.europe, .africa],
            habitat: "Heathlands, coastal areas, and disturbed ground",
            description: "Bright yellow pea-like flowers covering green, angular branches",
            imagePrompt: "Cytisus scoparius Scotch broom with bright yellow pea-like flowers, green angular branches, dense shrub"
        ),
        
        BotanicalSpecies(
            scientificName: "Trifolium pratense",
            commonNames: ["Red Clover", "Purple Clover", "Meadow Clover"],
            family: "Fabaceae",
            nativeRegions: ["Europe", "Western Asia", "Northwestern Africa"],
            bloomingSeason: "Late spring to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Livestock feed", "Soil improvement", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "One of the most important forage crops worldwide",
                "Flowers are edible and rich in protein",
                "Used in traditional medicine for women's health",
                "Can improve soil nitrogen content significantly"
            ],
            careInstructions: "Adapts to most soils. Prefers slightly alkaline conditions. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa],
            habitat: "Meadows, pastures, and roadsides",
            description: "Dense, rounded clusters of small purple-pink flowers with three-leaflet leaves",
            imagePrompt: "Trifolium pratense red clover with purple-pink flower heads, three-leaflet leaves, meadow habitat"
        ),
        
        BotanicalSpecies(
            scientificName: "Mimosa pudica",
            commonNames: ["Sensitive Plant", "Shame Plant", "Touch-me-not"],
            family: "Fabaceae",
            nativeRegions: ["Central America", "South America"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Scientific research"],
            interestingFacts: [
                "Leaves fold instantly when touched (thigmonasty)",
                "Movement is caused by rapid loss of turgor pressure",
                "Used in scientific studies of plant behavior",
                "Pink flowers resemble powder puffs"
            ],
            careInstructions: "Warm conditions, bright light. Moist but well-drained soil. Treat as annual in cold climates.",
            rarityLevel: .uncommon,
            continents: [.southAmerica, .northAmerica],
            habitat: "Tropical grasslands and disturbed areas",
            description: "Delicate pink puffball flowers with sensitive compound leaves that fold when touched",
            imagePrompt: "Mimosa pudica sensitive plant with pink puffball flowers, compound leaves that fold when touched"
        ),
        
        BotanicalSpecies(
            scientificName: "Acacia dealbata",
            commonNames: ["Silver Wattle", "Blue Wattle", "Mimosa"],
            family: "Fabaceae",
            nativeRegions: ["Southeastern Australia", "Tasmania"],
            bloomingSeason: "Winter to early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Timber", "Tannin production"],
            interestingFacts: [
                "Symbol of International Women's Day in Europe",
                "Blooms in winter when few other plants are flowering",
                "Fast-growing but relatively short-lived (30-40 years)",
                "Extremely fragrant yellow flowers"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant. Protect from strong winds.",
            rarityLevel: .uncommon,
            continents: [.oceania],
            habitat: "Open forests and woodland edges",
            description: "Masses of fragrant bright yellow fluffy flower balls on silvery-blue foliage",
            imagePrompt: "Acacia dealbata silver wattle with masses of bright yellow fluffy flowers, silvery-blue foliage, winter blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Caesalpinia pulcherrima",
            commonNames: ["Pride of Barbados", "Red Bird of Paradise", "Peacock Flower"],
            family: "Fabaceae",
            nativeRegions: ["Caribbean", "Central America"],
            bloomingSeason: "Year-round in tropical climates",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Butterfly gardens"],
            interestingFacts: [
                "National flower of Barbados",
                "Attracts butterflies and hummingbirds",
                "Can bloom continuously in warm climates",
                "Long red stamens give flowers distinctive appearance"
            ],
            careInstructions: "Full sun, well-drained soil. Drought tolerant. Prune to maintain shape.",
            rarityLevel: .uncommon,
            continents: [.northAmerica, .southAmerica],
            habitat: "Tropical and subtropical coastal areas",
            description: "Bright orange and red flowers with long red stamens and delicate fern-like foliage",
            imagePrompt: "Caesalpinia pulcherrima pride of Barbados with orange red flowers, long red stamens, delicate fern-like foliage"
        ),
        
        BotanicalSpecies(
            scientificName: "Medicago sativa",
            commonNames: ["Alfalfa", "Lucerne", "Purple Medic"],
            family: "Fabaceae",
            nativeRegions: ["Central Asia", "Iran"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Livestock feed", "Soil improvement", "Human food", "Traditional medicine"],
            interestingFacts: [
                "Called 'Queen of Forages' for its nutritional value",
                "Roots can extend down 15 feet deep",
                "One of the oldest cultivated crops, grown for 2,500+ years",
                "Sprouts are popular health food"
            ],
            careInstructions: "Deep, well-drained soil. Neutral to alkaline pH preferred. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Cultivated fields and naturalized areas",
            description: "Small purple flowers in compact clusters with three-leaflet clover-like leaves",
            imagePrompt: "Medicago sativa alfalfa with small purple flower clusters, three-leaflet leaves, deep taproot system"
        ),
        
        BotanicalSpecies(
            scientificName: "Spartium junceum",
            commonNames: ["Spanish Broom", "Weaver's Broom", "Rush Broom"],
            family: "Fabaceae",
            nativeRegions: ["Mediterranean Basin"],
            bloomingSeason: "Late spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Fiber production", "Erosion control"],
            interestingFacts: [
                "Fibers from stems were used to make cloth and rope",
                "Extremely drought tolerant once established",
                "Flowers have intense sweet fragrance",
                "Can grow in very poor, rocky soils"
            ],
            careInstructions: "Poor, well-drained soil preferred. Full sun. Very low water needs once established.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Mediterranean scrublands and hillsides",
            description: "Bright yellow fragrant pea-like flowers on rush-like green stems",
            imagePrompt: "Spartium junceum Spanish broom with bright yellow fragrant flowers, rush-like green stems, Mediterranean native"
        ),
        
        BotanicalSpecies(
            scientificName: "Coronilla varia",
            commonNames: ["Crown Vetch", "Axseed", "Purple Crown Vetch"],
            family: "Fabaceae",
            nativeRegions: ["Europe", "Southwest Asia", "North Africa"],
            bloomingSeason: "Late spring to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Erosion control", "Ground cover", "Wildlife habitat"],
            interestingFacts: [
                "Extensively used for highway slope stabilization",
                "Forms dense mats that exclude other vegetation",
                "Flowers arranged in crown-like clusters",
                "Can spread aggressively through rhizomes and seeds"
            ],
            careInstructions: "Adapts to poor soils. Full sun to partial shade. Very drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa],
            habitat: "Roadsides, slopes, and disturbed areas",
            description: "Pink and white flowers arranged in crown-like clusters with compound leaves",
            imagePrompt: "Coronilla varia crown vetch with pink white crown-like flower clusters, compound leaves, ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Hedysarum coronarium",
            commonNames: ["Sulla", "French Honeysuckle", "Italian Sainfoin"],
            family: "Fabaceae",
            nativeRegions: ["Mediterranean Basin"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Livestock feed", "Soil improvement", "Ornamental"],
            interestingFacts: [
                "Important forage crop in Mediterranean agriculture",
                "Flowers are excellent source of nectar for bees",
                "Can grow in saline and alkaline soils",
                "Self-reseeding annual that can act like perennial"
            ],
            careInstructions: "Well-drained soil, full sun. Tolerates poor and alkaline conditions.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Mediterranean grasslands and cultivated areas",
            description: "Dense spikes of bright red-purple pea-like flowers with pinnately compound leaves",
            imagePrompt: "Hedysarum coronarium sulla with dense spikes, bright red-purple pea flowers, pinnately compound leaves"
        ),
        
        // BRASSICACEAE (Crucifers)
        BotanicalSpecies(
            scientificName: "Brassica nigra",
            commonNames: ["Black Mustard", "Brown Mustard"],
            family: "Brassicaceae",
            nativeRegions: ["Mediterranean", "Southwest Asia"],
            bloomingSeason: "Spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Spice production", "Edible greens", "Cover crop", "Traditional medicine"],
            interestingFacts: [
                "Seeds are ground to make Dijon mustard",
                "Referenced in Biblical parable of the mustard seed",
                "Can grow up to 8 feet tall in ideal conditions",
                "Young leaves are edible and nutritious"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Tolerates poor soils. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Fields, roadsides, and waste areas",
            description: "Small bright yellow four-petaled flowers in terminal clusters above dark green leaves",
            imagePrompt: "Brassica nigra black mustard with small bright yellow four-petaled flowers, dark green leaves, tall stems"
        ),
        
        BotanicalSpecies(
            scientificName: "Matthiola incana",
            commonNames: ["Stock", "Common Stock", "Ten-week Stock"],
            family: "Brassicaceae",
            nativeRegions: ["Mediterranean", "Southern Europe"],
            bloomingSeason: "Spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Fragrance"],
            interestingFacts: [
                "Intensely fragrant, especially in evening",
                "Double-flowered forms are sterile and propagated by cuttings",
                "Name 'ten-week stock' refers to growing time from seed to flower",
                "Popular in Victorian gardens for their scent"
            ],
            careInstructions: "Cool, moist conditions. Rich, well-drained soil. Partial shade in hot climates.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Coastal cliffs and cultivated gardens",
            description: "Dense spikes of fragrant four-petaled flowers in purple, pink, or white",
            imagePrompt: "Matthiola incana stock with dense spikes, fragrant four-petaled flowers, purple pink white colors"
        ),
        
        BotanicalSpecies(
            scientificName: "Lunaria annua",
            commonNames: ["Honesty", "Money Plant", "Silver Dollar"],
            family: "Brassicaceae",
            nativeRegions: ["Southeast Europe", "Southwest Asia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Dried flower arrangements", "Edible leaves"],
            interestingFacts: [
                "Grown primarily for its decorative seed pods",
                "Translucent seed pod membranes resemble silver coins",
                "Biennial that flowers in second year",
                "Young leaves are edible and taste like watercress"
            ],
            careInstructions: "Partial shade, moist well-drained soil. Self-seeds readily. Leave seed pods for decoration.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Woodland edges and cultivated gardens",
            description: "Purple or white four-petaled flowers followed by distinctive flat, round seed pods",
            imagePrompt: "Lunaria annua honesty with purple white flowers, distinctive flat round translucent seed pods, money plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Iberis umbellata",
            commonNames: ["Candytuft", "Globe Candytuft", "Umbrella Candytuft"],
            family: "Brassicaceae",
            nativeRegions: ["Southern Europe", "Mediterranean"],
            bloomingSeason: "Spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Rock gardens"],
            interestingFacts: [
                "Flowers are arranged in umbrella-like clusters",
                "Self-seeds readily and can bloom repeatedly",
                "Attracts butterflies and beneficial insects",
                "Cool weather extends blooming period"
            ],
            careInstructions: "Well-drained soil, full sun. Tolerates poor soils. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Rocky areas and cultivated gardens",
            description: "Dense clusters of small white, pink, or purple four-petaled flowers",
            imagePrompt: "Iberis umbellata candytuft with dense umbrella clusters, small white pink purple flowers, ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Alyssum maritimum",
            commonNames: ["Sweet Alyssum", "Sweet Alison", "Seaside Lobularia"],
            family: "Brassicaceae",
            nativeRegions: ["Mediterranean", "Canary Islands"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Edging", "Container gardens", "Fragrance"],
            interestingFacts: [
                "Flowers have honey-like fragrance",
                "Blooms almost continuously in cool weather",
                "Self-seeds prolifically in suitable conditions",
                "Popular with beneficial insects"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Cut back mid-season for repeat blooming.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Coastal areas and cultivated gardens",
            description: "Masses of tiny white or purple flowers with honey-like fragrance",
            imagePrompt: "Alyssum maritimum sweet alyssum with masses of tiny white purple flowers, honey fragrance, ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Erysimum cheiri",
            commonNames: ["Wallflower", "English Wallflower", "Gillyflower"],
            family: "Brassicaceae",
            nativeRegions: ["Southern Europe", "Mediterranean"],
            bloomingSeason: "Spring to early summer",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Traditional medicine", "Fragrance"],
            interestingFacts: [
                "Name comes from growing in walls and rocky crevices",
                "Flowers have spicy, sweet fragrance",
                "Symbol of faithfulness in adversity",
                "Can survive in very poor, alkaline soils"
            ],
            careInstructions: "Well-drained, alkaline soil. Full sun. Excellent drainage essential.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Walls, cliffs, and rocky areas",
            description: "Fragrant four-petaled flowers in yellow, orange, red, or purple on woody stems",
            imagePrompt: "Erysimum cheiri wallflower with fragrant four-petaled flowers, yellow orange colors, growing in walls"
        ),
        
        BotanicalSpecies(
            scientificName: "Hesperis matronalis",
            commonNames: ["Dame's Rocket", "Sweet Rocket", "Damask Violet"],
            family: "Brassicaceae",
            nativeRegions: ["Eurasia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Naturalized plantings", "Fragrance"],
            interestingFacts: [
                "Fragrance is strongest in evening and night",
                "Often mistaken for wild phlox",
                "Can naturalize and spread in woodland areas",
                "Flowers are edible with peppery taste"
            ],
            careInstructions: "Partial shade, moist soil. Self-seeds readily. Can be aggressive spreader.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Woodland edges, roadsides, and naturalized areas",
            description: "Four-petaled flowers in purple, pink, or white with evening fragrance",
            imagePrompt: "Hesperis matronalis dame's rocket with four-petaled purple pink flowers, evening fragrance, woodland edges"
        ),
        
        BotanicalSpecies(
            scientificName: "Cardamine pratensis",
            commonNames: ["Cuckoo Flower", "Lady's Smock", "Mayflower"],
            family: "Brassicaceae",
            nativeRegions: ["Europe", "Northern Asia"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Edible greens", "Naturalized plantings"],
            interestingFacts: [
                "Named for blooming when cuckoos return in spring",
                "Important host plant for orange-tip butterfly",
                "Leaves have watercress-like flavor",
                "Forms colonies in wet meadows"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Naturalizes well in suitable conditions.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Wet meadows, stream sides, and woodland clearings",
            description: "Delicate pale pink or white four-petaled flowers on slender stems",
            imagePrompt: "Cardamine pratensis cuckoo flower with delicate pale pink white flowers, wet meadow habitat, spring blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Diplotaxis muralis",
            commonNames: ["Wall Rocket", "Annual Wall Rocket"],
            family: "Brassicaceae",
            nativeRegions: ["Mediterranean", "Western Europe"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Edible greens", "Wild food", "Urban wildlife habitat"],
            interestingFacts: [
                "Thrives in urban environments and waste places",
                "Leaves have strong peppery flavor like arugula",
                "Can bloom almost year-round in mild climates",
                "Pioneer species in disturbed soils"
            ],
            careInstructions: "Adapts to poor, disturbed soils. Full sun. Very drought tolerant.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Walls, waste ground, and urban areas",
            description: "Small bright yellow four-petaled flowers on branched stems with lobed leaves",
            imagePrompt: "Diplotaxis muralis wall rocket with small bright yellow flowers, branched stems, urban waste ground"
        ),
        
        BotanicalSpecies(
            scientificName: "Crambe maritima",
            commonNames: ["Sea Kale", "Sea Cabbage", "Scurvy Grass"],
            family: "Brassicaceae",
            nativeRegions: ["Atlantic Coasts of Europe"],
            bloomingSeason: "Early summer",
            conservationStatus: "Near Threatened",
            uses: ["Edible vegetable", "Ornamental", "Coastal gardens"],
            interestingFacts: [
                "Young shoots were traditionally eaten as vegetable",
                "Extremely salt tolerant and wind resistant",
                "Can survive being completely buried by sand",
                "Declining due to coastal development"
            ],
            careInstructions: "Well-drained, sandy soil. Full sun. Excellent drainage essential. Salt tolerant.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Coastal beaches and cliffs",
            description: "Large clusters of white fragrant flowers above blue-green wavy leaves",
            imagePrompt: "Crambe maritima sea kale with large white fragrant flower clusters, blue-green wavy leaves, coastal habitat"
        ),
        
        BotanicalSpecies(
            scientificName: "Cheiranthus allionii",
            commonNames: ["Siberian Wallflower", "Orange Wallflower"],
            family: "Brassicaceae",
            nativeRegions: ["Eastern Europe", "Western Asia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Rock gardens", "Spring bedding"],
            interestingFacts: [
                "Hardier than English wallflower",
                "Flowers have sweet, spicy fragrance",
                "Excellent for early season color",
                "Often grown as biennial for best display"
            ],
            careInstructions: "Well-drained soil, full sun. Hardy and drought tolerant once established.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia],
            habitat: "Rocky areas and mountain slopes",
            description: "Bright orange four-petaled fragrant flowers in dense terminal clusters",
            imagePrompt: "Cheiranthus allionii Siberian wallflower with bright orange fragrant flowers, dense terminal clusters, rock gardens"
        ),
        
        BotanicalSpecies(
            scientificName: "Arabis alpina",
            commonNames: ["Alpine Rock Cress", "Mountain Rock Cress", "White Arabis"],
            family: "Brassicaceae",
            nativeRegions: ["Mountains of Europe", "Asia", "North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Rock gardens", "Alpine gardens", "Ground cover"],
            interestingFacts: [
                "Forms dense mats cascading over rocks",
                "Extremely hardy, surviving harsh mountain conditions",
                "Popular in traditional Alpine gardens",
                "Flowers attract early season pollinators"
            ],
            careInstructions: "Excellent drainage essential. Full sun to partial shade. Very hardy and drought tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Mountain slopes, rocky crevices, and alpine areas",
            description: "Dense clusters of white four-petaled flowers forming cascading mats",
            imagePrompt: "Arabis alpina alpine rock cress with white four-petaled flowers, cascading mats, rocky mountain habitat"
        ),
        
        // RANUNCULACEAE (Buttercups)
        BotanicalSpecies(
            scientificName: "Ranunculus acris",
            commonNames: ["Meadow Buttercup", "Tall Buttercup", "Common Buttercup"],
            family: "Ranunculaceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Late spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Traditional medicine", "Ornamental"],
            interestingFacts: [
                "Glossy petals reflect light due to special cells beneath surface",
                "Toxic to livestock but avoided due to bitter taste",
                "Symbol of children's games - held under chin to 'test' for butter liking",
                "Important early nectar source for many insects"
            ],
            careInstructions: "Moist, fertile soil. Full sun to partial shade. Can spread aggressively.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Meadows, pastures, and woodland edges",
            description: "Bright yellow cup-shaped flowers with glossy petals and deeply divided leaves",
            imagePrompt: "Ranunculus acris meadow buttercup with bright yellow glossy cup-shaped flowers, deeply divided leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Delphinium elatum",
            commonNames: ["Candle Larkspur", "Bee Larkspur", "Alpine Delphinium"],
            family: "Ranunculaceae",
            nativeRegions: ["Mountains of Europe"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Traditional medicine"],
            interestingFacts: [
                "Can grow up to 8 feet tall in ideal conditions",
                "All parts of plant are highly toxic",
                "Flowers have distinctive spur that gives name 'larkspur'",
                "Important parent of modern garden delphiniums"
            ],
            careInstructions: "Rich, moist soil. Full sun with some afternoon shade. Stake tall varieties.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Mountain meadows and alpine slopes",
            description: "Tall spikes of blue flowers with prominent spurs and deeply cut leaves",
            imagePrompt: "Delphinium elatum candle larkspur with tall blue flower spikes, prominent spurs, deeply cut leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Aconitum napellus",
            commonNames: ["Monkshood", "Wolfsbane", "Helmet Flower"],
            family: "Ranunculaceae",
            nativeRegions: ["Mountains of Europe"],
            bloomingSeason: "Late summer to autumn",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Historical medicine", "Research"],
            interestingFacts: [
                "One of the most poisonous plants in Europe",
                "Used historically as arrow poison",
                "Distinctive helmet-shaped flowers",
                "Important late-season nectar source for bumblebees"
            ],
            careInstructions: "Moist, rich soil. Partial shade preferred. Handle with extreme caution.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Mountain woods and damp meadows",
            description: "Dark blue helmet-shaped flowers on tall stems with deeply divided palmate leaves",
            imagePrompt: "Aconitum napellus monkshood with dark blue helmet-shaped flowers, deeply divided palmate leaves, mountain woods"
        ),
        
        BotanicalSpecies(
            scientificName: "Aquilegia vulgaris",
            commonNames: ["European Columbine", "Granny's Bonnet", "Common Columbine"],
            family: "Ranunculaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Name 'columbine' means dove-like, referring to flower shape",
                "Flowers have distinctive backward-pointing spurs",
                "Self-seeds readily and hybridizes easily",
                "Important nectar source for long-tongued moths"
            ],
            careInstructions: "Well-drained soil, partial shade. Self-seeds in suitable conditions.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Woodland clearings and mountain meadows",
            description: "Distinctive spurred flowers in blue, purple, pink, or white with compound blue-green leaves",
            imagePrompt: "Aquilegia vulgaris European columbine with spurred flowers, blue purple colors, compound blue-green leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Clematis vitalba",
            commonNames: ["Old Man's Beard", "Traveller's Joy", "Virgin's Bower"],
            family: "Ranunculaceae",
            nativeRegions: ["Europe", "Northwest Africa", "Southwest Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Ornamental", "Traditional crafts"],
            interestingFacts: [
                "Produces fluffy seed heads that persist through winter",
                "Can smother trees and shrubs if left unchecked",
                "Stems were used historically to make rope",
                "Important late-season nectar source"
            ],
            careInstructions: "Any well-drained soil. Full sun to partial shade. Can be very vigorous.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Woodland edges, hedgerows, and scrubland",
            description: "Masses of small creamy-white fragrant flowers followed by fluffy seed heads",
            imagePrompt: "Clematis vitalba old man's beard with masses of small creamy-white flowers, fluffy seed heads, climbing vine"
        ),
        
        BotanicalSpecies(
            scientificName: "Trollius europaeus",
            commonNames: ["European Globeflower", "Globe Buttercup"],
            family: "Ranunculaceae",
            nativeRegions: ["Northern Europe", "Mountains of Central Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Wildlife habitat", "Traditional medicine"],
            interestingFacts: [
                "Flowers remain partially closed, forming globe shape",
                "Declining in wild due to habitat loss",
                "Specialized pollination by small flies trapped inside flowers",
                "Symbol of several European mountain regions"
            ],
            careInstructions: "Moist, rich soil. Cool conditions preferred. Partial shade tolerated.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Mountain meadows and stream sides",
            description: "Globe-shaped bright yellow flowers with overlapping petals",
            imagePrompt: "Trollius europaeus European globeflower with globe-shaped bright yellow flowers, overlapping petals, mountain meadows"
        ),
        
        BotanicalSpecies(
            scientificName: "Hepatica nobilis",
            commonNames: ["Liverleaf", "Common Hepatica", "Kidneywort"],
            family: "Ranunculaceae",
            nativeRegions: ["Europe", "Asia", "Eastern North America"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Ornamental", "Spring gardens"],
            interestingFacts: [
                "One of the earliest spring flowers to bloom",
                "Leaves are three-lobed, resembling liver shape",
                "Flowers appear before new leaves emerge",
                "Important early nectar source for emerging insects"
            ],
            careInstructions: "Rich, well-drained soil. Partial to full shade. Prefers alkaline conditions.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Deciduous woodlands and forest floors",
            description: "Delicate blue, pink, or white flowers with three-lobed evergreen leaves",
            imagePrompt: "Hepatica nobilis liverleaf with delicate blue pink flowers, three-lobed evergreen leaves, early spring blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Nigella damascena",
            commonNames: ["Love-in-a-mist", "Fennel Flower", "Devil-in-the-bush"],
            family: "Ranunculaceae",
            nativeRegions: ["Southern Europe", "North Africa", "Southwest Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Dried flower arrangements", "Traditional medicine"],
            interestingFacts: [
                "Flowers surrounded by feathery bracts creating 'mist' effect",
                "Seeds are edible and used as spice",
                "Self-seeds readily in suitable conditions",
                "Popular in cottage gardens for centuries"
            ],
            careInstructions: "Well-drained soil, full sun. Self-seeds best when not disturbed.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Cultivated gardens and naturalized areas",
            description: "Blue, pink, or white flowers surrounded by feathery green bracts",
            imagePrompt: "Nigella damascena love-in-a-mist with blue flowers surrounded by feathery green bracts, cottage garden favorite"
        ),
        
        BotanicalSpecies(
            scientificName: "Pulsatilla vulgaris",
            commonNames: ["Pasque Flower", "Easter Flower", "Wind Flower"],
            family: "Ranunculaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Early spring",
            conservationStatus: "Near Threatened",
            uses: ["Ornamental", "Traditional medicine", "Rock gardens"],
            interestingFacts: [
                "Blooms around Easter time (Pasque)",
                "Flowers covered in silky hairs for protection from cold",
                "Declining due to habitat loss and over-collection",
                "Seeds have feathery plumes for wind dispersal"
            ],
            careInstructions: "Well-drained, alkaline soil. Full sun. Excellent drainage essential.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Chalk grasslands and limestone hills",
            description: "Purple cup-shaped flowers covered in silky hairs with feathery seed heads",
            imagePrompt: "Pulsatilla vulgaris pasque flower with purple cup-shaped silky hairy flowers, feathery seed heads, Easter blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Anemone nemorosa",
            commonNames: ["Wood Anemone", "Windflower", "European Thimbleweed"],
            family: "Ranunculaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Naturalizing", "Woodland gardens"],
            interestingFacts: [
                "Forms carpets in ancient woodlands",
                "Flowers close on cloudy days and at night",
                "Spreads by underground rhizomes",
                "Indicator species of ancient woodland"
            ],
            careInstructions: "Moist, rich soil. Partial to full shade. Dies back in summer.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Deciduous woodlands and forest floors",
            description: "Simple white flowers with yellow centers above divided leaves",
            imagePrompt: "Anemone nemorosa wood anemone with simple white flowers, yellow centers, divided leaves, woodland carpets"
        ),
        
        // MORE ROSACEAE
        BotanicalSpecies(
            scientificName: "Prunus dulcis",
            commonNames: ["Almond", "Sweet Almond", "Common Almond"],
            family: "Rosaceae",
            nativeRegions: ["Mediterranean", "Southwest Asia"],
            bloomingSeason: "Late winter to early spring",
            conservationStatus: "Least Concern",
            uses: ["Nut production", "Ornamental", "Oil production"],
            interestingFacts: [
                "Flowers appear before leaves in spring",
                "California produces 80% of world's almonds",
                "Related to peaches, plums, and cherries",
                "Symbol of hope and new beginnings in many cultures"
            ],
            careInstructions: "Well-drained soil, full sun. Needs chilling hours for proper flowering.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Mediterranean hillsides and cultivated orchards",
            description: "Pink or white five-petaled flowers on bare branches before leaves emerge",
            imagePrompt: "Prunus dulcis almond with pink white five-petaled flowers, bare branches, early spring blooming before leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Malus domestica",
            commonNames: ["Apple", "Common Apple", "Domestic Apple"],
            family: "Rosaceae",
            nativeRegions: ["Central Asia", "Kazakhstan"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Fruit production", "Ornamental", "Cider making"],
            interestingFacts: [
                "Over 7,500 cultivars exist worldwide",
                "Flowers must be cross-pollinated for fruit production",
                "Origin of phrase 'an apple a day keeps doctor away'",
                "Apple wood produces excellent smoking flavor for meats"
            ],
            careInstructions: "Well-drained soil, full sun. Regular pruning needed for best fruit production.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Temperate regions and cultivated orchards",
            description: "Pink-budded flowers opening to white or pink five-petaled blooms",
            imagePrompt: "Malus domestica apple with pink-budded flowers opening to white pink blooms, orchard trees, spring blossoms"
        ),
        
        BotanicalSpecies(
            scientificName: "Crataegus monogyna",
            commonNames: ["Common Hawthorn", "May Tree", "Whitethorn"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Northwest Africa", "Western Asia"],
            bloomingSeason: "Late spring",
            conservationStatus: "Least Concern",
            uses: ["Hedging", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Traditional May Day flower in European folklore",
                "Important food source for over 150 insect species",
                "Used in traditional heart medicine",
                "Can live for several hundred years"
            ],
            careInstructions: "Adapts to most soils. Full sun to partial shade. Very hardy and drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Hedgerows, woodland edges, and scrubland",
            description: "Clusters of small white flowers with red stamens followed by red berries",
            imagePrompt: "Crataegus monogyna common hawthorn with clusters of small white flowers, red stamens, red berries, hedgerow"
        ),
        
        BotanicalSpecies(
            scientificName: "Spiraea japonica",
            commonNames: ["Japanese Spirea", "Japanese Meadowsweet"],
            family: "Rosaceae",
            nativeRegions: ["Japan", "Korea", "China"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Landscaping", "Cut flowers"],
            interestingFacts: [
                "Flowers attract butterflies and beneficial insects",
                "Very hardy and tolerates pollution",
                "Leaves often have colorful spring and fall foliage",
                "Popular foundation plant in temperate gardens"
            ],
            careInstructions: "Adapts to various soils. Full sun for best flowering. Prune after blooming.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Mountain slopes and cultivated gardens",
            description: "Dense flat-topped clusters of tiny pink or white flowers",
            imagePrompt: "Spiraea japonica Japanese spirea with dense flat-topped clusters, tiny pink white flowers, summer blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Potentilla fruticosa",
            commonNames: ["Shrubby Cinquefoil", "Bush Cinquefoil", "Potentilla"],
            family: "Rosaceae",
            nativeRegions: ["Northern Hemisphere", "Arctic regions"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Erosion control", "Wildlife habitat"],
            interestingFacts: [
                "Extremely hardy, surviving temperatures to -40°F",
                "Blooms continuously from summer through frost",
                "Important nectar source in harsh climates",
                "Used in traditional medicine by many cultures"
            ],
            careInstructions: "Well-drained soil, full sun. Very drought tolerant once established.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Rocky slopes, meadows, and tundra",
            description: "Bright yellow five-petaled flowers on low spreading shrubs with small compound leaves",
            imagePrompt: "Potentilla fruticosa shrubby cinquefoil with bright yellow five-petaled flowers, low spreading shrub, compound leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Filipendula ulmaria",
            commonNames: ["Meadowsweet", "Queen of the Meadow", "Bridewort"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Flavoring", "Wildlife habitat"],
            interestingFacts: [
                "Source of salicylic acid, precursor to aspirin",
                "Flowers have sweet almond-like fragrance",
                "Used to flavor mead and other beverages",
                "Important nectar source for many insects"
            ],
            careInstructions: "Moist soil preferred. Tolerates partial shade. Can spread in suitable conditions.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Wet meadows, stream banks, and marshes",
            description: "Creamy-white frothy flower clusters above divided leaves",
            imagePrompt: "Filipendula ulmaria meadowsweet with creamy-white frothy flower clusters, divided leaves, wet meadow habitat"
        ),
        
        BotanicalSpecies(
            scientificName: "Geum urbanum",
            commonNames: ["Wood Avens", "Herb Bennet", "Colewort"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Southwest Asia"],
            bloomingSeason: "Late spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Wild food", "Ground cover"],
            interestingFacts: [
                "Roots smell like cloves when crushed",
                "Seeds have hooked structures that attach to clothing",
                "Used historically as substitute for cloves",
                "Indicator of nitrogen-rich soils"
            ],
            careInstructions: "Moist, rich soil. Partial shade preferred. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Woodland edges, hedgerows, and shaded areas",
            description: "Small yellow five-petaled flowers followed by burr-like seed heads",
            imagePrompt: "Geum urbanum wood avens with small yellow five-petaled flowers, burr-like seed heads, woodland shade"
        ),
        
        BotanicalSpecies(
            scientificName: "Rubus idaeus",
            commonNames: ["Red Raspberry", "European Raspberry"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Northern Asia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Fruit production", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Canes are biennial - grow first year, fruit second year",
                "Rich in vitamins, antioxidants, and fiber",
                "Leaves used in traditional women's health teas",
                "Important food source for birds and mammals"
            ],
            careInstructions: "Well-drained, slightly acidic soil. Full sun to partial shade. Support canes.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Woodland clearings, forest edges, and cultivated gardens",
            description: "Small white five-petaled flowers followed by red aggregate berries",
            imagePrompt: "Rubus idaeus red raspberry with small white five-petaled flowers, red aggregate berries, thorny canes"
        ),
        
        BotanicalSpecies(
            scientificName: "Pyrus communis",
            commonNames: ["European Pear", "Common Pear"],
            family: "Rosaceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Fruit production", "Ornamental", "Wood products"],
            interestingFacts: [
                "Flowers appear before or with emerging leaves",
                "Over 3,000 cultivars exist worldwide",
                "Pear wood is prized for woodworking and instruments",
                "Symbol of longevity in many cultures"
            ],
            careInstructions: "Well-drained soil, full sun. Cross-pollination often needed for fruit.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Temperate forests and cultivated orchards",
            description: "Clusters of white five-petaled flowers with prominent stamens",
            imagePrompt: "Pyrus communis European pear with clusters of white five-petaled flowers, prominent stamens, orchard trees"
        ),
        
        // MORE MALVACEAE (Hibiscus Family)  
        BotanicalSpecies(
            scientificName: "Althaea officinalis",
            commonNames: ["Marshmallow", "White Mallow", "Common Marshmallow"],
            family: "Malvaceae",
            nativeRegions: ["Europe", "Western Asia", "North Africa"],
            bloomingSeason: "Summer to early autumn",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Food", "Ornamental"],
            interestingFacts: [
                "Original source of marshmallow confection",
                "Roots contain mucilage used for soothing remedies",
                "All parts of plant are edible",
                "Important nectar source for late-season pollinators"
            ],
            careInstructions: "Moist soil preferred. Full sun to partial shade. Salt tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .africa],
            habitat: "Salt marshes, wet meadows, and stream banks",
            description: "Pale pink five-petaled flowers with prominent stamens and soft, velvety leaves",
            imagePrompt: "Althaea officinalis marshmallow with pale pink five-petaled flowers, prominent stamens, soft velvety leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Malva sylvestris",
            commonNames: ["Common Mallow", "High Mallow", "Cheeseweed"],
            family: "Malvaceae",
            nativeRegions: ["Europe", "North Africa", "Asia"],
            bloomingSeason: "Late spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Edible greens", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Young leaves and flowers are edible and nutritious",
                "Seeds in round pods resemble cheese wheels",
                "Used medicinally for over 2,000 years",
                "Can bloom continuously for months"
            ],
            careInstructions: "Adapts to most soils. Full sun to partial shade. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Waste ground, roadsides, and disturbed areas",
            description: "Pink to purple five-petaled flowers with dark veining and heart-shaped leaves",
            imagePrompt: "Malva sylvestris common mallow with pink purple five-petaled flowers, dark veining, heart-shaped leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Lavatera trimestris",
            commonNames: ["Annual Mallow", "Rose Mallow", "Royal Mallow"],
            family: "Malvaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Butterfly gardens"],
            interestingFacts: [
                "Fast-growing annual that blooms quickly from seed",
                "Flowers attract butterflies and hummingbirds",
                "Heat and drought tolerant once established",
                "Named after Swiss naturalist brothers Lavater"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant. Self-seeds in suitable conditions.",
            rarityLevel: .common,
            continents: [.europe],
            habitat: "Mediterranean gardens and naturalized areas",
            description: "Large funnel-shaped pink or white flowers with silky petals",
            imagePrompt: "Lavatera trimestris annual mallow with large funnel-shaped pink white flowers, silky petals, fast-growing"
        ),
        
        BotanicalSpecies(
            scientificName: "Alcea rosea",
            commonNames: ["Hollyhock", "Garden Hollyhock", "Common Hollyhock"],
            family: "Malvaceae",
            nativeRegions: ["China", "Southwest Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional medicine", "Cottage gardens"],
            interestingFacts: [
                "Can grow up to 9 feet tall in ideal conditions",
                "Symbol of cottage gardens and rural life",
                "Flowers grow in tall spikes against walls and fences",
                "Self-seeds readily and can become perennial"
            ],
            careInstructions: "Well-drained soil, full sun. Protect from strong winds. Often grown as biennial.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Cultivated gardens and naturalized areas",
            description: "Large papery flowers in tall spikes, colors ranging from white to deep red",
            imagePrompt: "Alcea rosea hollyhock with large papery flowers, tall spikes, cottage garden favorite, various colors"
        ),
        
        BotanicalSpecies(
            scientificName: "Abutilon theophrasti",
            commonNames: ["Velvetleaf", "Indian Mallow", "Buttonweed"],
            family: "Malvaceae",
            nativeRegions: ["India", "China"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Fiber production", "Traditional medicine", "Wildlife habitat"],
            interestingFacts: [
                "Large heart-shaped leaves feel like velvet",
                "Historically grown for strong bast fiber",
                "Considered agricultural weed in many regions",
                "Seeds can remain viable in soil for decades"
            ],
            careInstructions: "Adapts to various soils. Full sun preferred. Can be invasive.",
            rarityLevel: .common,
            continents: [.asia],
            habitat: "Agricultural fields and disturbed ground",
            description: "Small yellow five-petaled flowers and large velvety heart-shaped leaves",
            imagePrompt: "Abutilon theophrasti velvetleaf with small yellow flowers, large velvety heart-shaped leaves, agricultural areas"
        ),
        
        BotanicalSpecies(
            scientificName: "Hibiscus trionum",
            commonNames: ["Flower-of-an-hour", "Venice Mallow", "Bladder Hibiscus"],
            family: "Malvaceae",
            nativeRegions: ["Mediterranean", "Africa", "Asia"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Wildlife habitat"],
            interestingFacts: [
                "Flowers open in morning and close by afternoon",
                "Seed pods are inflated and papery",
                "Self-seeds prolifically in suitable conditions",
                "Attracts bees and other beneficial insects"
            ],
            careInstructions: "Well-drained soil, full sun. Very drought tolerant. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia],
            habitat: "Waste ground, fields, and disturbed areas",
            description: "Pale yellow flowers with dark centers that last only one day",
            imagePrompt: "Hibiscus trionum flower-of-an-hour with pale yellow flowers, dark centers, inflated seed pods, one-day blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Kosteletzkya virginica",
            commonNames: ["Seashore Mallow", "Virginia Saltmarsh Mallow"],
            family: "Malvaceae",
            nativeRegions: ["Eastern United States", "Atlantic Coast"],
            bloomingSeason: "Late summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Salt-tolerant landscaping", "Wildlife habitat"],
            interestingFacts: [
                "Extremely salt tolerant, grows in brackish marshes",
                "Important nectar source for migrating butterflies",
                "Can survive periodic saltwater flooding",
                "Part of important coastal ecosystem"
            ],
            careInstructions: "Moist to wet soil, full sun. Salt tolerant. Excellent for rain gardens.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Salt marshes, brackish wetlands, and coastal areas",
            description: "Pink five-petaled flowers with prominent stamens on tall stems in marsh habitat",
            imagePrompt: "Kosteletzkya virginica seashore mallow with pink five-petaled flowers, prominent stamens, salt marsh habitat"
        ),
        
        // SOLANACEAE (Nightshades)
        BotanicalSpecies(
            scientificName: "Petunia axillaris",
            commonNames: ["Large White Petunia", "White Moon Petunia"],
            family: "Solanaceae",
            nativeRegions: ["South America", "Argentina", "Uruguay"],
            bloomingSeason: "Spring to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Garden bedding", "Container gardens"],
            interestingFacts: [
                "Flowers are fragrant at night to attract moths",
                "Parent species of most garden petunias",
                "Can bloom continuously for months",
                "Self-cleaning - old flowers fall off naturally"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Regular watering needed.",
            rarityLevel: .common,
            continents: [.southAmerica],
            habitat: "Grasslands and cultivated gardens",
            description: "Large white trumpet-shaped flowers with sweet evening fragrance",
            imagePrompt: "Petunia axillaris large white petunia with trumpet-shaped flowers, sweet evening fragrance, South American native"
        ),
        
        BotanicalSpecies(
            scientificName: "Datura stramonium",
            commonNames: ["Jimsonweed", "Thorn Apple", "Devil's Trumpet"],
            family: "Solanaceae",
            nativeRegions: ["Central America"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Research", "Wildlife habitat"],
            interestingFacts: [
                "All parts extremely toxic and hallucinogenic",
                "Large white trumpet flowers open at night",
                "Seed pods covered in sharp thorns",
                "Important plant in toxicology research"
            ],
            careInstructions: "Any well-drained soil, full sun. Self-seeds readily. Handle with extreme caution.",
            rarityLevel: .common,
            continents: [.northAmerica, .southAmerica],
            habitat: "Waste areas, roadsides, and disturbed ground",
            description: "Large white trumpet flowers and spiny seed pods with toxic properties",
            imagePrompt: "Datura stramonium jimsonweed with large white trumpet flowers, spiny seed pods, toxic nightshade family"
        ),
        
        BotanicalSpecies(
            scientificName: "Nicotiana alata",
            commonNames: ["Flowering Tobacco", "Jasmine Tobacco", "Winged Tobacco"],
            family: "Solanaceae",
            nativeRegions: ["South America", "Argentina"],
            bloomingSeason: "Summer to autumn",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Evening gardens", "Fragrance"],
            interestingFacts: [
                "Flowers open and become fragrant in evening",
                "Important nectar source for sphinx moths",
                "Can grow up to 5 feet tall",
                "Related to commercial tobacco but not smoked"
            ],
            careInstructions: "Moist, rich soil. Partial shade tolerated. Protect from strong winds.",
            rarityLevel: .common,
            continents: [.southAmerica],
            habitat: "Forest edges and cultivated gardens",
            description: "Long tubular white or pink flowers with sweet evening fragrance",
            imagePrompt: "Nicotiana alata flowering tobacco with long tubular white pink flowers, sweet evening fragrance, moth pollinated"
        ),
        
        BotanicalSpecies(
            scientificName: "Solanum dulcamara",
            commonNames: ["Bittersweet Nightshade", "Woody Nightshade", "Climbing Nightshade"],
            family: "Solanaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Wildlife habitat", "Ornamental berries"],
            interestingFacts: [
                "Climbing vine that can reach 12 feet",
                "Purple flowers followed by bright red berries",
                "All parts toxic, especially berries",
                "Important food source for birds in autumn"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Can be invasive in suitable climates.",
            rarityLevel: .common,
            continents: [.europe, .asia],
            habitat: "Woodland edges, hedgerows, and moist areas",
            description: "Purple star-shaped flowers with yellow stamens and bright red berries",
            imagePrompt: "Solanum dulcamara bittersweet nightshade with purple star-shaped flowers, yellow stamens, bright red berries, climbing vine"
        ),
        
        BotanicalSpecies(
            scientificName: "Physalis alkekengi",
            commonNames: ["Chinese Lantern", "Bladder Cherry", "Winter Cherry"],
            family: "Solanaceae",
            nativeRegions: ["Southern Europe", "Asia"],
            bloomingSeason: "Summer (decorative fruits in autumn)",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Dried arrangements", "Traditional medicine"],
            interestingFacts: [
                "Grown primarily for orange paper-like seed pods",
                "Pods persist through winter providing decoration",
                "Berries inside pods are edible when fully ripe",
                "Spreads by underground rhizomes"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Can spread aggressively.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia],
            habitat: "Woodland edges and cultivated gardens",
            description: "Small white flowers followed by distinctive orange papery lantern-like pods",
            imagePrompt: "Physalis alkekengi Chinese lantern with small white flowers, distinctive orange papery lantern pods, autumn decoration"
        ),
        
        BotanicalSpecies(
            scientificName: "Brunfelsia pauciflora",
            commonNames: ["Yesterday-Today-Tomorrow", "Morning-Noon-Night", "Kiss Me Quick"],
            family: "Solanaceae",
            nativeRegions: ["Brazil"],
            bloomingSeason: "Spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Fragrant gardens", "Container plants"],
            interestingFacts: [
                "Flowers change color from purple to white over 3 days",
                "Each plant has flowers in three different colors simultaneously",
                "Intensely fragrant, especially in evening",
                "All parts of plant are toxic"
            ],
            careInstructions: "Rich, well-drained soil. Partial shade preferred. Needs warm conditions.",
            rarityLevel: .rare,
            continents: [.southAmerica],
            habitat: "Tropical forests and cultivated gardens",
            description: "Tubular flowers that change from deep purple to lavender to white",
            imagePrompt: "Brunfelsia pauciflora yesterday-today-tomorrow with tubular flowers changing purple to lavender to white, fragrant tropical"
        ),
        
        BotanicalSpecies(
            scientificName: "Calibrachoa parviflora",
            commonNames: ["Mini Petunia", "Million Bells", "Trailing Petunia"],
            family: "Solanaceae",
            nativeRegions: ["South America"],
            bloomingSeason: "Spring to frost",
            conservationStatus: "Least Concern",
            uses: ["Container gardens", "Hanging baskets", "Ground cover"],
            interestingFacts: [
                "Produces hundreds of small petunia-like flowers",
                "Self-cleaning, no deadheading required",
                "Originally classified as Petunia species",
                "Excellent for continuous color displays"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Regular fertilization beneficial.",
            rarityLevel: .common,
            continents: [.southAmerica],
            habitat: "Rocky areas and cultivated gardens",
            description: "Masses of small petunia-like flowers in various colors with trailing habit",
            imagePrompt: "Calibrachoa parviflora mini petunia with masses of small petunia-like flowers, trailing habit, continuous blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Cestrum nocturnum",
            commonNames: ["Night-blooming Jasmine", "Lady of the Night", "Night-blooming Cestrum"],
            family: "Solanaceae",
            nativeRegions: ["Central America", "Caribbean"],
            bloomingSeason: "Year-round in tropical climates",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Fragrant gardens", "Traditional medicine"],
            interestingFacts: [
                "Flowers open at night with intense sweet fragrance",
                "Can perfume an entire garden from single plant",
                "Important pollinator plant for night-flying moths",
                "All parts of plant are toxic"
            ],
            careInstructions: "Rich, moist soil. Partial shade tolerated. Needs warm conditions year-round.",
            rarityLevel: .uncommon,
            continents: [.northAmerica, .southAmerica],
            habitat: "Tropical forests and cultivated gardens",
            description: "Small greenish-white tubular flowers with intense nighttime fragrance",
            imagePrompt: "Cestrum nocturnum night-blooming jasmine with small greenish-white tubular flowers, intense nighttime fragrance, tropical"
        ),
        
        // MARK: - Lamiaceae (Mint Family) - 20 species
        
        BotanicalSpecies(
            scientificName: "Lavandula angustifolia",
            commonNames: ["English Lavender", "True Lavender", "Common Lavender"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean", "Southern Europe"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Essential oils", "Culinary", "Medicinal", "Ornamental"],
            interestingFacts: [
                "Contains over 150 compounds in essential oil",
                "Used in ancient Egypt for mummification",
                "Bees prefer lavender over many other flowers",
                "Name derives from Latin 'lavare' meaning 'to wash'"
            ],
            careInstructions: "Well-drained soil, full sun, drought tolerant once established.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Mediterranean scrubland and cultivated gardens",
            description: "Dense spikes of purple-blue flowers with distinctive aromatic foliage",
            imagePrompt: "Lavandula angustifolia English lavender with purple-blue flower spikes, aromatic silver-green foliage, Mediterranean garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Rosmarinus officinalis",
            commonNames: ["Rosemary", "Garden Rosemary"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Ornamental", "Essential oils"],
            interestingFacts: [
                "Symbol of remembrance and fidelity",
                "Can live over 30 years in ideal conditions",
                "Flowers are edible and attract bees",
                "Evergreen shrub with needle-like leaves"
            ],
            careInstructions: "Well-drained soil, full sun, drought tolerant. Prune after flowering.",
            rarityLevel: .common,
            continents: [.europe, .africa, .northAmerica],
            habitat: "Mediterranean coastal areas and dry hillsides",
            description: "Small blue, purple, pink, or white flowers among needle-like aromatic leaves",
            imagePrompt: "Rosmarinus officinalis rosemary with small blue flowers, needle-like aromatic leaves, Mediterranean shrub"
        ),
        
        BotanicalSpecies(
            scientificName: "Salvia officinalis",
            commonNames: ["Garden Sage", "Common Sage", "Culinary Sage"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Ornamental"],
            interestingFacts: [
                "Name means 'to heal' in Latin",
                "Sacred to Romans who had special harvesting ceremonies",
                "Leaves have antimicrobial properties",
                "Perennial herb with woody stems"
            ],
            careInstructions: "Well-drained soil, full sun, avoid overwatering.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Mediterranean hillsides and herb gardens",
            description: "Purple-blue flowers in whorled spikes above grey-green textured leaves",
            imagePrompt: "Salvia officinalis garden sage with purple-blue flowers, grey-green textured leaves, Mediterranean herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Thymus vulgaris",
            commonNames: ["Common Thyme", "Garden Thyme", "English Thyme"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Ornamental"],
            interestingFacts: [
                "Contains thymol, a natural antiseptic",
                "Used by ancient Egyptians for embalming",
                "Symbol of courage in medieval times",
                "Low-growing perennial subshrub"
            ],
            careInstructions: "Well-drained soil, full sun, drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .africa, .northAmerica],
            habitat: "Rocky Mediterranean slopes and herb gardens",
            description: "Tiny pink to purple flowers in clusters above small aromatic leaves",
            imagePrompt: "Thymus vulgaris common thyme with tiny pink-purple flowers, small aromatic leaves, Mediterranean ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Ocimum basilicum",
            commonNames: ["Sweet Basil", "Genovese Basil", "Garden Basil"],
            family: "Lamiaceae",
            nativeRegions: ["India", "Southeast Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Aromatic", "Ornamental"],
            interestingFacts: [
                "Sacred plant in Hindu tradition",
                "Over 60 varieties exist worldwide",
                "Repels mosquitoes and flies naturally",
                "Annual herb that self-seeds readily"
            ],
            careInstructions: "Rich, moist soil. Full sun. Pinch flowers to encourage leaf growth.",
            rarityLevel: .common,
            continents: [.asia, .europe, .northAmerica, .africa],
            habitat: "Tropical regions and cultivated gardens",
            description: "Small white flowers in terminal spikes above bright green aromatic leaves",
            imagePrompt: "Ocimum basilicum sweet basil with white flower spikes, bright green aromatic leaves, culinary herb garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Mentha spicata",
            commonNames: ["Spearmint", "Garden Mint", "Common Mint"],
            family: "Lamiaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Aromatic"],
            interestingFacts: [
                "Spreads rapidly via underground runners",
                "Contains less menthol than peppermint",
                "Used in ancient Greece to flavor wines",
                "Natural mouse and ant deterrent"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Contain roots to prevent spread.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Moist meadows and stream banks",
            description: "Purple to pink flowers in terminal spikes above serrated aromatic leaves",
            imagePrompt: "Mentha spicata spearmint with purple-pink flower spikes, serrated aromatic leaves, spreading herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Origanum vulgare",
            commonNames: ["Wild Marjoram", "Oregano", "Mountain Mint"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean", "Europe"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Ornamental"],
            interestingFacts: [
                "Essential oil has strong antimicrobial properties",
                "Symbol of joy and happiness in ancient Greece",
                "Attracts beneficial insects to gardens",
                "Perennial herb forming spreading colonies"
            ],
            careInstructions: "Well-drained soil, full sun, drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Mediterranean hillsides and dry grasslands",
            description: "Clusters of small pink to purple flowers above oval aromatic leaves",
            imagePrompt: "Origanum vulgare wild marjoram oregano with pink-purple flower clusters, oval aromatic leaves, Mediterranean herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Salvia splendens",
            commonNames: ["Scarlet Sage", "Red Salvia", "Tropical Sage"],
            family: "Lamiaceae",
            nativeRegions: ["Brazil"],
            bloomingSeason: "Summer to frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers"],
            interestingFacts: [
                "Most popular annual salvia in cultivation",
                "Hummingbirds are primary pollinators",
                "Available in many colors beyond red",
                "Heat-loving tropical perennial grown as annual"
            ],
            careInstructions: "Rich, moist soil. Full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.southAmerica, .northAmerica],
            habitat: "Tropical forests and ornamental gardens",
            description: "Bright scarlet tubular flowers in dense terminal spikes",
            imagePrompt: "Salvia splendens scarlet sage with bright red tubular flowers, dense terminal spikes, tropical garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Monarda didyma",
            commonNames: ["Bee Balm", "Oswego Tea", "Scarlet Beebalm"],
            family: "Lamiaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Medicinal", "Herbal tea", "Native plant gardens"],
            interestingFacts: [
                "Used as tea substitute during Boston Tea Party",
                "Attracts hummingbirds, bees, and butterflies",
                "Natural source of thymol",
                "Spreads by underground rhizomes"
            ],
            careInstructions: "Moist, rich soil. Full sun to partial shade. Good air circulation.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Moist woodlands and stream banks",
            description: "Tubular scarlet flowers in distinctive crown-like clusters",
            imagePrompt: "Monarda didyma bee balm with scarlet tubular flowers in crown-like clusters, native wildflower"
        ),
        
        BotanicalSpecies(
            scientificName: "Nepeta cataria",
            commonNames: ["Catnip", "Catmint", "Catswort"],
            family: "Lamiaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Feline stimulant", "Medicinal", "Insect repellent"],
            interestingFacts: [
                "Contains nepetalactone that attracts cats",
                "More effective mosquito repellent than DEET",
                "Used historically to treat nervousness",
                "Not all cats respond to catnip"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Disturbed soils and waste areas",
            description: "Small white flowers with purple spots in loose spikes",
            imagePrompt: "Nepeta cataria catnip with small white flowers with purple spots, heart-shaped leaves, cat-attracting herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Coleus scutellarioides",
            commonNames: ["Painted Nettle", "Coleus", "Flame Nettle"],
            family: "Lamiaceae",
            nativeRegions: ["Southeast Asia"],
            bloomingSeason: "Summer (grown for foliage)",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Houseplant", "Container gardens"],
            interestingFacts: [
                "Over 600 named varieties exist",
                "Flowers are typically removed to promote foliage",
                "Heat-loving tropical perennial",
                "Leaves contain anthocyanins for color"
            ],
            careInstructions: "Rich, moist soil. Partial shade. Pinch flowers for best foliage.",
            rarityLevel: .common,
            continents: [.asia, .northAmerica, .europe],
            habitat: "Tropical forests and shade gardens",
            description: "Colorful variegated leaves in reds, greens, yellows, and purples",
            imagePrompt: "Coleus scutellarioides painted nettle with soft colorful variegated leaves, tropical foliage plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Prunella vulgaris",
            commonNames: ["Self-heal", "Heal-all", "Woundwort"],
            family: "Lamiaceae",
            nativeRegions: ["Europe", "Asia", "North America"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Edible", "Wildlife plant"],
            interestingFacts: [
                "Traditional wound healing herb",
                "Found on every continent except Antarctica",
                "Flowers close at night and in bad weather",
                "Low-growing perennial forming mats"
            ],
            careInstructions: "Adapts to most soils. Full sun to partial shade. Low maintenance.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Lawns, meadows, and disturbed areas",
            description: "Purple-blue flowers in dense cylindrical spikes",
            imagePrompt: "Prunella vulgaris self-heal with purple-blue flowers in cylindrical spikes, low-growing medicinal herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Lamium album",
            commonNames: ["White Dead-nettle", "White Archangel"],
            family: "Lamiaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Edible", "Ground cover"],
            interestingFacts: [
                "Young leaves are edible when cooked",
                "Important early nectar source for bees",
                "Doesn't sting despite nettle-like appearance",
                "Spreads by underground rhizomes"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Tolerates poor soil.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Hedgerows, waste ground, and woodland edges",
            description: "White hooded flowers in whorls around square stems",
            imagePrompt: "Lamium album white dead-nettle with white hooded flowers in whorls, heart-shaped serrated leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Ajuga reptans",
            commonNames: ["Bugleweed", "Carpet Bugle", "Common Bugleweed"],
            family: "Lamiaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Ornamental", "Medicinal"],
            interestingFacts: [
                "Forms dense mats via stolons",
                "Bronze-purple foliage varieties available",
                "Traditionally used to stop bleeding",
                "Tolerates foot traffic when established"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Spreads rapidly.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Woodland floors and shaded gardens",
            description: "Blue-purple flowers in upright spikes above bronze-green foliage",
            imagePrompt: "Ajuga reptans bugleweed with blue-purple flower spikes, bronze-green foliage, ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Stachys byzantina",
            commonNames: ["Lamb's Ear", "Woolly Betony", "Silver Carpet"],
            family: "Lamiaceae",
            nativeRegions: ["Turkey", "Armenia", "Iran"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Silver foliage"],
            interestingFacts: [
                "Leaves feel like soft velvet",
                "Silver-white hairs reflect heat and light",
                "Used historically as bandages",
                "Drought tolerant once established"
            ],
            careInstructions: "Well-drained soil, full sun. Remove flower spikes for best foliage.",
            rarityLevel: .common,
            continents: [.asia, .europe, .northAmerica],
            habitat: "Rocky slopes and Mediterranean gardens",
            description: "Soft, silvery-white woolly leaves with purple flower spikes",
            imagePrompt: "Stachys byzantina lamb's ear with soft silvery-white woolly leaves, purple flower spikes, silver foliage plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Marrubium vulgare",
            commonNames: ["White Horehound", "Common Horehound"],
            family: "Lamiaceae",
            nativeRegions: ["Europe", "Asia", "North Africa"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Herbal", "Cough remedy"],
            interestingFacts: [
                "Traditional cough drop ingredient",
                "Bitter taste deters grazing animals",
                "Perennial herb with woolly stems",
                "Spreads by seed and root division"
            ],
            careInstructions: "Well-drained soil, full sun, drought tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .africa, .northAmerica],
            habitat: "Waste ground and dry grasslands",
            description: "Small white flowers in dense whorls along woolly stems",
            imagePrompt: "Marrubium vulgare white horehound with small white flowers in whorls, woolly grey-green stems and leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Hyssopus officinalis",
            commonNames: ["Hyssop", "Garden Hyssop"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean", "Central Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Culinary", "Ornamental", "Essential oils"],
            interestingFacts: [
                "Mentioned in biblical texts for purification",
                "Semi-evergreen perennial subshrub",
                "Attracts bees and butterflies",
                "Used in liqueur production"
            ],
            careInstructions: "Well-drained soil, full sun, drought tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Rocky Mediterranean hillsides",
            description: "Dense spikes of blue, pink, or white flowers above narrow aromatic leaves",
            imagePrompt: "Hyssopus officinalis hyssop with blue flower spikes, narrow aromatic leaves, Mediterranean herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Melissa officinalis",
            commonNames: ["Lemon Balm", "Bee Balm", "Sweet Balm"],
            family: "Lamiaceae",
            nativeRegions: ["Mediterranean", "Central Europe"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Herbal tea", "Aromatherapy"],
            interestingFacts: [
                "Leaves smell like lemon when crushed",
                "Spreads rapidly by seed and runners",
                "Traditional remedy for anxiety",
                "Attracts beneficial insects"
            ],
            careInstructions: "Moist, rich soil. Partial shade to full sun. Control spread.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodland edges and herb gardens",
            description: "Small white flowers in loose clusters above lemon-scented leaves",
            imagePrompt: "Melissa officinalis lemon balm with small white flowers, lemon-scented serrated leaves, aromatic herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Leonurus cardiaca",
            commonNames: ["Motherwort", "Lion's Tail", "Heart Medicine"],
            family: "Lamiaceae",
            nativeRegions: ["Central Asia", "Southeastern Europe"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Women's health", "Heart tonic"],
            interestingFacts: [
                "Traditional remedy for heart conditions",
                "Used historically in childbirth",
                "Perennial with deeply lobed leaves",
                "Self-seeds readily in disturbed soil"
            ],
            careInstructions: "Adapts to most soils. Full sun to partial shade. Low maintenance.",
            rarityLevel: .uncommon,
            continents: [.asia, .europe, .northAmerica],
            habitat: "Waste areas and disturbed ground",
            description: "Pink to white flowers in dense whorls along tall stems",
            imagePrompt: "Leonurus cardiaca motherwort with pink-white flowers in whorls, deeply lobed leaves, medicinal herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Scutellaria lateriflora",
            commonNames: ["Skullcap", "Mad Dog Skullcap", "Blue Skullcap"],
            family: "Lamiaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Nervine", "Anxiety relief"],
            interestingFacts: [
                "Traditional Native American medicine",
                "Flowers resemble tiny skulls with caps",
                "Used historically for rabies treatment",
                "Perennial with spreading rhizomes"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Prefers woodland conditions.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Moist woodlands and stream banks",
            description: "Small blue flowers in one-sided racemes",
            imagePrompt: "Scutellaria lateriflora skullcap with small blue flowers in racemes, serrated leaves, woodland herb"
        ),
        
        // MARK: - Apiaceae (Carrot Family) - 15 species
        
        BotanicalSpecies(
            scientificName: "Daucus carota",
            commonNames: ["Wild Carrot", "Queen Anne's Lace", "Bird's Nest"],
            family: "Apiaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Edible root", "Medicinal", "Ornamental", "Wildlife food"],
            interestingFacts: [
                "Ancestor of cultivated carrots",
                "Often has single dark purple floret in center",
                "Flowers close into bird's nest shape",
                "Biennial with edible taproot first year"
            ],
            careInstructions: "Well-drained soil, full sun. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Fields, roadsides, and disturbed areas",
            description: "Flat-topped white flower clusters with lacy appearance",
            imagePrompt: "Daucus carota wild carrot Queen Anne's lace with flat white flower clusters, lacy delicate appearance"
        ),
        
        BotanicalSpecies(
            scientificName: "Foeniculum vulgare",
            commonNames: ["Fennel", "Sweet Fennel", "Florence Fennel"],
            family: "Apiaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Spice", "Ornamental"],
            interestingFacts: [
                "All parts of plant are edible",
                "Seeds used as spice and digestive aid",
                "Can grow 6 feet tall",
                "Attracts beneficial insects"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.europe, .africa, .northAmerica],
            habitat: "Mediterranean coastal areas",
            description: "Bright yellow flowers in large flat-topped umbels",
            imagePrompt: "Foeniculum vulgare fennel with bright yellow flower umbels, feathery foliage, tall aromatic herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Petroselinum crispum",
            commonNames: ["Parsley", "Garden Parsley", "Common Parsley"],
            family: "Apiaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Second year summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Garnish"],
            interestingFacts: [
                "Biennial herb usually grown as annual",
                "Rich in vitamins A, C, and K",
                "Flat-leaf variety more flavorful than curly",
                "Ancient Greeks associated with death"
            ],
            careInstructions: "Rich, moist soil. Partial shade to full sun. Regular watering.",
            rarityLevel: .common,
            continents: [.europe, .africa, .northAmerica],
            habitat: "Herb gardens and rocky areas",
            description: "Small yellowish-green flowers in compound umbels",
            imagePrompt: "Petroselinum crispum parsley with small yellowish-green flower umbels, bright green curly or flat leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Coriandrum sativum",
            commonNames: ["Coriander", "Cilantro", "Chinese Parsley"],
            family: "Apiaceae",
            nativeRegions: ["Mediterranean", "Middle East"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Spice", "Medicinal"],
            interestingFacts: [
                "Leaves (cilantro) and seeds (coriander) used differently",
                "Genetic variation affects taste perception",
                "Annual herb that bolts in heat",
                "Seeds have citrusy, nutty flavor"
            ],
            careInstructions: "Rich, well-drained soil. Cool weather preferred. Succession plant.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa, .northAmerica],
            habitat: "Cultivated herb gardens",
            description: "Small white to pinkish flowers in compound umbels",
            imagePrompt: "Coriandrum sativum coriander cilantro with small white-pink flower umbels, delicate feathery leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Anethum graveolens",
            commonNames: ["Dill", "Dill Weed", "Garden Dill"],
            family: "Apiaceae",
            nativeRegions: ["Mediterranean", "Central Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Pickling spice", "Medicinal"],
            interestingFacts: [
                "Name comes from Norse word meaning 'to lull'",
                "Used historically to aid digestion",
                "Annual herb with feathery foliage",
                "Self-seeds readily in gardens"
            ],
            careInstructions: "Well-drained soil, full sun. Cool weather preferred for leaves.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Herb gardens and waste areas",
            description: "Bright yellow flowers in large flat umbels",
            imagePrompt: "Anethum graveolens dill with bright yellow flower umbels, fine feathery blue-green foliage"
        ),
        
        BotanicalSpecies(
            scientificName: "Carum carvi",
            commonNames: ["Caraway", "Persian Cumin"],
            family: "Apiaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Spice", "Culinary", "Medicinal", "Liqueur flavoring"],
            interestingFacts: [
                "Seeds used in rye bread and sauerkraut",
                "Biennial producing seeds second year",
                "Important ingredient in European cuisine",
                "Aids in digestion and reduces gas"
            ],
            careInstructions: "Well-drained soil, full sun. Cool, moist conditions preferred.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Meadows and cultivated fields",
            description: "Small white flowers in compound umbels",
            imagePrompt: "Carum carvi caraway with small white flower umbels, finely divided feathery leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Anthriscus cerefolium",
            commonNames: ["Chervil", "French Parsley", "Garden Chervil"],
            family: "Apiaceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Herb", "French cuisine"],
            interestingFacts: [
                "One of the classical French 'fines herbes'",
                "Delicate anise-like flavor",
                "Annual herb preferring cool weather",
                "Leaves lose flavor when dried"
            ],
            careInstructions: "Rich, moist soil. Partial shade. Cool weather preferred.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodland edges and herb gardens",
            description: "Small white flowers in delicate umbels",
            imagePrompt: "Anthriscus cerefolium chervil with small white delicate flower umbels, finely divided lacy leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Pastinaca sativa",
            commonNames: ["Wild Parsnip", "Common Parsnip"],
            family: "Apiaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Edible root", "Wildlife food"],
            interestingFacts: [
                "Ancestor of cultivated parsnips",
                "Biennial with edible taproot",
                "Can cause skin burns in sensitive people",
                "Important food source for wildlife"
            ],
            careInstructions: "Deep, well-drained soil. Full sun to partial shade.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Fields, roadsides, and disturbed areas",
            description: "Yellow flowers in large flat-topped umbels",
            imagePrompt: "Pastinaca sativa wild parsnip with yellow flower umbels, compound leaves, tall biennial herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Heracleum maximum",
            commonNames: ["Cow Parsnip", "American Cow Parsnip"],
            family: "Apiaceae",
            nativeRegions: ["North America"],
            bloomingSeason: "Late spring to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Traditional food", "Wildlife food", "Medicinal"],
            interestingFacts: [
                "Can grow 8-10 feet tall",
                "Largest member of carrot family in North America",
                "Young stems edible when cooked",
                "Important for native pollinators"
            ],
            careInstructions: "Moist, rich soil. Partial shade to full sun. Large space required.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Moist meadows and stream banks",
            description: "Large white flower umbels up to 8 inches across",
            imagePrompt: "Heracleum maximum cow parsnip with large white flower umbels, massive compound leaves, giant herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Angelica archangelica",
            commonNames: ["Garden Angelica", "Wild Celery", "Holy Ghost"],
            family: "Apiaceae",
            nativeRegions: ["Northern Europe", "Iceland"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Liqueur flavoring", "Candied stems"],
            interestingFacts: [
                "Can live 100+ years in ideal conditions",
                "Stems traditionally candied for desserts",
                "Important ingredient in gin and chartreuse",
                "Biennial to short-lived perennial"
            ],
            careInstructions: "Rich, moist soil. Partial shade. Cool, humid conditions.",
            rarityLevel: .rare,
            continents: [.europe, .northAmerica],
            habitat: "Moist meadows and stream banks",
            description: "Large white flower umbels on tall sturdy stems",
            imagePrompt: "Angelica archangelica garden angelica with large white flower umbels, tall stems, compound leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Cichorium intybus",
            commonNames: ["Chicory", "Blue Sailors", "Coffee Weed"],
            family: "Asteraceae",
            nativeRegions: ["Europe", "Western Asia", "North Africa"],
            bloomingSeason: "Summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Coffee substitute", "Edible greens", "Medicinal"],
            interestingFacts: [
                "Roots roasted as coffee substitute",
                "Flowers open in morning, close by noon",
                "Perennial with deep taproot",
                "Leaves bitter but nutritious when young"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa, .northAmerica],
            habitat: "Roadsides, fields, and waste areas",
            description: "Bright blue daisy-like flowers along tall stems",
            imagePrompt: "Cichorium intybus chicory with bright blue daisy-like flowers, tall branching stems, roadside plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Conium maculatum",
            commonNames: ["Poison Hemlock", "Spotted Hemlock", "Devil's Bread"],
            family: "Apiaceae",
            nativeRegions: ["Europe", "North Africa"],
            bloomingSeason: "Late spring to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["None - highly toxic"],
            interestingFacts: [
                "Extremely poisonous to humans and animals",
                "Used to execute Socrates in ancient Greece",
                "Biennial with purple-spotted stems",
                "Often confused with edible plants"
            ],
            careInstructions: "Grows in most conditions. Remove immediately if found.",
            rarityLevel: .uncommon,
            continents: [.europe, .africa, .northAmerica],
            habitat: "Disturbed areas, roadsides, and waste ground",
            description: "Small white flowers in compound umbels, purple-spotted stems",
            imagePrompt: "Conium maculatum poison hemlock with small white flower umbels, purple-spotted stems, toxic plant warning"
        ),
        
        BotanicalSpecies(
            scientificName: "Eryngium planum",
            commonNames: ["Blue Eryngo", "Flat Sea Holly"],
            family: "Apiaceae",
            nativeRegions: ["Europe", "Central Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Dried flowers", "Medicinal"],
            interestingFacts: [
                "Flowers and bracts turn metallic blue",
                "Excellent for dried arrangements",
                "Perennial with deep taproot",
                "Attracts butterflies and beneficial insects"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Dry grasslands and rocky slopes",
            description: "Metallic blue spiky flower heads surrounded by spiny bracts",
            imagePrompt: "Eryngium planum blue eryngo with metallic blue spiky flower heads, spiny bracts, architectural plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Pimpinella anisum",
            commonNames: ["Anise", "Aniseed", "Sweet Cumin"],
            family: "Apiaceae",
            nativeRegions: ["Eastern Mediterranean"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Spice", "Flavoring", "Medicinal", "Liqueur production"],
            interestingFacts: [
                "Seeds have distinctive licorice flavor",
                "Used in ouzo, pastis, and sambuca",
                "Annual herb requiring long growing season",
                "Different from star anise (unrelated plant)"
            ],
            careInstructions: "Rich, well-drained soil. Full sun. Warm conditions needed.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Cultivated herb gardens",
            description: "Small white flowers in compound umbels",
            imagePrompt: "Pimpinella anisum anise with small white flower umbels, feathery leaves, aromatic seed herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Levisticum officinale",
            commonNames: ["Lovage", "Garden Lovage", "Love Parsley"],
            family: "Apiaceae",
            nativeRegions: ["Southern Europe"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Culinary", "Medicinal", "Flavoring"],
            interestingFacts: [
                "Tastes like combination of celery and parsley",
                "Can grow 6-8 feet tall",
                "Perennial herb with thick stems",
                "All parts of plant are edible"
            ],
            careInstructions: "Rich, moist soil. Full sun to partial shade. Large space needed.",
            rarityLevel: .uncommon,
            continents: [.europe, .northAmerica],
            habitat: "Herb gardens and moist areas",
            description: "Yellow-green flowers in large compound umbels",
            imagePrompt: "Levisticum officinale lovage with yellow-green flower umbels, large compound leaves, tall herb"
        ),
        
        // MARK: - Violaceae (Violet Family) - 10 species
        
        BotanicalSpecies(
            scientificName: "Viola odorata",
            commonNames: ["Sweet Violet", "English Violet", "Common Violet"],
            family: "Violaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Edible flowers", "Perfume", "Medicinal"],
            interestingFacts: [
                "Flowers have distinctive sweet fragrance",
                "Symbol of modesty and faithfulness",
                "Spreads by runners and self-seeding",
                "Flowers and leaves are edible"
            ],
            careInstructions: "Moist, rich soil. Partial shade. Mulch in summer.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodland edges and shaded gardens",
            description: "Deep purple fragrant flowers with heart-shaped leaves",
            imagePrompt: "Viola odorata sweet violet with deep purple fragrant flowers, heart-shaped leaves, spring woodland"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola tricolor",
            commonNames: ["Wild Pansy", "Johnny Jump Up", "Heartsease"],
            family: "Violaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Medicinal", "Edible flowers"],
            interestingFacts: [
                "Ancestor of garden pansies",
                "Flowers have three colors: purple, white, and yellow",
                "Annual that self-seeds prolifically",
                "Traditional remedy for skin conditions"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Cool weather preferred.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Fields, gardens, and disturbed areas",
            description: "Small tricolored flowers with distinctive face-like markings",
            imagePrompt: "Viola tricolor wild pansy with small tricolored flowers, face-like markings, purple yellow white"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola cornuta",
            commonNames: ["Horned Violet", "Tufted Pansy", "Bedding Pansy"],
            family: "Violaceae",
            nativeRegions: ["Pyrenees"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Bedding plant", "Container gardens"],
            interestingFacts: [
                "Parent of modern pansy cultivars",
                "Perennial in mild climates",
                "Heat tolerant compared to other violets",
                "Available in wide range of colors"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Mountain meadows and gardens",
            description: "Small pansy-like flowers in various colors with short spurs",
            imagePrompt: "Viola cornuta horned violet with small pansy-like flowers, various colors, compact garden plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola canadensis",
            commonNames: ["Canada Violet", "Tall White Violet"],
            family: "Violaceae",
            nativeRegions: ["North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Woodland gardens", "Wildlife food"],
            interestingFacts: [
                "Tallest North American violet",
                "Flowers have yellow centers with purple backs",
                "Important food source for fritillary butterflies",
                "Perennial with underground rhizomes"
            ],
            careInstructions: "Rich, moist soil. Partial to full shade. Woodland conditions.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Rich woodlands and moist areas",
            description: "White flowers with yellow centers and purple-tinged backs",
            imagePrompt: "Viola canadensis Canada violet with white flowers, yellow centers, purple-tinged backs, woodland native"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola sororia",
            commonNames: ["Common Blue Violet", "Woolly Violet", "Confederate Violet"],
            family: "Violaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Early to mid-spring",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Ground cover", "Edible flowers and leaves"],
            interestingFacts: [
                "State flower of Illinois, Rhode Island, and Wisconsin",
                "Produces cleistogamous (closed) flowers for reproduction",
                "Young leaves high in vitamins A and C",
                "Spreads by underground rhizomes"
            ],
            careInstructions: "Adapts to most soils. Partial shade to full sun. Low maintenance.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Woodlands, lawns, and meadows",
            description: "Blue to purple flowers with white centers and bearded throats",
            imagePrompt: "Viola sororia common blue violet with blue-purple flowers, white centers, heart-shaped leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola pedata",
            commonNames: ["Bird's Foot Violet", "Crowfoot Violet"],
            family: "Violaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Rock gardens", "Specialty collections"],
            interestingFacts: [
                "Most distinctive violet due to deeply divided leaves",
                "Does not produce underground runners",
                "Upper petals are often darker than lower ones",
                "Requires specific soil conditions to thrive"
            ],
            careInstructions: "Sandy, well-drained, acidic soil. Full sun to light shade.",
            rarityLevel: .rare,
            continents: [.northAmerica],
            habitat: "Sandy woods and clearings",
            description: "Purple flowers with deeply divided bird's foot-shaped leaves",
            imagePrompt: "Viola pedata bird's foot violet with purple flowers, deeply divided bird-foot-shaped leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola reichenbachiana",
            commonNames: ["Early Dog Violet", "Pale Wood Violet"],
            family: "Violaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Early to mid-spring",
            conservationStatus: "Least Concern",
            uses: ["Woodland gardens", "Native plant gardens"],
            interestingFacts: [
                "One of earliest violets to bloom",
                "Scentless flowers unlike sweet violet",
                "Perennial forming small colonies",
                "Important early nectar source"
            ],
            careInstructions: "Moist, humus-rich soil. Partial to full shade.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Deciduous woodlands",
            description: "Pale purple flowers with distinctive spur and notched petals",
            imagePrompt: "Viola reichenbachiana early dog violet with pale purple flowers, woodland setting, spring blooming"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola lutea",
            commonNames: ["Mountain Pansy", "Yellow Violet"],
            family: "Violaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Alpine gardens", "Rock gardens", "Ornamental"],
            interestingFacts: [
                "Grows in high altitude conditions",
                "Flowers can be yellow, purple, or mixed",
                "Perennial adapted to harsh mountain conditions",
                "Short growing season due to altitude"
            ],
            careInstructions: "Well-drained, sandy soil. Full sun. Cool conditions preferred.",
            rarityLevel: .rare,
            continents: [.europe],
            habitat: "Mountain grasslands and rocky areas",
            description: "Bright yellow or purple pansy-like flowers",
            imagePrompt: "Viola lutea mountain pansy with bright yellow or purple flowers, alpine meadow, mountain setting"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola wittrockiana",
            commonNames: ["Garden Pansy", "Large-flowered Pansy"],
            family: "Violaceae",
            nativeRegions: ["Garden hybrid"],
            bloomingSeason: "Cool seasons (spring and fall)",
            conservationStatus: "Cultivated",
            uses: ["Ornamental", "Bedding plant", "Container gardens"],
            interestingFacts: [
                "Complex hybrid of several violet species",
                "Available in hundreds of color combinations",
                "Cool weather annual or short-lived perennial",
                "Face-like markings called 'blotch'"
            ],
            careInstructions: "Rich, moist soil. Cool weather. Full sun to partial shade.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica, .asia],
            habitat: "Cultivated gardens and containers",
            description: "Large flat flowers with distinctive face-like patterns in many colors",
            imagePrompt: "Viola wittrockiana garden pansy with large flat flowers, face-like patterns, multiple colors"
        ),
        
        BotanicalSpecies(
            scientificName: "Viola hederacea",
            commonNames: ["Australian Violet", "Ivy-leaved Violet"],
            family: "Violaceae",
            nativeRegions: ["Australia"],
            bloomingSeason: "Spring to summer",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Rock gardens", "Native Australian gardens"],
            interestingFacts: [
                "Creeping perennial forming mats",
                "Flowers held above foliage on long stems",
                "Tolerates light foot traffic",
                "Important food for Australian butterflies"
            ],
            careInstructions: "Moist, well-drained soil. Partial shade. Regular watering.",
            rarityLevel: .uncommon,
            continents: [.oceania],
            habitat: "Moist forests and shaded areas",
            description: "Small white and purple flowers above kidney-shaped leaves",
            imagePrompt: "Viola hederacea Australian violet with small white-purple flowers, kidney-shaped leaves, ground cover"
        ),
        
        // MARK: - Caryophyllaceae (Carnation Family) - 15 species
        
        BotanicalSpecies(
            scientificName: "Dianthus caryophyllus",
            commonNames: ["Carnation", "Clove Pink", "Gillyflower"],
            family: "Caryophyllaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Cut flowers", "Ornamental", "Perfume", "Culinary"],
            interestingFacts: [
                "Symbol of love and fascination",
                "Spicy clove-like fragrance",
                "Can live several years in mild climates",
                "Parent of many garden cultivars"
            ],
            careInstructions: "Well-drained, alkaline soil. Full sun. Good air circulation.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Rocky areas and cultivated gardens",
            description: "Fragrant ruffled flowers in pink, red, white, or yellow",
            imagePrompt: "Dianthus caryophyllus carnation with fragrant ruffled flowers, pink red white, clove-scented"
        ),
        
        BotanicalSpecies(
            scientificName: "Dianthus barbatus",
            commonNames: ["Sweet William", "Bearded Pink", "Bunch Pink"],
            family: "Caryophyllaceae",
            nativeRegions: ["Southern Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Cottage gardens"],
            interestingFacts: [
                "Named after Saint William of Rochester",
                "Biennial producing flowers second year",
                "Dense clusters can contain 30+ flowers",
                "Attracts butterflies and beneficial insects"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Gardens and naturalized areas",
            description: "Dense flat-topped clusters of small fringed flowers",
            imagePrompt: "Dianthus barbatus Sweet William with dense clusters of small fringed flowers, multiple colors"
        ),
        
        BotanicalSpecies(
            scientificName: "Dianthus plumarius",
            commonNames: ["Cottage Pink", "Garden Pink", "Grass Pink"],
            family: "Caryophyllaceae",
            nativeRegions: ["Eastern Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Rock gardens", "Fragrance"],
            interestingFacts: [
                "Traditional cottage garden plant",
                "Intensely fragrant, especially in evening",
                "Perennial forming spreading mats",
                "Grey-blue foliage year-round"
            ],
            careInstructions: "Well-drained, alkaline soil. Full sun. Drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Rocky areas and cottage gardens",
            description: "Fragrant fringed flowers above blue-grey grass-like foliage",
            imagePrompt: "Dianthus plumarius cottage pink with fragrant fringed flowers, blue-grey grass-like foliage"
        ),
        
        BotanicalSpecies(
            scientificName: "Gypsophila paniculata",
            commonNames: ["Baby's Breath", "Common Gypsophila"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Cut flowers", "Dried flowers", "Ornamental", "Filler plant"],
            interestingFacts: [
                "Essential flower in floral arrangements",
                "Cloud-like masses of tiny flowers",
                "Deep taproot makes it drought tolerant",
                "Can produce 14,000+ flowers per plant"
            ],
            careInstructions: "Well-drained, alkaline soil. Full sun. Avoid heavy clay.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Open areas and rocky soils",
            description: "Clouds of tiny white flowers creating airy texture",
            imagePrompt: "Gypsophila paniculata baby's breath with clouds of tiny white flowers, airy delicate texture"
        ),
        
        BotanicalSpecies(
            scientificName: "Saponaria officinalis",
            commonNames: ["Soapwort", "Bouncing Bet", "Sweet Betty"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid-summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Traditional soap", "Medicinal", "Ornamental"],
            interestingFacts: [
                "Roots contain saponins that create lather",
                "Used historically to clean wool and silk",
                "Spreads rapidly by underground rhizomes",
                "Flowers are fragrant in evening"
            ],
            careInstructions: "Adapts to most soils. Full sun to partial shade. Can be invasive.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Roadsides, waste areas, and old gardens",
            description: "Pink or white flowers in clusters above oval leaves",
            imagePrompt: "Saponaria officinalis soapwort with pink-white flowers in clusters, spreading perennial herb"
        ),
        
        BotanicalSpecies(
            scientificName: "Silene dioica",
            commonNames: ["Red Campion", "Red Catchfly"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Wildflower gardens", "Native plant gardens", "Wildlife food"],
            interestingFacts: [
                "Separate male and female plants (dioecious)",
                "Important nectar source for moths",
                "Perennial or biennial depending on conditions",
                "Hybridizes with white campion"
            ],
            careInstructions: "Moist, rich soil. Partial shade to full sun.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Woodlands, hedgerows, and moist areas",
            description: "Bright pink five-petaled flowers with notched petals",
            imagePrompt: "Silene dioica red campion with bright pink five-petaled flowers, notched petals, woodland wildflower"
        ),
        
        BotanicalSpecies(
            scientificName: "Silene alba",
            commonNames: ["White Campion", "Evening Lychnis", "White Cockle"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe", "North Africa"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Wildflower gardens", "Evening gardens", "Wildlife food"],
            interestingFacts: [
                "Flowers open in evening and are fragrant",
                "Separate male and female plants",
                "Important food for moth caterpillars",
                "Annual, biennial, or short-lived perennial"
            ],
            careInstructions: "Well-drained soil. Full sun to partial shade. Self-seeds.",
            rarityLevel: .common,
            continents: [.europe, .africa, .northAmerica],
            habitat: "Fields, roadsides, and disturbed areas",
            description: "White five-petaled flowers opening in evening",
            imagePrompt: "Silene alba white campion with white five-petaled flowers opening in evening, fragrant"
        ),
        
        BotanicalSpecies(
            scientificName: "Lychnis coronaria",
            commonNames: ["Rose Campion", "Dusty Miller", "Mullein Pink"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cottage gardens", "Drought gardens"],
            interestingFacts: [
                "Silver-white woolly foliage year-round",
                "Biennial or short-lived perennial",
                "Self-seeds readily in garden conditions",
                "Tolerates poor, dry soils"
            ],
            careInstructions: "Well-drained soil. Full sun. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Dry, rocky areas and gardens",
            description: "Magenta flowers above silver-white woolly foliage",
            imagePrompt: "Lychnis coronaria rose campion with magenta flowers, silver-white woolly foliage, drought tolerant"
        ),
        
        BotanicalSpecies(
            scientificName: "Cerastium tomentosum",
            commonNames: ["Snow-in-Summer", "Mouse-ear Chickweed"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Rock gardens", "Border edging"],
            interestingFacts: [
                "Forms dense mats of silver-grey foliage",
                "Covered in white flowers resembling snow",
                "Perennial that spreads by creeping stems",
                "Drought tolerant once established"
            ],
            careInstructions: "Well-drained soil. Full sun. Avoid wet conditions.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Rocky areas and dry slopes",
            description: "Masses of small white flowers above silver-grey foliage",
            imagePrompt: "Cerastium tomentosum snow-in-summer with masses of white flowers, silver-grey foliage mat"
        ),
        
        BotanicalSpecies(
            scientificName: "Stellaria media",
            commonNames: ["Chickweed", "Common Chickweed", "Starwort"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Nearly year-round in mild climates",
            conservationStatus: "Least Concern",
            uses: ["Edible greens", "Medicinal", "Wildlife food"],
            interestingFacts: [
                "One of most widespread weeds in world",
                "Edible and nutritious when young",
                "Annual that can complete lifecycle in 5 weeks",
                "Important food for birds and small animals"
            ],
            careInstructions: "Adapts to most conditions. Prefers cool, moist weather.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica, .oceania],
            habitat: "Gardens, lawns, and disturbed areas everywhere",
            description: "Tiny white star-shaped flowers with deeply notched petals",
            imagePrompt: "Stellaria media chickweed with tiny white star-shaped flowers, deeply notched petals, common weed"
        ),
        
        BotanicalSpecies(
            scientificName: "Agrostemma githago",
            commonNames: ["Corn Cockle", "Common Corncockle"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Near Threatened",
            uses: ["Wildflower gardens", "Historical gardens", "Cut flowers"],
            interestingFacts: [
                "Once common weed in grain fields",
                "Seeds are toxic to humans and animals",
                "Now rare due to modern farming practices",
                "Annual that requires cultivation disturbance"
            ],
            careInstructions: "Well-drained soil. Full sun. Direct sow in fall or spring.",
            rarityLevel: .rare,
            continents: [.europe, .northAmerica],
            habitat: "Former grain fields and wildflower meadows",
            description: "Large pink flowers with dark veins and narrow petals",
            imagePrompt: "Agrostemma githago corn cockle with large pink flowers, dark veins, narrow petals, rare wildflower"
        ),
        
        BotanicalSpecies(
            scientificName: "Spergularia media",
            commonNames: ["Greater Sea-spurrey", "Media Sandspurry"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe", "North America"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Salt marsh restoration", "Coastal gardens"],
            interestingFacts: [
                "Tolerates high salt concentrations",
                "Annual adapted to coastal conditions",
                "Small but numerous pink flowers",
                "Important pioneer species in salt marshes"
            ],
            careInstructions: "Sandy, saline soil. Full sun. Salt tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .northAmerica],
            habitat: "Salt marshes and coastal areas",
            description: "Small pink flowers above succulent linear leaves",
            imagePrompt: "Spergularia media greater sea-spurrey with small pink flowers, succulent leaves, coastal salt marsh"
        ),
        
        BotanicalSpecies(
            scientificName: "Minuartia verna",
            commonNames: ["Spring Sandwort", "Vernal Sandwort"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe", "North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Rock gardens", "Alpine gardens", "Ground cover"],
            interestingFacts: [
                "Forms tight cushions or mats",
                "Adapted to harsh alpine conditions",
                "Perennial with woody base",
                "Important plant for mountain ecosystems"
            ],
            careInstructions: "Well-drained, sandy soil. Full sun. Excellent drainage essential.",
            rarityLevel: .uncommon,
            continents: [.europe, .northAmerica],
            habitat: "Rocky areas and alpine meadows",
            description: "Small white star-shaped flowers above needle-like leaves",
            imagePrompt: "Minuartia verna spring sandwort with small white star flowers, needle-like leaves, alpine cushion"
        ),
        
        BotanicalSpecies(
            scientificName: "Scleranthus annuus",
            commonNames: ["Annual Knawel", "German Knotgrass"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Specialty gardens", "Sandy soil areas"],
            interestingFacts: [
                "Tiny flowers lack petals",
                "Annual forming small tufts",
                "Adapted to nutrient-poor soils",
                "Often overlooked due to small size"
            ],
            careInstructions: "Sandy, well-drained soil. Full sun. Low fertility preferred.",
            rarityLevel: .uncommon,
            continents: [.europe, .northAmerica],
            habitat: "Sandy fields and waste areas",
            description: "Tiny green flowers in clusters above narrow leaves",
            imagePrompt: "Scleranthus annuus annual knawel with tiny green petalless flowers, narrow leaves, small tuft"
        ),
        
        BotanicalSpecies(
            scientificName: "Herniaria glabra",
            commonNames: ["Smooth Rupturewort", "Green Carpet"],
            family: "Caryophyllaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Between stepping stones", "Rock gardens"],
            interestingFacts: [
                "Forms dense, flat mats",
                "Tolerates light foot traffic",
                "Tiny flowers are barely visible",
                "Traditional medicinal use for hernias"
            ],
            careInstructions: "Well-drained soil. Full sun to partial shade. Drought tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Sandy soils and gravelly areas",
            description: "Tiny greenish flowers on prostrate mat-forming plant",
            imagePrompt: "Herniaria glabra smooth rupturewort forming dense green mat, tiny greenish flowers, ground cover"
        ),
        
        // MARK: - Papaveraceae (Poppy Family) - 12 species
        
        BotanicalSpecies(
            scientificName: "Papaver somniferum",
            commonNames: ["Opium Poppy", "Bread-seed Poppy", "Garden Poppy"],
            family: "Papaveraceae",
            nativeRegions: ["Mediterranean", "Western Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Culinary seeds", "Medicinal (restricted)"],
            interestingFacts: [
                "Source of opium and medical opioids",
                "Seeds are edible and nutritious",
                "Large papery flowers up to 5 inches across",
                "Annual with distinctive seed pods"
            ],
            careInstructions: "Well-drained soil, full sun. Direct sow in cool weather.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Gardens and disturbed areas",
            description: "Large papery flowers in white, pink, red, or purple with dark centers",
            imagePrompt: "Papaver somniferum opium poppy with large papery flowers, white pink red purple, prominent seed pods"
        ),
        
        BotanicalSpecies(
            scientificName: "Papaver rhoeas",
            commonNames: ["Common Poppy", "Corn Poppy", "Field Poppy"],
            family: "Papaveraceae",
            nativeRegions: ["Europe", "North Africa", "Asia"],
            bloomingSeason: "Late spring to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Symbol of remembrance", "Wildlife food"],
            interestingFacts: [
                "Symbol of WWI remembrance (Flanders poppies)",
                "Annual that self-seeds prolifically",
                "Flowers last only one day",
                "Traditional weed of grain fields"
            ],
            careInstructions: "Well-drained soil, full sun. Self-seeds in disturbed ground.",
            rarityLevel: .common,
            continents: [.europe, .africa, .asia, .northAmerica],
            habitat: "Fields, roadsides, and disturbed areas",
            description: "Bright red papery flowers with black centers and hairy stems",
            imagePrompt: "Papaver rhoeas corn poppy with bright red papery flowers, black centers, field of poppies"
        ),
        
        BotanicalSpecies(
            scientificName: "Papaver orientale",
            commonNames: ["Oriental Poppy", "Large Poppy"],
            family: "Papaveraceae",
            nativeRegions: ["Turkey", "Iran", "Caucasus"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Perennial gardens"],
            interestingFacts: [
                "Largest flowers in poppy family",
                "Perennial with deep taproot",
                "Goes dormant in summer heat",
                "Flowers can be 6+ inches across"
            ],
            careInstructions: "Well-drained soil, full sun. Plant in fall. Summer dormancy normal.",
            rarityLevel: .common,
            continents: [.asia, .europe, .northAmerica],
            habitat: "Rocky slopes and perennial gardens",
            description: "Enormous orange-red flowers with dark blotches and papery texture",
            imagePrompt: "Papaver orientale oriental poppy with enormous orange-red flowers, dark blotches, papery petals"
        ),
        
        BotanicalSpecies(
            scientificName: "Eschscholzia californica",
            commonNames: ["California Poppy", "Golden Poppy", "Cup of Gold"],
            family: "Papaveraceae",
            nativeRegions: ["California", "Oregon"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "State flower of California", "Drought gardens"],
            interestingFacts: [
                "Official state flower of California",
                "Flowers close on cloudy days and at night",
                "Self-seeding annual in ideal conditions",
                "Drought tolerant and heat resistant"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Grasslands, hillsides, and roadsides",
            description: "Bright orange cup-shaped flowers with silky petals",
            imagePrompt: "Eschscholzia californica California poppy with bright orange cup-shaped flowers, silky petals, golden hillside"
        ),
        
        BotanicalSpecies(
            scientificName: "Chelidonium majus",
            commonNames: ["Greater Celandine", "Swallowwort", "Garden Celandine"],
            family: "Papaveraceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring to early fall",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Historical uses", "Shade gardens"],
            interestingFacts: [
                "Produces bright yellow latex when cut",
                "Traditional wart removal remedy",
                "Biennial or short-lived perennial",
                "Thrives in partial shade unlike most poppies"
            ],
            careInstructions: "Moist, rich soil. Partial shade to full sun. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodland edges and disturbed areas",
            description: "Small bright yellow flowers in clusters above lobed leaves",
            imagePrompt: "Chelidonium majus greater celandine with small bright yellow flowers, lobed leaves, yellow latex"
        ),
        
        BotanicalSpecies(
            scientificName: "Sanguinaria canadensis",
            commonNames: ["Bloodroot", "Red Puccoon"],
            family: "Papaveraceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Woodland gardens", "Medicinal"],
            interestingFacts: [
                "Named for red latex in roots and stems",
                "One of earliest spring wildflowers",
                "Single leaf wraps around flower stem",
                "Perennial with thick underground rhizomes"
            ],
            careInstructions: "Rich, moist soil. Partial to full shade. Woodland conditions.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Rich deciduous woodlands",
            description: "Pure white flowers with golden centers emerging before leaves",
            imagePrompt: "Sanguinaria canadensis bloodroot with pure white flowers, golden centers, single wrapped leaf, spring woodland"
        ),
        
        BotanicalSpecies(
            scientificName: "Stylophorum diphyllum",
            commonNames: ["Wood Poppy", "Celandine Poppy"],
            family: "Papaveraceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Mid to late spring",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Woodland gardens", "Shade perennials"],
            interestingFacts: [
                "Only native North American true poppy",
                "Produces yellow latex when damaged",
                "Perennial forming colonies",
                "Self-seeds in ideal woodland conditions"
            ],
            careInstructions: "Rich, moist soil. Partial shade. Mulch to retain moisture.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Rich moist woodlands",
            description: "Bright yellow poppy flowers above deeply lobed leaves",
            imagePrompt: "Stylophorum diphyllum wood poppy with bright yellow poppy flowers, deeply lobed leaves, woodland shade"
        ),
        
        BotanicalSpecies(
            scientificName: "Glaucium flavum",
            commonNames: ["Yellow Horned-poppy", "Sea Poppy"],
            family: "Papaveraceae",
            nativeRegions: ["Europe", "Mediterranean"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Coastal gardens", "Drought gardens", "Ornamental"],
            interestingFacts: [
                "Produces extremely long seed pods (up to 12 inches)",
                "Tolerates salt spray and poor soils",
                "Biennial with thick, fleshy leaves",
                "All parts contain toxic alkaloids"
            ],
            careInstructions: "Sandy, well-drained soil. Full sun. Salt and drought tolerant.",
            rarityLevel: .uncommon,
            continents: [.europe],
            habitat: "Coastal areas and sandy soils",
            description: "Large yellow flowers above blue-grey deeply lobed leaves",
            imagePrompt: "Glaucium flavum yellow horned-poppy with large yellow flowers, blue-grey lobed leaves, coastal setting"
        ),
        
        BotanicalSpecies(
            scientificName: "Argemone mexicana",
            commonNames: ["Mexican Prickly Poppy", "Yellow Prickly Poppy"],
            family: "Papaveraceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Summer to fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Medicinal", "Drought gardens"],
            interestingFacts: [
                "Entire plant covered in sharp spines",
                "Produces yellow latex when cut",
                "Annual adapted to hot, dry conditions",
                "Seeds contain toxic alkaloids"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant. Handle with care due to spines.",
            rarityLevel: .uncommon,
            continents: [.northAmerica, .southAmerica],
            habitat: "Deserts and disturbed ground",
            description: "Yellow poppy flowers above spiny blue-green leaves",
            imagePrompt: "Argemone mexicana Mexican prickly poppy with yellow flowers, spiny blue-green leaves, desert plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Macleaya cordata",
            commonNames: ["Plume Poppy", "Tree Celandine"],
            family: "Papaveraceae",
            nativeRegions: ["China", "Japan"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Back of border", "Architectural plant"],
            interestingFacts: [
                "Can grow 8+ feet tall in one season",
                "Flowers lack petals but have showy stamens",
                "Perennial spreading by underground rhizomes",
                "Large heart-shaped leaves up to 10 inches"
            ],
            careInstructions: "Rich, moist soil. Full sun to partial shade. Needs space to spread.",
            rarityLevel: .uncommon,
            continents: [.asia, .northAmerica, .europe],
            habitat: "Woodland edges and large gardens",
            description: "Tall plumes of small petalless flowers above large heart-shaped leaves",
            imagePrompt: "Macleaya cordata plume poppy with tall feathery flower plumes, large heart-shaped leaves, architectural"
        ),
        
        BotanicalSpecies(
            scientificName: "Corydalis lutea",
            commonNames: ["Yellow Corydalis", "Golden Bleeding-heart"],
            family: "Papaveraceae",
            nativeRegions: ["Southern Europe"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Rock gardens", "Wall gardens", "Ground cover"],
            interestingFacts: [
                "Self-seeds in cracks and crevices",
                "Blooms continuously in cool weather",
                "Perennial with fern-like foliage",
                "Flowers have distinctive spurs"
            ],
            careInstructions: "Well-drained soil. Partial shade to full sun. Tolerates poor soil.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Rocky areas, walls, and gardens",
            description: "Small bright yellow flowers with spurs above delicate fern-like foliage",
            imagePrompt: "Corydalis lutea yellow corydalis with bright yellow spurred flowers, delicate fern-like foliage"
        ),
        
        BotanicalSpecies(
            scientificName: "Dicentra spectabilis",
            commonNames: ["Bleeding Heart", "Old-fashioned Bleeding Heart"],
            family: "Papaveraceae",
            nativeRegions: ["Siberia", "Northern China", "Korea", "Japan"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Shade gardens", "Woodland gardens", "Cut flowers"],
            interestingFacts: [
                "Heart-shaped flowers appear to be bleeding",
                "Goes dormant in summer heat",
                "Perennial with arching stems",
                "Traditional cottage garden plant"
            ],
            careInstructions: "Rich, moist soil. Partial to full shade. Mulch to keep cool.",
            rarityLevel: .common,
            continents: [.asia, .northAmerica, .europe],
            habitat: "Shaded gardens and woodland edges",
            description: "Heart-shaped pink and white flowers dangling from arching stems",
            imagePrompt: "Dicentra spectabilis bleeding heart with heart-shaped pink-white dangling flowers, arching stems"
        ),
        
        // MARK: - Convolvulaceae (Morning Glory Family) - 10 species
        
        BotanicalSpecies(
            scientificName: "Ipomoea purpurea",
            commonNames: ["Morning Glory", "Common Morning Glory", "Purple Morning Glory"],
            family: "Convolvulaceae",
            nativeRegions: ["Central America", "Mexico"],
            bloomingSeason: "Summer to frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Climbing vine", "Screen plant"],
            interestingFacts: [
                "Flowers open in morning, close by afternoon",
                "Vigorous annual vine that can climb 15+ feet",
                "Self-seeds readily and can become weedy",
                "Heart-shaped leaves and trumpet flowers"
            ],
            careInstructions: "Average soil, full sun. Climbing support needed. Can be invasive.",
            rarityLevel: .common,
            continents: [.northAmerica, .southAmerica],
            habitat: "Gardens, fences, and disturbed areas",
            description: "Purple trumpet-shaped flowers opening in morning",
            imagePrompt: "Ipomoea purpurea morning glory with purple trumpet-shaped flowers, heart-shaped leaves, climbing vine"
        ),
        
        BotanicalSpecies(
            scientificName: "Ipomoea tricolor",
            commonNames: ["Heavenly Blue Morning Glory", "Mexican Morning Glory"],
            family: "Convolvulaceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Summer to frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Climbing vine", "Container gardens"],
            interestingFacts: [
                "Flowers change from blue to pink as they age",
                "Seeds contain psychoactive compounds (LSA)",
                "Annual vine reaching 10+ feet",
                "Popular variety 'Heavenly Blue' widely grown"
            ],
            careInstructions: "Well-drained soil, full sun. Support for climbing. Regular watering.",
            rarityLevel: .common,
            continents: [.northAmerica, .southAmerica],
            habitat: "Gardens and natural areas",
            description: "Sky-blue trumpet flowers with white throats",
            imagePrompt: "Ipomoea tricolor heavenly blue morning glory with sky-blue trumpet flowers, white throats, climbing"
        ),
        
        BotanicalSpecies(
            scientificName: "Convolvulus arvensis",
            commonNames: ["Field Bindweed", "Wild Morning Glory", "Creeping Jenny"],
            family: "Convolvulaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring through fall",
            conservationStatus: "Least Concern",
            uses: ["None (considered invasive weed)"],
            interestingFacts: [
                "Extremely deep root system (up to 30 feet)",
                "Perennial that's nearly impossible to eradicate",
                "Flowers similar to morning glory but smaller",
                "Spreads by both seeds and underground rhizomes"
            ],
            careInstructions: "Grows in any conditions. Control measures needed to prevent spread.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Fields, gardens, and waste areas",
            description: "Small white or pink funnel-shaped flowers on twining stems",
            imagePrompt: "Convolvulus arvensis field bindweed with small white-pink funnel flowers, twining stems, invasive weed"
        ),
        
        BotanicalSpecies(
            scientificName: "Convolvulus tricolor",
            commonNames: ["Dwarf Morning Glory", "Tricolor Convolvulus"],
            family: "Convolvulaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Rock gardens", "Ground cover"],
            interestingFacts: [
                "Bushy annual, not a climbing vine",
                "Flowers have three distinct color zones",
                "Stays open longer than true morning glories",
                "Drought tolerant once established"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant. No support needed.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Mediterranean gardens and dry areas",
            description: "Tricolored flowers with blue, white, and yellow zones",
            imagePrompt: "Convolvulus tricolor dwarf morning glory with tricolored blue-white-yellow flowers, bushy growth"
        ),
        
        BotanicalSpecies(
            scientificName: "Calystegia sepium",
            commonNames: ["Hedge Bindweed", "Large Bindweed", "Bellbind"],
            family: "Convolvulaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Wildlife habitat", "Natural areas only"],
            interestingFacts: [
                "Larger flowers than field bindweed",
                "Perennial climbing vine reaching 10+ feet",
                "Important nectar source for moths",
                "Can quickly cover hedges and shrubs"
            ],
            careInstructions: "Grows in any soil. Can be invasive, control spread as needed.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Hedgerows, woodland edges, and waste areas",
            description: "Large white trumpet flowers with broad arrow-shaped leaves",
            imagePrompt: "Calystegia sepium hedge bindweed with large white trumpet flowers, arrow-shaped leaves, climbing"
        ),
        
        BotanicalSpecies(
            scientificName: "Ipomoea nil",
            commonNames: ["Japanese Morning Glory", "Imperial Morning Glory"],
            family: "Convolvulaceae",
            nativeRegions: ["Tropical Asia"],
            bloomingSeason: "Summer to frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Traditional cultivation", "Climbing screens"],
            interestingFacts: [
                "Cultivated in Japan for over 1000 years",
                "Hundreds of named varieties with different flower forms",
                "Annual vine with vigorous growth",
                "Traditional subject for Japanese art and poetry"
            ],
            careInstructions: "Rich, moist soil. Full sun to partial shade. Support required.",
            rarityLevel: .common,
            continents: [.asia, .northAmerica],
            habitat: "Gardens and traditional cultivation",
            description: "Large funnel-shaped flowers in blue, purple, pink, or white",
            imagePrompt: "Ipomoea nil Japanese morning glory with large funnel flowers, blue purple pink white, traditional cultivation"
        ),
        
        BotanicalSpecies(
            scientificName: "Ipomoea batatas",
            commonNames: ["Sweet Potato Vine", "Ornamental Sweet Potato"],
            family: "Convolvulaceae",
            nativeRegions: ["Central America", "South America"],
            bloomingSeason: "Rarely flowers in cultivation",
            conservationStatus: "Least Concern",
            uses: ["Ornamental foliage", "Ground cover", "Container plants"],
            interestingFacts: [
                "Grown primarily for colorful foliage",
                "Same species as edible sweet potato",
                "Perennial vine grown as annual",
                "Available in purple, chartreuse, and variegated forms"
            ],
            careInstructions: "Rich, well-drained soil. Full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.southAmerica, .northAmerica],
            habitat: "Ornamental gardens and containers",
            description: "Heart-shaped leaves in purple, green, or chartreuse colors",
            imagePrompt: "Ipomoea batatas ornamental sweet potato vine with colorful heart-shaped leaves, purple green chartreuse"
        ),
        
        BotanicalSpecies(
            scientificName: "Cuscuta europaea",
            commonNames: ["Greater Dodder", "European Dodder"],
            family: "Convolvulaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["None (parasitic plant)", "Scientific study"],
            interestingFacts: [
                "Parasitic vine with no chlorophyll",
                "Wraps around host plants and penetrates them",
                "Annual that starts from seed but loses roots",
                "Orange thread-like stems with tiny flowers"
            ],
            careInstructions: "Parasitic - requires host plants. Not cultivated.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia],
            habitat: "On various host plants in natural areas",
            description: "Orange thread-like parasitic stems with tiny white flowers",
            imagePrompt: "Cuscuta europaea greater dodder with orange thread-like parasitic stems, tiny white flowers, host plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Dichondra argentea",
            commonNames: ["Silver Falls", "Silver Dichondra"],
            family: "Convolvulaceae",
            nativeRegions: ["Texas", "New Mexico"],
            bloomingSeason: "Summer (grown for foliage)",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Hanging baskets", "Ground cover"],
            interestingFacts: [
                "Grown primarily for silvery trailing foliage",
                "Perennial in warm climates, annual elsewhere",
                "Flowers are tiny and inconspicuous",
                "Popular in hanging baskets for cascading effect"
            ],
            careInstructions: "Well-drained soil. Full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Rock gardens and hanging baskets",
            description: "Silvery kidney-shaped leaves on trailing stems",
            imagePrompt: "Dichondra argentea silver falls with silvery kidney-shaped leaves, trailing cascading stems"
        ),
        
        BotanicalSpecies(
            scientificName: "Evolvulus glomeratus",
            commonNames: ["Blue Daze", "Brazilian Dwarf Morning Glory"],
            family: "Convolvulaceae",
            nativeRegions: ["Brazil"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Rock gardens"],
            interestingFacts: [
                "Flowers stay open all day unlike morning glories",
                "Low-growing perennial with silvery foliage",
                "Heat and drought tolerant",
                "Attracts butterflies and beneficial insects"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.southAmerica, .northAmerica],
            habitat: "Gardens and natural areas",
            description: "Small bright blue flowers above silvery-green foliage",
            imagePrompt: "Evolvulus glomeratus blue daze with small bright blue flowers, silvery-green foliage, ground cover"
        ),
        
        // MARK: - Scrophulariaceae (Figwort Family) - 15 species
        
        BotanicalSpecies(
            scientificName: "Antirrhinum majus",
            commonNames: ["Snapdragon", "Garden Snapdragon", "Dragon Flower"],
            family: "Scrophulariaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Cottage gardens"],
            interestingFacts: [
                "Flowers resemble dragon mouths that open when squeezed",
                "Available in dwarf, medium, and tall varieties",
                "Cool weather annual, perennial in mild climates",
                "Traditional cottage garden favorite"
            ],
            careInstructions: "Rich, well-drained soil. Cool weather preferred. Full sun to partial shade.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Gardens and naturalized areas",
            description: "Spikes of tubular flowers that snap open when squeezed",
            imagePrompt: "Antirrhinum majus snapdragon with colorful flower spikes, tubular snap-open flowers, cottage garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Digitalis purpurea",
            commonNames: ["Common Foxglove", "Purple Foxglove", "Lady's Glove"],
            family: "Scrophulariaceae",
            nativeRegions: ["Western Europe"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Medicinal (pharmaceutical)", "Woodland gardens"],
            interestingFacts: [
                "Source of heart medication digitoxin",
                "All parts highly toxic if ingested",
                "Biennial producing flower spikes second year",
                "Important pollinator plant for bees"
            ],
            careInstructions: "Moist, well-drained soil. Partial shade to full sun. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Woodland edges and gardens",
            description: "Tall spikes of purple tubular flowers with spotted throats",
            imagePrompt: "Digitalis purpurea foxglove with tall purple flower spikes, tubular spotted flowers, woodland garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Penstemon digitalis",
            commonNames: ["Foxglove Beardtongue", "Smooth Penstemon", "White Beardtongue"],
            family: "Scrophulariaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Prairie gardens", "Pollinator gardens"],
            interestingFacts: [
                "Important nectar source for hummingbirds",
                "Perennial native wildflower",
                "Named for fuzzy stamen (beardtongue)",
                "Tolerates wide range of soil conditions"
            ],
            careInstructions: "Adapts to most soils. Full sun to partial shade. Low maintenance.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Prairies, open woods, and roadsides",
            description: "White tubular flowers with purple lines in tall spikes",
            imagePrompt: "Penstemon digitalis foxglove beardtongue with white tubular flowers, purple lines, native wildflower"
        ),
        
        BotanicalSpecies(
            scientificName: "Veronica spicata",
            commonNames: ["Spiked Speedwell", "Spike Veronica"],
            family: "Scrophulariaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Perennial borders", "Rock gardens"],
            interestingFacts: [
                "Perennial forming clumps with upright spikes",
                "Attracts butterflies and beneficial insects",
                "Drought tolerant once established",
                "Available in blue, pink, and white varieties"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant. Deadhead for repeat bloom.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Grasslands and garden borders",
            description: "Dense spikes of small blue flowers above narrow leaves",
            imagePrompt: "Veronica spicata spiked speedwell with dense blue flower spikes, narrow leaves, perennial border"
        ),
        
        BotanicalSpecies(
            scientificName: "Linaria vulgaris",
            commonNames: ["Common Toadflax", "Butter and Eggs", "Yellow Toadflax"],
            family: "Scrophulariaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Wildflower gardens", "Naturalized areas", "Cut flowers"],
            interestingFacts: [
                "Flowers resemble tiny yellow snapdragons",
                "Perennial spreading by underground runners",
                "Can become weedy in some areas",
                "Traditional medicinal uses for skin conditions"
            ],
            careInstructions: "Adapts to most soils. Full sun. Can spread aggressively.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Roadsides, fields, and waste areas",
            description: "Spikes of small yellow flowers with orange throats and spurs",
            imagePrompt: "Linaria vulgaris common toadflax with yellow flowers, orange throats, spurs, wildflower spikes"
        ),
        
        BotanicalSpecies(
            scientificName: "Mimulus guttatus",
            commonNames: ["Yellow Monkey Flower", "Common Monkey Flower"],
            family: "Scrophulariaceae",
            nativeRegions: ["Western North America"],
            bloomingSeason: "Spring through summer",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Bog gardens", "Stream plantings"],
            interestingFacts: [
                "Flowers have spotted throats resembling monkey faces",
                "Annual or perennial depending on conditions",
                "Requires consistently moist soil",
                "Important food source for native pollinators"
            ],
            careInstructions: "Moist to wet soil. Full sun to partial shade. Consistent moisture essential.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Stream banks and moist areas",
            description: "Bright yellow flowers with red-spotted throats and monkey-like faces",
            imagePrompt: "Mimulus guttatus yellow monkey flower with bright yellow flowers, red-spotted throats, stream side"
        ),
        
        BotanicalSpecies(
            scientificName: "Chelone glabra",
            commonNames: ["White Turtlehead", "Balmony", "Snakehead"],
            family: "Scrophulariaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Bog gardens", "Wildlife gardens"],
            interestingFacts: [
                "Flowers resemble turtle heads with open mouths",
                "Host plant for Baltimore checkerspot butterfly",
                "Perennial preferring wet conditions",
                "Traditional medicinal plant"
            ],
            careInstructions: "Moist to wet soil. Partial shade to full sun. Bog-like conditions preferred.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Wet meadows and stream banks",
            description: "White turtle-head shaped flowers in terminal clusters",
            imagePrompt: "Chelone glabra white turtlehead with white turtle-head shaped flowers, terminal clusters, bog plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Verbascum thapsus",
            commonNames: ["Common Mullein", "Great Mullein", "Aaron's Rod"],
            family: "Scrophulariaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Medicinal", "Wildlife habitat", "Naturalized areas"],
            interestingFacts: [
                "Tall flower spikes can reach 8+ feet",
                "Biennial with large woolly leaves first year",
                "Traditional remedy for respiratory ailments",
                "Leaves historically used as lamp wicks"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Fields, roadsides, and disturbed areas",
            description: "Tall spikes of yellow flowers above large woolly leaves",
            imagePrompt: "Verbascum thapsus common mullein with tall yellow flower spikes, large woolly leaves, roadside"
        ),
        
        BotanicalSpecies(
            scientificName: "Scrophularia nodosa",
            commonNames: ["Common Figwort", "Woodland Figwort", "Knotted Figwort"],
            family: "Scrophulariaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Wildlife gardens", "Shade gardens", "Traditional medicine"],
            interestingFacts: [
                "Flowers attract wasps rather than typical pollinators",
                "Perennial with square stems like mint family",
                "Traditional use for treating scrofula (hence name)",
                "Inconspicuous flowers but important for wildlife"
            ],
            careInstructions: "Moist, rich soil. Partial shade to full sun. Low maintenance.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodland edges and moist areas",
            description: "Small brownish-purple flowers in loose terminal clusters",
            imagePrompt: "Scrophularia nodosa common figwort with small brownish-purple flowers, loose clusters, woodland"
        ),
        
        BotanicalSpecies(
            scientificName: "Castilleja coccinea",
            commonNames: ["Scarlet Indian Paintbrush", "Scarlet Painted Cup"],
            family: "Scrophulariaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Prairie restorations", "Wildflower meadows"],
            interestingFacts: [
                "Colorful bracts more showy than actual flowers",
                "Annual that parasitizes grass roots",
                "Important nectar source for hummingbirds",
                "Difficult to cultivate due to parasitic nature"
            ],
            careInstructions: "Prairie conditions with native grasses. Full sun. Difficult to establish.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Prairies and grasslands",
            description: "Bright red bracts surrounding small inconspicuous flowers",
            imagePrompt: "Castilleja coccinea Indian paintbrush with bright red bracts, prairie wildflower, hummingbird plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Rhinanthus minor",
            commonNames: ["Yellow Rattle", "Little Yellow Rattle"],
            family: "Scrophulariaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Meadow restoration", "Grass suppression", "Wildlife habitat"],
            interestingFacts: [
                "Semi-parasitic annual that weakens grasses",
                "Used to create wildflower meadows from grassland",
                "Seeds rattle in dried capsules (hence name)",
                "Important for increasing meadow diversity"
            ],
            careInstructions: "Sow in grassland in fall. No cultivation needed once established.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia],
            habitat: "Grasslands and meadows",
            description: "Small yellow flowers with inflated seed capsules",
            imagePrompt: "Rhinanthus minor yellow rattle with small yellow flowers, inflated seed capsules, meadow grass"
        ),
        
        BotanicalSpecies(
            scientificName: "Bacopa monnieri",
            commonNames: ["Water Hyssop", "Brahmi", "Herb of Grace"],
            family: "Scrophulariaceae",
            nativeRegions: ["Worldwide in wetlands"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Aquatic gardens", "Medicinal", "Ground cover"],
            interestingFacts: [
                "Creeping perennial for wet conditions",
                "Important Ayurvedic medicinal herb",
                "Can grow submerged or in shallow water",
                "Memory-enhancing properties being studied"
            ],
            careInstructions: "Wet soil or shallow water. Full sun to partial shade. Aquatic conditions.",
            rarityLevel: .uncommon,
            continents: [.asia, .northAmerica, .oceania],
            habitat: "Wetlands and water gardens",
            description: "Small white flowers above small succulent leaves",
            imagePrompt: "Bacopa monnieri water hyssop with small white flowers, succulent leaves, aquatic ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Torenia fournieri",
            commonNames: ["Wishbone Flower", "Blue Wings"],
            family: "Scrophulariaceae",
            nativeRegions: ["Asia"],
            bloomingSeason: "Summer to frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Shade gardens", "Container plants"],
            interestingFacts: [
                "Stamens form wishbone shape inside flower",
                "Annual thriving in heat and humidity",
                "One of few annuals that bloom well in shade",
                "Flowers are bicolored with contrasting throat"
            ],
            careInstructions: "Rich, moist soil. Partial shade preferred. Regular watering needed.",
            rarityLevel: .common,
            continents: [.asia, .northAmerica],
            habitat: "Shade gardens and containers",
            description: "Purple and white bicolored flowers with wishbone-shaped stamens",
            imagePrompt: "Torenia fournieri wishbone flower with purple-white bicolored flowers, wishbone stamens, shade annual"
        ),
        
        BotanicalSpecies(
            scientificName: "Nemesia strumosa",
            commonNames: ["Nemesia", "Cape Snapdragon"],
            family: "Scrophulariaceae",
            nativeRegions: ["South Africa"],
            bloomingSeason: "Spring and fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cool weather annual", "Container gardens"],
            interestingFacts: [
                "Cool weather annual blooming best in spring/fall",
                "Flowers have distinctive pouched lower lip",
                "Available in wide range of bright colors",
                "Popular in European gardens"
            ],
            careInstructions: "Rich, well-drained soil. Cool weather preferred. Full sun to partial shade.",
            rarityLevel: .common,
            continents: [.africa, .northAmerica, .europe],
            habitat: "Gardens and containers",
            description: "Small snapdragon-like flowers with pouched lips in bright colors",
            imagePrompt: "Nemesia strumosa nemesia with small snapdragon-like flowers, pouched lips, bright mixed colors"
        ),
        
        BotanicalSpecies(
            scientificName: "Angelonia angustifolia",
            commonNames: ["Summer Snapdragon", "Angelonia"],
            family: "Scrophulariaceae",
            nativeRegions: ["Mexico", "Central America"],
            bloomingSeason: "Summer to frost",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Heat-tolerant annual", "Container gardens"],
            interestingFacts: [
                "Heat and humidity tolerant unlike true snapdragons",
                "Perennial in frost-free areas",
                "Flowers have slight grape-like fragrance",
                "Self-cleaning, no deadheading needed"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Heat tolerant.",
            rarityLevel: .common,
            continents: [.northAmerica, .southAmerica],
            habitat: "Gardens and containers in warm climates",
            description: "Small snapdragon-like flowers in purple, pink, or white spikes",
            imagePrompt: "Angelonia angustifolia summer snapdragon with purple-pink-white flower spikes, heat-tolerant annual"
        ),
        
        // MARK: - Geraniaceae (Geranium Family) - 10 species
        
        BotanicalSpecies(
            scientificName: "Pelargonium × hortorum",
            commonNames: ["Garden Geranium", "Zonal Geranium", "Common Geranium"],
            family: "Geraniaceae",
            nativeRegions: ["South Africa hybrid"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Cultivated",
            uses: ["Ornamental", "Container gardens", "Bedding plant"],
            interestingFacts: [
                "Actually pelargoniums, not true geraniums",
                "Tender perennial grown as annual in cold climates",
                "Scented leaves deter insects",
                "Available in many flower colors"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Regular watering but not soggy.",
            rarityLevel: .common,
            continents: [.africa, .northAmerica, .europe],
            habitat: "Gardens and containers worldwide",
            description: "Clusters of five-petaled flowers in red, pink, white, or salmon",
            imagePrompt: "Pelargonium hortorum garden geranium with clusters of flowers, red pink white salmon, container plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium maculatum",
            commonNames: ["Wild Geranium", "Spotted Geranium", "Cranesbill"],
            family: "Geraniaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Woodland gardens", "Ground cover"],
            interestingFacts: [
                "True geranium native to North America",
                "Seed pods split and eject seeds when ripe",
                "Perennial with deeply divided leaves",
                "Important nectar source for native bees"
            ],
            careInstructions: "Moist, rich soil. Partial shade to full shade. Woodland conditions.",
            rarityLevel: .common,
            continents: [.northAmerica],
            habitat: "Deciduous woodlands and shaded areas",
            description: "Pink five-petaled flowers with prominent veins",
            imagePrompt: "Geranium maculatum wild geranium with pink five-petaled flowers, prominent veins, woodland native"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium sanguineum",
            commonNames: ["Bloody Cranesbill", "Blood-red Geranium"],
            family: "Geraniaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Late spring through summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Rock gardens"],
            interestingFacts: [
                "Perennial with spreading habit",
                "Leaves turn red in fall",
                "Drought tolerant once established",
                "Long blooming season"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Rocky areas and gardens",
            description: "Magenta-pink flowers with darker veins above divided leaves",
            imagePrompt: "Geranium sanguineum bloody cranesbill with magenta-pink flowers, darker veins, divided leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Erodium cicutarium",
            commonNames: ["Redstem Filaree", "Common Stork's Bill", "Pin Clover"],
            family: "Geraniaceae",
            nativeRegions: ["Europe", "Asia", "North Africa"],
            bloomingSeason: "Spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Wildlife food", "Erosion control", "Forage plant"],
            interestingFacts: [
                "Annual with distinctive twisted seed awns",
                "Seeds drill themselves into ground when moist",
                "Important early season nectar source",
                "Widespread weedy species"
            ],
            careInstructions: "Adapts to poor soils. Full sun. Self-seeds readily.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa, .northAmerica],
            habitat: "Disturbed soils and waste areas",
            description: "Small pink flowers above finely divided leaves",
            imagePrompt: "Erodium cicutarium redstem filaree with small pink flowers, finely divided leaves, twisted seed awns"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium pratense",
            commonNames: ["Meadow Cranesbill", "Meadow Geranium"],
            family: "Geraniaceae",
            nativeRegions: ["Europe", "Central Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Meadow gardens", "Cut flowers"],
            interestingFacts: [
                "Large perennial geranium for borders",
                "Flowers can be blue, purple, pink, or white",
                "Self-seeds readily in gardens",
                "Attracts many types of pollinators"
            ],
            careInstructions: "Moist, fertile soil. Full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Meadows and garden borders",
            description: "Large blue-purple flowers with prominent veins",
            imagePrompt: "Geranium pratense meadow cranesbill with large blue-purple flowers, prominent veins, meadow setting"
        ),
        
        BotanicalSpecies(
            scientificName: "Pelargonium graveolens",
            commonNames: ["Rose Geranium", "Rose-scented Geranium"],
            family: "Geraniaceae",
            nativeRegions: ["South Africa"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Aromatherapy", "Essential oils", "Culinary", "Ornamental"],
            interestingFacts: [
                "Leaves smell strongly of roses when touched",
                "Source of geranium essential oil",
                "Tender perennial grown as annual",
                "Leaves used in cooking and teas"
            ],
            careInstructions: "Well-drained soil, full sun. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.africa, .northAmerica, .europe],
            habitat: "Herb gardens and containers",
            description: "Small pink flowers above deeply lobed rose-scented leaves",
            imagePrompt: "Pelargonium graveolens rose geranium with small pink flowers, deeply lobed rose-scented leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium endressii",
            commonNames: ["Endres Cranesbill", "French Cranesbill"],
            family: "Geraniaceae",
            nativeRegions: ["Pyrenees"],
            bloomingSeason: "Late spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Rock gardens"],
            interestingFacts: [
                "Semi-evergreen perennial with long blooming",
                "Spreads by underground rhizomes",
                "Pink flowers with darker veins",
                "Excellent ground cover for partial shade"
            ],
            careInstructions: "Well-drained soil, partial shade to full sun. Regular watering.",
            rarityLevel: .uncommon,
            continents: [.europe, .northAmerica],
            habitat: "Mountain meadows and gardens",
            description: "Bright pink flowers with dark veins above lobed leaves",
            imagePrompt: "Geranium endressii Endres cranesbill with bright pink flowers, dark veins, ground cover"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium himalayense",
            commonNames: ["Himalayan Cranesbill", "Lilac Cranesbill"],
            family: "Geraniaceae",
            nativeRegions: ["Himalayas"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Ground cover", "Perennial borders"],
            interestingFacts: [
                "Large flowers up to 2 inches across",
                "Perennial with spreading habit",
                "Blue flowers with reddish-purple veins",
                "Tolerates both sun and partial shade"
            ],
            careInstructions: "Moist, well-drained soil. Full sun to partial shade.",
            rarityLevel: .uncommon,
            continents: [.asia, .northAmerica, .europe],
            habitat: "Mountain meadows and gardens",
            description: "Large violet-blue flowers with reddish veins",
            imagePrompt: "Geranium himalayense Himalayan cranesbill with large violet-blue flowers, reddish veins"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium robertianum",
            commonNames: ["Herb Robert", "Red Robin", "Stinky Bob"],
            family: "Geraniaceae",
            nativeRegions: ["Europe", "Asia", "North America"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Traditional medicine", "Wildlife food", "Wild gardens"],
            interestingFacts: [
                "Annual with strong, distinctive odor",
                "Stems and leaves turn red in fall",
                "Traditional wound healing herb",
                "Self-seeds prolifically"
            ],
            careInstructions: "Adapts to most conditions. Shade tolerant. Self-maintaining.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodlands, walls, and waste areas",
            description: "Small pink flowers above reddish stems and divided leaves",
            imagePrompt: "Geranium robertianum herb Robert with small pink flowers, reddish stems, divided leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Geranium macrorrhizum",
            commonNames: ["Bigroot Geranium", "Bulgarian Geranium", "Rock Geranium"],
            family: "Geraniaceae",
            nativeRegions: ["Southern Europe"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Fragrant gardens", "Dry shade"],
            interestingFacts: [
                "Aromatic leaves smell spicy when crushed",
                "Excellent ground cover for difficult areas",
                "Semi-evergreen perennial",
                "Tolerates dry shade better than most geraniums"
            ],
            careInstructions: "Well-drained soil, partial shade to full shade. Drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Rocky areas and dry shade gardens",
            description: "Magenta flowers above aromatic, lobed leaves",
            imagePrompt: "Geranium macrorrhizum bigroot geranium with magenta flowers, aromatic lobed leaves, ground cover"
        ),
        
        // MARK: - Primulaceae (Primrose Family) - 10 species
        
        BotanicalSpecies(
            scientificName: "Primula vulgaris",
            commonNames: ["Common Primrose", "English Primrose"],
            family: "Primulaceae",
            nativeRegions: ["Western Europe"],
            bloomingSeason: "Early spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Woodland gardens", "Spring bedding"],
            interestingFacts: [
                "One of earliest spring flowers",
                "Symbol of youth and new beginnings",
                "Perennial forming rosettes",
                "Flowers have sweet fragrance"
            ],
            careInstructions: "Moist, rich soil. Partial shade. Cool conditions preferred.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Woodlands and shaded gardens",
            description: "Pale yellow flowers with orange centers above rosettes of leaves",
            imagePrompt: "Primula vulgaris common primrose with pale yellow flowers, orange centers, rosette leaves, spring woodland"
        ),
        
        BotanicalSpecies(
            scientificName: "Primula veris",
            commonNames: ["Cowslip", "Key Flower", "Fairy Cups"],
            family: "Primulaceae",
            nativeRegions: ["Europe", "Western Asia"],
            bloomingSeason: "Mid to late spring",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Meadow gardens", "Herbal medicine"],
            interestingFacts: [
                "Flowers hang in one-sided clusters",
                "Traditional uses for headaches and insomnia",
                "Perennial preferring alkaline soils",
                "Important early nectar source for butterflies"
            ],
            careInstructions: "Moist, alkaline soil. Full sun to partial shade. Cool conditions.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Meadows and chalky grasslands",
            description: "Bright yellow drooping flowers in terminal umbels",
            imagePrompt: "Primula veris cowslip with bright yellow drooping flowers, terminal umbels, meadow setting"
        ),
        
        BotanicalSpecies(
            scientificName: "Primula japonica",
            commonNames: ["Japanese Primrose", "Candelabra Primrose"],
            family: "Primulaceae",
            nativeRegions: ["Japan"],
            bloomingSeason: "Late spring to early summer",
            conservationStatus: "Least Concern",
            uses: ["Bog gardens", "Pond margins", "Woodland gardens"],
            interestingFacts: [
                "Flowers arranged in whorls up tall stems",
                "Perennial requiring consistently moist soil",
                "Available in pink, white, red, and purple",
                "Forms colonies in ideal conditions"
            ],
            careInstructions: "Moist to wet soil. Partial shade. Consistent moisture essential.",
            rarityLevel: .uncommon,
            continents: [.asia, .northAmerica, .europe],
            habitat: "Stream sides and bog gardens",
            description: "Tiered whorls of flowers in pink, red, or white on tall stems",
            imagePrompt: "Primula japonica Japanese primrose with tiered flower whorls, pink red white, tall stems, bog garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Cyclamen hederifolium",
            commonNames: ["Ivy-leaved Cyclamen", "Hardy Cyclamen"],
            family: "Primulaceae",
            nativeRegions: ["Mediterranean"],
            bloomingSeason: "Late summer to fall",
            conservationStatus: "Least Concern",
            uses: ["Woodland gardens", "Rock gardens", "Naturalizing"],
            interestingFacts: [
                "Flowers appear before leaves in fall",
                "Perennial from underground tubers",
                "Leaves are beautifully marbled",
                "Hardy to zone 5 with protection"
            ],
            careInstructions: "Well-drained soil, partial shade. Summer dormancy normal.",
            rarityLevel: .uncommon,
            continents: [.europe, .northAmerica],
            habitat: "Woodland floors and rocky areas",
            description: "Pink swept-back flowers above marbled heart-shaped leaves",
            imagePrompt: "Cyclamen hederifolium ivy-leaved cyclamen with pink swept-back flowers, marbled heart leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Anagallis arvensis",
            commonNames: ["Scarlet Pimpernel", "Poor Man's Weather-glass", "Shepherd's Weather-glass"],
            family: "Primulaceae",
            nativeRegions: ["Europe", "Asia", "North Africa"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Wildlife gardens", "Traditional weather forecasting"],
            interestingFacts: [
                "Flowers close before rain (hence weather-glass)",
                "Annual with prostrate spreading habit",
                "Usually scarlet but blue forms exist",
                "Traditional remedy but now known to be toxic"
            ],
            careInstructions: "Well-drained soil, full sun. Self-seeds in disturbed ground.",
            rarityLevel: .common,
            continents: [.europe, .asia, .africa, .northAmerica],
            habitat: "Fields, gardens, and waste areas",
            description: "Small bright red five-petaled flowers that close in cloudy weather",
            imagePrompt: "Anagallis arvensis scarlet pimpernel with small bright red flowers, prostrate spreading habit"
        ),
        
        BotanicalSpecies(
            scientificName: "Lysimachia nummularia",
            commonNames: ["Creeping Jenny", "Moneywort", "Herb Twopence"],
            family: "Primulaceae",
            nativeRegions: ["Europe"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ground cover", "Pond margins", "Hanging baskets"],
            interestingFacts: [
                "Trailing perennial spreading by runners",
                "Round leaves resemble coins (hence moneywort)",
                "Tolerates wet conditions and shallow water",
                "Golden cultivar 'Aurea' popular"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Spreads rapidly.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Stream banks and moist gardens",
            description: "Bright yellow cup-shaped flowers along trailing stems with round leaves",
            imagePrompt: "Lysimachia nummularia creeping jenny with yellow cup flowers, trailing stems, round leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Dodecatheon media",
            commonNames: ["Shooting Star", "American Cowslip", "Pride of Ohio"],
            family: "Primulaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late spring",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Woodland gardens", "Spring ephemerals"],
            interestingFacts: [
                "Flowers have swept-back petals like cyclamen",
                "Perennial going dormant by mid-summer",
                "Important early nectar source",
                "Forms colonies from underground bulbs"
            ],
            careInstructions: "Moist, rich soil. Partial shade. Summer dormancy normal.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Prairies, woodlands, and moist meadows",
            description: "Pink or white flowers with swept-back petals pointing skyward",
            imagePrompt: "Dodecatheon media shooting star with pink-white flowers, swept-back petals, native wildflower"
        ),
        
        BotanicalSpecies(
            scientificName: "Primula polyantha",
            commonNames: ["Polyantha Primrose", "English Primrose"],
            family: "Primulaceae",
            nativeRegions: ["Garden hybrid"],
            bloomingSeason: "Spring",
            conservationStatus: "Cultivated",
            uses: ["Ornamental", "Spring bedding", "Container gardens"],
            interestingFacts: [
                "Complex hybrid developed from crossing multiple primula species including P. vulgaris, P. veris, and P. elatior",
                "First bred in England during the Victorian era, becoming immensely popular for spring gardens",
                "Available in a rainbow of colors including red, pink, yellow, white, blue, and bicolors",
                "Flowers are edible and can be candied for cake decorations or used in salads"
            ],
            careInstructions: "Rich, moist soil. Cool weather. Partial shade to full sun.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Cultivated gardens, containers, and borders",
            description: "Clusters of large, fragrant flowers in many soft colors rise above neat rosettes of textured green leaves",
            imagePrompt: "Primula polyantha polyantha primrose with clusters of soft multicolored flowers, rosette leaves"
        ),
        
        BotanicalSpecies(
            scientificName: "Lysimachia clethroides",
            commonNames: ["Gooseneck Loosestrife", "Japanese Loosestrife"],
            family: "Primulaceae",
            nativeRegions: ["China", "Korea", "Japan"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Bog gardens"],
            interestingFacts: [
                "Flower spikes curve like goose necks",
                "Perennial spreading by underground stolons",
                "Can be aggressive in ideal conditions",
                "Excellent cut flower with long vase life"
            ],
            careInstructions: "Moist soil, full sun to partial shade. Can be invasive.",
            rarityLevel: .uncommon,
            continents: [.asia, .northAmerica],
            habitat: "Moist areas and garden borders",
            description: "White flowers in curved terminal spikes resembling goose necks",
            imagePrompt: "Lysimachia clethroides gooseneck loosestrife with white curved flower spikes, goose neck shape"
        ),
        
        BotanicalSpecies(
            scientificName: "Androsace septentrionalis",
            commonNames: ["Northern Rock Jasmine", "Pygmy Flower"],
            family: "Primulaceae",
            nativeRegions: ["Northern Hemisphere"],
            bloomingSeason: "Spring",
            conservationStatus: "Least Concern",
            uses: ["Rock gardens", "Alpine gardens", "Wild gardens"],
            interestingFacts: [
                "Tiny annual adapted to harsh conditions",
                "Circumboreal distribution in arctic regions",
                "Forms small rosettes with minute flowers",
                "Important pioneer species in disturbed soils"
            ],
            careInstructions: "Well-drained, sandy soil. Full sun. Excellent drainage essential.",
            rarityLevel: .rare,
            continents: [.northAmerica, .europe, .asia],
            habitat: "Rocky areas and arctic regions",
            description: "Tiny white flowers in small umbels above minute rosettes",
            imagePrompt: "Androsace septentrionalis northern rock jasmine with tiny white flowers, small umbels, alpine plant"
        ),
        
        // MARK: - Campanulaceae (Bellflower Family) - 10 species
        
        BotanicalSpecies(
            scientificName: "Campanula medium",
            commonNames: ["Canterbury Bells", "Cup and Saucer"],
            family: "Campanulaceae",
            nativeRegions: ["Southern Europe"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Cottage gardens"],
            interestingFacts: [
                "Biennial producing flowers second year",
                "Large bell-shaped flowers up to 2 inches",
                "Traditional cottage garden plant",
                "Available in blue, pink, white, and purple"
            ],
            careInstructions: "Rich, well-drained soil. Full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Gardens and naturalized areas",
            description: "Large bell-shaped flowers in blue, pink, white, or purple",
            imagePrompt: "Campanula medium Canterbury bells with large bell-shaped flowers, blue pink white purple, cottage garden"
        ),
        
        BotanicalSpecies(
            scientificName: "Campanula persicifolia",
            commonNames: ["Peach-leaved Bellflower", "Peach Bells"],
            family: "Campanulaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Perennial borders"],
            interestingFacts: [
                "Perennial with tall flowering spikes",
                "Leaves resemble peach tree leaves",
                "Long-lasting cut flowers",
                "Self-seeds readily in gardens"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Regular watering.",
            rarityLevel: .common,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Woodland edges and gardens",
            description: "Blue or white cup-shaped flowers on tall spikes",
            imagePrompt: "Campanula persicifolia peach-leaved bellflower with blue-white cup flowers, tall spikes, perennial border"
        ),
        
        BotanicalSpecies(
            scientificName: "Campanula rotundifolia",
            commonNames: ["Harebell", "Bluebell of Scotland", "Witch's Bells"],
            family: "Campanulaceae",
            nativeRegions: ["Northern Hemisphere"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Rock gardens", "Native plant gardens", "Naturalizing"],
            interestingFacts: [
                "Perennial with delicate nodding flowers",
                "Round basal leaves disappear early",
                "National flower of Scotland",
                "Widely distributed in temperate regions"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Drought tolerant.",
            rarityLevel: .common,
            continents: [.northAmerica, .europe, .asia],
            habitat: "Rocky areas, meadows, and moorlands",
            description: "Delicate blue bell-shaped flowers nodding on slender stems",
            imagePrompt: "Campanula rotundifolia harebell with delicate blue bell flowers nodding on slender stems, Scotland"
        ),
        
        BotanicalSpecies(
            scientificName: "Lobelia erinus",
            commonNames: ["Edging Lobelia", "Garden Lobelia", "Trailing Lobelia"],
            family: "Campanulaceae",
            nativeRegions: ["South Africa"],
            bloomingSeason: "Spring through fall",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Edging", "Hanging baskets", "Container gardens"],
            interestingFacts: [
                "Annual with masses of small flowers",
                "Available in trailing and compact forms",
                "Prefers cool weather, struggles in heat",
                "Popular for blue flower color"
            ],
            careInstructions: "Rich, moist soil. Partial shade in hot climates. Regular watering.",
            rarityLevel: .common,
            continents: [.africa, .northAmerica, .europe],
            habitat: "Gardens and containers",
            description: "Masses of small blue, white, or pink flowers with distinct lips",
            imagePrompt: "Lobelia erinus edging lobelia with masses of small blue-white-pink flowers, trailing habit"
        ),
        
        BotanicalSpecies(
            scientificName: "Lobelia cardinalis",
            commonNames: ["Cardinal Flower", "Red Lobelia"],
            family: "Campanulaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Bog gardens", "Hummingbird gardens"],
            interestingFacts: [
                "Brilliant red spikes attract hummingbirds",
                "Perennial requiring consistently moist soil",
                "Native American medicinal plant",
                "Can grow 4+ feet tall in ideal conditions"
            ],
            careInstructions: "Moist to wet soil. Partial shade to full sun. Consistent moisture needed.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Stream banks, wet meadows, and bog gardens",
            description: "Brilliant scarlet flowers in tall terminal spikes",
            imagePrompt: "Lobelia cardinalis cardinal flower with brilliant scarlet flowers, tall spikes, hummingbird plant"
        ),
        
        BotanicalSpecies(
            scientificName: "Platycodon grandiflorus",
            commonNames: ["Balloon Flower", "Chinese Bellflower"],
            family: "Campanulaceae",
            nativeRegions: ["East Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Ornamental", "Cut flowers", "Perennial borders"],
            interestingFacts: [
                "Flower buds inflate like balloons before opening",
                "Perennial with late spring emergence",
                "Long-lived with deep taproots",
                "Available in blue, white, and pink"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Drought tolerant once established.",
            rarityLevel: .common,
            continents: [.asia, .northAmerica, .europe],
            habitat: "Gardens and naturalized areas",
            description: "Large star-shaped flowers that start as inflated balloon buds",
            imagePrompt: "Platycodon grandiflorus balloon flower with large star-shaped flowers, inflated balloon buds"
        ),
        
        BotanicalSpecies(
            scientificName: "Campanula carpatica",
            commonNames: ["Carpathian Bellflower", "Carpathian Harebell", "Tussock Bellflower"],
            family: "Campanulaceae",
            nativeRegions: ["Carpathian Mountains"],
            bloomingSeason: "Summer",
            conservationStatus: "Least Concern",
            uses: ["Rock gardens", "Ground cover", "Front of borders"],
            interestingFacts: [
                "Low-growing perennial forming tufts",
                "Blooms over long period",
                "Tolerates poor soils well",
                "Popular for edging and rock gardens"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Drought tolerant.",
            rarityLevel: .common,
            continents: [.europe, .northAmerica],
            habitat: "Rocky mountains and gardens",
            description: "Large cup-shaped flowers in blue or white above low mounds",
            imagePrompt: "Campanula carpatica Carpathian bellflower with cup-shaped blue-white flowers, low mounding habit"
        ),
        
        BotanicalSpecies(
            scientificName: "Adenophora stricta",
            commonNames: ["Ladybell", "Strict Ladybell"],
            family: "Campanulaceae",
            nativeRegions: ["East Asia"],
            bloomingSeason: "Mid to late summer",
            conservationStatus: "Least Concern",
            uses: ["Perennial borders", "Cut flowers", "Cottage gardens"],
            interestingFacts: [
                "Perennial related to bellflowers",
                "Flowers have protruding style",
                "Long-lived with deep taproots",
                "Fragrant flowers attract bees"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Drought tolerant once established.",
            rarityLevel: .uncommon,
            continents: [.asia, .northAmerica],
            habitat: "Meadows and garden borders",
            description: "Pale blue bell-shaped flowers with protruding styles in tall spikes",
            imagePrompt: "Adenophora stricta ladybell with pale blue bell flowers, protruding styles, tall garden spikes"
        ),
        
        BotanicalSpecies(
            scientificName: "Campanula glomerata",
            commonNames: ["Clustered Bellflower", "Danesblood"],
            family: "Campanulaceae",
            nativeRegions: ["Europe", "Asia"],
            bloomingSeason: "Early to mid-summer",
            conservationStatus: "Least Concern",
            uses: ["Perennial borders", "Wildflower gardens", "Cut flowers"],
            interestingFacts: [
                "Flowers cluster at stem tips and leaf axils",
                "Perennial spreading by underground stolons",
                "Purple-blue flowers in dense clusters",
                "Traditional medicinal uses"
            ],
            careInstructions: "Well-drained soil, full sun to partial shade. Can spread vigorously.",
            rarityLevel: .uncommon,
            continents: [.europe, .asia, .northAmerica],
            habitat: "Grasslands and garden borders",
            description: "Dense clusters of purple-blue bell-shaped flowers",
            imagePrompt: "Campanula glomerata clustered bellflower with dense purple-blue flower clusters, perennial border"
        ),
        
        BotanicalSpecies(
            scientificName: "Lobelia siphilitica",
            commonNames: ["Great Blue Lobelia", "Blue Cardinal Flower"],
            family: "Campanulaceae",
            nativeRegions: ["Eastern North America"],
            bloomingSeason: "Late summer to early fall",
            conservationStatus: "Least Concern",
            uses: ["Native plant gardens", "Bog gardens", "Butterfly gardens"],
            interestingFacts: [
                "Blue counterpart to red cardinal flower",
                "Perennial preferring moist conditions",
                "Important late-season nectar source",
                "Native American medicinal plant"
            ],
            careInstructions: "Moist soil, partial shade to full sun. Consistent moisture preferred.",
            rarityLevel: .uncommon,
            continents: [.northAmerica],
            habitat: "Wet meadows and stream banks",
            description: "Spikes of bright blue flowers with white markings",
            imagePrompt: "Lobelia siphilitica great blue lobelia with bright blue flower spikes, white markings, native wetland"
        )
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