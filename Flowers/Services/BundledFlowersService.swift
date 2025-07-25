import Foundation
import UIKit

/// Service that provides pre-generated flower images bundled with the app
/// This ensures consistent, high-quality onboarding experience without API calls
class BundledFlowersService {
    static let shared = BundledFlowersService()
    
    private init() {}
    
    // Bundled flower data with asset names
    private let bundledFlowers: [(name: String, descriptor: String, assetName: String)] = [
        (
            name: "Cherry Blossom",
            descriptor: "delicate pink cherry blossom with soft white petals and golden center",
            assetName: "BundledFlower1"
        ),
        (
            name: "Sunflower",
            descriptor: "bright golden sunflower with vibrant yellow petals and dark center",
            assetName: "BundledFlower2"
        ),
        (
            name: "Rose",
            descriptor: "elegant red rose with velvety petals and dewdrops",
            assetName: "BundledFlower3"
        ),
        (
            name: "Lavender",
            descriptor: "purple lavender with delicate stems and calming fragrance",
            assetName: "BundledFlower4"
        ),
        (
            name: "Lily",
            descriptor: "pure white lily with graceful petals and golden stamens",
            assetName: "BundledFlower5"
        ),
        (
            name: "Orchid",
            descriptor: "exotic purple orchid with delicate speckled petals and elegant curves",
            assetName: "BundledFlower6"
        )
    ]
    
    /// Get a specific bundled flower by index
    func getBundledFlower(at index: Int) -> AIFlower? {
        guard index >= 0 && index < bundledFlowers.count else { return nil }
        
        let flowerData = bundledFlowers[index]
        
        // Try to load from asset catalog first
        var image: UIImage?
        if let assetImage = UIImage(named: flowerData.assetName) {
            image = assetImage
        } else {
            // Fallback to placeholder if asset not found
            image = createPlaceholderFlowerImage(color: getColorForIndex(index))
        }
        
        guard let finalImage = image,
              let imageData = finalImage.pngData() else { return nil }
        
        let flower = AIFlower(
            name: flowerData.name,
            descriptor: flowerData.descriptor,
            imageData: imageData,
            generatedDate: Date(),
            isFavorite: false,
            discoveryDate: Date()
        )
        
        return flower
    }
    
    /// Get all bundled flowers
    func getAllBundledFlowers() -> [AIFlower] {
        return bundledFlowers.enumerated().compactMap { index, _ in
            getBundledFlower(at: index)
        }
    }
    
    /// Get a random bundled flower
    func getRandomBundledFlower() -> AIFlower? {
        let randomIndex = Int.random(in: 0..<bundledFlowers.count)
        return getBundledFlower(at: randomIndex)
    }
    
    // MARK: - Placeholder Image Generation
    
    private func getColorForIndex(_ index: Int) -> UIColor {
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0),  // Pink
            UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0),   // Yellow
            UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0),   // Red
            UIColor(red: 0.7, green: 0.6, blue: 0.9, alpha: 1.0),   // Lavender
            UIColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)    // White
        ]
        return colors[index % colors.count]
    }
    
    private func createPlaceholderFlowerImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw a simple flower shape
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let petalRadius: CGFloat = 80
            let centerRadius: CGFloat = 40
            
            // Draw petals
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let petalCenter = CGPoint(
                    x: center.x + cos(angle) * petalRadius,
                    y: center.y + sin(angle) * petalRadius
                )
                
                let path = UIBezierPath(
                    arcCenter: petalCenter,
                    radius: petalRadius * 0.6,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: true
                )
                
                color.withAlphaComponent(0.8).setFill()
                path.fill()
            }
            
            // Draw center
            let centerPath = UIBezierPath(
                arcCenter: center,
                radius: centerRadius,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            
            UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0).setFill()
            centerPath.fill()
        }
    }
    
    // MARK: - Generate Real Flowers (One-time process for developers)
    
    /// This function would be used during development to generate and save real flower images
    /// The generated images would then be bundled with the app
    func generateAndSaveBundledFlowers() async {
        #if DEBUG
        print("🌸 Generating bundled flowers for onboarding...")
        
        // Create directory in documents
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputDirectory = documentsURL.appendingPathComponent("BundledFlowers")
        print("📁 Images will be saved to app documents: BundledFlowers/")
        
        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create output directory: \(error)")
            return
        }
        
        // Define better descriptors for FAL API
        let descriptors = [
            "ISOLATED on PLAIN WHITE BACKGROUND, delicate pink cherry blossom with soft white petals and golden center, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stem with leaves, dreamy and ethereal, VERY SOFT PASTEL COLORS, light and airy palette, muted gentle tones, subtle gradients, NO BRIGHT OR VIVID COLORS, pale delicate hues only, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K",
            "ISOLATED on PLAIN WHITE BACKGROUND, bright golden sunflower with vibrant yellow petals and dark center, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stem with leaves, dreamy and ethereal, SOFT YELLOW AND GOLDEN COLORS, light and airy palette, gentle tones, subtle gradients, pale delicate hues, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K",
            "ISOLATED on PLAIN WHITE BACKGROUND, elegant soft pink rose with velvety petals and dewdrops, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stem with leaves and thorns, dreamy and ethereal, VERY SOFT PASTEL PINK COLORS, light and airy palette, muted gentle tones, subtle gradients, NO BRIGHT OR VIVID COLORS, pale delicate hues only, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K",
            "ISOLATED on PLAIN WHITE BACKGROUND, purple lavender with delicate stems and tiny flowers, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stems with narrow leaves, dreamy and ethereal, VERY SOFT PASTEL PURPLE COLORS, light and airy palette, muted gentle tones, subtle gradients, NO BRIGHT OR VIVID COLORS, pale delicate hues only, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K",
            "ISOLATED on PLAIN WHITE BACKGROUND, pure white lily with graceful petals and golden stamens, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals, elegant stem with long leaves, dreamy and ethereal, VERY SOFT WHITE AND CREAM COLORS, light and airy palette, muted gentle tones, subtle gradients, NO BRIGHT OR VIVID COLORS, pale delicate hues only, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K",
            "ISOLATED on PLAIN WHITE BACKGROUND, exotic purple orchid with delicate speckled petals and elegant curved stems, NOTHING ELSE IN FRAME, pure white empty background, NO SHADOWS on background, botanical illustration style, soft watercolor texture, delicate petals with intricate patterns, graceful arching stem, dreamy and ethereal, VERY SOFT PASTEL PURPLE AND LAVENDER COLORS, light and airy palette, muted gentle tones, subtle gradients, NO BRIGHT OR VIVID COLORS, pale delicate hues only, desaturated colors, professional botanical art, COMPLETELY WHITE BACKGROUND, isolated subject, minimalist presentation, highly detailed, 4K"
        ]
        
        for (index, flowerData) in bundledFlowers.enumerated() {
            print("\n📸 Generating \(flowerData.name)...")
            
            do {
                // Generate real flower using FAL API
                let (image, _) = try await FALService.shared.generateFlowerImage(
                    descriptor: descriptors[index]
                )
                
                // Save as PNG
                if let imageData = image.pngData() {
                    let fileName = "\(flowerData.assetName).png"
                    let fileURL = outputDirectory.appendingPathComponent(fileName)
                    
                    try imageData.write(to: fileURL)
                    print("✅ Saved: \(fileName)")
                    print("   Size: \(imageData.count / 1024)KB")
                    print("   Path: \(fileURL.path)")
                    
                    // Also save @2x and @3x versions
                    let size2x = CGSize(width: image.size.width * 2, height: image.size.height * 2)
                    let size3x = CGSize(width: image.size.width * 3, height: image.size.height * 3)
                    
                    if let resized2x = resizeImage(image, to: size2x),
                       let data2x = resized2x.pngData() {
                        let file2xURL = outputDirectory.appendingPathComponent("\(flowerData.assetName)@2x.png")
                        try data2x.write(to: file2xURL)
                        print("   ✅ Saved @2x version")
                    }
                    
                    if let resized3x = resizeImage(image, to: size3x),
                       let data3x = resized3x.pngData() {
                        let file3xURL = outputDirectory.appendingPathComponent("\(flowerData.assetName)@3x.png")
                        try data3x.write(to: file3xURL)
                        print("   ✅ Saved @3x version")
                    }
                }
                
            } catch {
                print("❌ Failed to generate \(flowerData.name): \(error)")
            }
        }
        
        print("\n✅ All flowers generated!")
        print("📁 Images saved to: \(outputDirectory.path)")
        print("\n📝 To retrieve the images:")
        print("1. In Xcode: Window > Devices and Simulators")
        print("2. Select your device and this app")
        print("3. Click 'Download Container...' to save app data")
        print("4. Right-click the .xcappdata file > Show Package Contents")
        print("5. Navigate to: AppData/Documents/BundledFlowers/")
        print("6. Drag the images into Xcode's Assets.xcassets")
        print("7. Create image sets named BundledFlower1-5")
        print("\nAlternatively, if testing on simulator:")
        print("• Open Finder and go to: \(outputDirectory.path)")
        #endif
    }
    
    #if DEBUG
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    #endif
} 