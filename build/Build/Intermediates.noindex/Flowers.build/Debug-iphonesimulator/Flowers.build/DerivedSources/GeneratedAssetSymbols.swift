import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "FlowerBackground" asset catalog color resource.
    static let flowerBackground = DeveloperToolsSupport.ColorResource(name: "FlowerBackground", bundle: resourceBundle)

    /// The "FlowerBackgroundSecondary" asset catalog color resource.
    static let flowerBackgroundSecondary = DeveloperToolsSupport.ColorResource(name: "FlowerBackgroundSecondary", bundle: resourceBundle)

    /// The "FlowerButtonBackground" asset catalog color resource.
    static let flowerButtonBackground = DeveloperToolsSupport.ColorResource(name: "FlowerButtonBackground", bundle: resourceBundle)

    /// The "FlowerCardBackground" asset catalog color resource.
    static let flowerCardBackground = DeveloperToolsSupport.ColorResource(name: "FlowerCardBackground", bundle: resourceBundle)

    /// The "FlowerDivider" asset catalog color resource.
    static let flowerDivider = DeveloperToolsSupport.ColorResource(name: "FlowerDivider", bundle: resourceBundle)

    /// The "FlowerError" asset catalog color resource.
    static let flowerError = DeveloperToolsSupport.ColorResource(name: "FlowerError", bundle: resourceBundle)

    /// The "FlowerInputBackground" asset catalog color resource.
    static let flowerInputBackground = DeveloperToolsSupport.ColorResource(name: "FlowerInputBackground", bundle: resourceBundle)

    /// The "FlowerPrimary" asset catalog color resource.
    static let flowerPrimary = DeveloperToolsSupport.ColorResource(name: "FlowerPrimary", bundle: resourceBundle)

    /// The "FlowerSecondary" asset catalog color resource.
    static let flowerSecondary = DeveloperToolsSupport.ColorResource(name: "FlowerSecondary", bundle: resourceBundle)

    /// The "FlowerSheetBackground" asset catalog color resource.
    static let flowerSheetBackground = DeveloperToolsSupport.ColorResource(name: "FlowerSheetBackground", bundle: resourceBundle)

    /// The "FlowerSuccess" asset catalog color resource.
    static let flowerSuccess = DeveloperToolsSupport.ColorResource(name: "FlowerSuccess", bundle: resourceBundle)

    /// The "FlowerTextPrimary" asset catalog color resource.
    static let flowerTextPrimary = DeveloperToolsSupport.ColorResource(name: "FlowerTextPrimary", bundle: resourceBundle)

    /// The "FlowerTextSecondary" asset catalog color resource.
    static let flowerTextSecondary = DeveloperToolsSupport.ColorResource(name: "FlowerTextSecondary", bundle: resourceBundle)

    /// The "FlowerTextTertiary" asset catalog color resource.
    static let flowerTextTertiary = DeveloperToolsSupport.ColorResource(name: "FlowerTextTertiary", bundle: resourceBundle)

    /// The "FlowerWarning" asset catalog color resource.
    static let flowerWarning = DeveloperToolsSupport.ColorResource(name: "FlowerWarning", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Icon Flowers" asset catalog image resource.
    static let iconFlowers = DeveloperToolsSupport.ImageResource(name: "Icon Flowers", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AccentColor" asset catalog color.
    static var accent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "FlowerBackground" asset catalog color.
    static var flowerBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerBackground)
#else
        .init()
#endif
    }

    /// The "FlowerBackgroundSecondary" asset catalog color.
    static var flowerBackgroundSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerBackgroundSecondary)
#else
        .init()
#endif
    }

    /// The "FlowerButtonBackground" asset catalog color.
    static var flowerButtonBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerButtonBackground)
#else
        .init()
#endif
    }

    /// The "FlowerCardBackground" asset catalog color.
    static var flowerCardBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerCardBackground)
#else
        .init()
#endif
    }

    /// The "FlowerDivider" asset catalog color.
    static var flowerDivider: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerDivider)
#else
        .init()
#endif
    }

    /// The "FlowerError" asset catalog color.
    static var flowerError: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerError)
#else
        .init()
#endif
    }

    /// The "FlowerInputBackground" asset catalog color.
    static var flowerInputBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerInputBackground)
#else
        .init()
#endif
    }

    /// The "FlowerPrimary" asset catalog color.
    static var flowerPrimary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerPrimary)
#else
        .init()
#endif
    }

    /// The "FlowerSecondary" asset catalog color.
    static var flowerSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerSecondary)
#else
        .init()
#endif
    }

    /// The "FlowerSheetBackground" asset catalog color.
    static var flowerSheetBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerSheetBackground)
#else
        .init()
#endif
    }

    /// The "FlowerSuccess" asset catalog color.
    static var flowerSuccess: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerSuccess)
#else
        .init()
#endif
    }

    /// The "FlowerTextPrimary" asset catalog color.
    static var flowerTextPrimary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerTextPrimary)
#else
        .init()
#endif
    }

    /// The "FlowerTextSecondary" asset catalog color.
    static var flowerTextSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerTextSecondary)
#else
        .init()
#endif
    }

    /// The "FlowerTextTertiary" asset catalog color.
    static var flowerTextTertiary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerTextTertiary)
#else
        .init()
#endif
    }

    /// The "FlowerWarning" asset catalog color.
    static var flowerWarning: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .flowerWarning)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AccentColor" asset catalog color.
    static var accent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "FlowerBackground" asset catalog color.
    static var flowerBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerBackground)
#else
        .init()
#endif
    }

    /// The "FlowerBackgroundSecondary" asset catalog color.
    static var flowerBackgroundSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerBackgroundSecondary)
#else
        .init()
#endif
    }

    /// The "FlowerButtonBackground" asset catalog color.
    static var flowerButtonBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerButtonBackground)
#else
        .init()
#endif
    }

    /// The "FlowerCardBackground" asset catalog color.
    static var flowerCardBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerCardBackground)
#else
        .init()
#endif
    }

    /// The "FlowerDivider" asset catalog color.
    static var flowerDivider: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerDivider)
#else
        .init()
#endif
    }

    /// The "FlowerError" asset catalog color.
    static var flowerError: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerError)
#else
        .init()
#endif
    }

    /// The "FlowerInputBackground" asset catalog color.
    static var flowerInputBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerInputBackground)
#else
        .init()
#endif
    }

    /// The "FlowerPrimary" asset catalog color.
    static var flowerPrimary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerPrimary)
#else
        .init()
#endif
    }

    /// The "FlowerSecondary" asset catalog color.
    static var flowerSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerSecondary)
#else
        .init()
#endif
    }

    /// The "FlowerSheetBackground" asset catalog color.
    static var flowerSheetBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerSheetBackground)
#else
        .init()
#endif
    }

    /// The "FlowerSuccess" asset catalog color.
    static var flowerSuccess: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerSuccess)
#else
        .init()
#endif
    }

    /// The "FlowerTextPrimary" asset catalog color.
    static var flowerTextPrimary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerTextPrimary)
#else
        .init()
#endif
    }

    /// The "FlowerTextSecondary" asset catalog color.
    static var flowerTextSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerTextSecondary)
#else
        .init()
#endif
    }

    /// The "FlowerTextTertiary" asset catalog color.
    static var flowerTextTertiary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerTextTertiary)
#else
        .init()
#endif
    }

    /// The "FlowerWarning" asset catalog color.
    static var flowerWarning: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .flowerWarning)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "FlowerBackground" asset catalog color.
    static var flowerBackground: SwiftUI.Color { .init(.flowerBackground) }

    /// The "FlowerBackgroundSecondary" asset catalog color.
    static var flowerBackgroundSecondary: SwiftUI.Color { .init(.flowerBackgroundSecondary) }

    /// The "FlowerButtonBackground" asset catalog color.
    static var flowerButtonBackground: SwiftUI.Color { .init(.flowerButtonBackground) }

    /// The "FlowerCardBackground" asset catalog color.
    static var flowerCardBackground: SwiftUI.Color { .init(.flowerCardBackground) }

    /// The "FlowerDivider" asset catalog color.
    static var flowerDivider: SwiftUI.Color { .init(.flowerDivider) }

    /// The "FlowerError" asset catalog color.
    static var flowerError: SwiftUI.Color { .init(.flowerError) }

    /// The "FlowerInputBackground" asset catalog color.
    static var flowerInputBackground: SwiftUI.Color { .init(.flowerInputBackground) }

    /// The "FlowerPrimary" asset catalog color.
    static var flowerPrimary: SwiftUI.Color { .init(.flowerPrimary) }

    /// The "FlowerSecondary" asset catalog color.
    static var flowerSecondary: SwiftUI.Color { .init(.flowerSecondary) }

    /// The "FlowerSheetBackground" asset catalog color.
    static var flowerSheetBackground: SwiftUI.Color { .init(.flowerSheetBackground) }

    /// The "FlowerSuccess" asset catalog color.
    static var flowerSuccess: SwiftUI.Color { .init(.flowerSuccess) }

    /// The "FlowerTextPrimary" asset catalog color.
    static var flowerTextPrimary: SwiftUI.Color { .init(.flowerTextPrimary) }

    /// The "FlowerTextSecondary" asset catalog color.
    static var flowerTextSecondary: SwiftUI.Color { .init(.flowerTextSecondary) }

    /// The "FlowerTextTertiary" asset catalog color.
    static var flowerTextTertiary: SwiftUI.Color { .init(.flowerTextTertiary) }

    /// The "FlowerWarning" asset catalog color.
    static var flowerWarning: SwiftUI.Color { .init(.flowerWarning) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "FlowerBackground" asset catalog color.
    static var flowerBackground: SwiftUI.Color { .init(.flowerBackground) }

    /// The "FlowerBackgroundSecondary" asset catalog color.
    static var flowerBackgroundSecondary: SwiftUI.Color { .init(.flowerBackgroundSecondary) }

    /// The "FlowerButtonBackground" asset catalog color.
    static var flowerButtonBackground: SwiftUI.Color { .init(.flowerButtonBackground) }

    /// The "FlowerCardBackground" asset catalog color.
    static var flowerCardBackground: SwiftUI.Color { .init(.flowerCardBackground) }

    /// The "FlowerDivider" asset catalog color.
    static var flowerDivider: SwiftUI.Color { .init(.flowerDivider) }

    /// The "FlowerError" asset catalog color.
    static var flowerError: SwiftUI.Color { .init(.flowerError) }

    /// The "FlowerInputBackground" asset catalog color.
    static var flowerInputBackground: SwiftUI.Color { .init(.flowerInputBackground) }

    /// The "FlowerPrimary" asset catalog color.
    static var flowerPrimary: SwiftUI.Color { .init(.flowerPrimary) }

    /// The "FlowerSecondary" asset catalog color.
    static var flowerSecondary: SwiftUI.Color { .init(.flowerSecondary) }

    /// The "FlowerSheetBackground" asset catalog color.
    static var flowerSheetBackground: SwiftUI.Color { .init(.flowerSheetBackground) }

    /// The "FlowerSuccess" asset catalog color.
    static var flowerSuccess: SwiftUI.Color { .init(.flowerSuccess) }

    /// The "FlowerTextPrimary" asset catalog color.
    static var flowerTextPrimary: SwiftUI.Color { .init(.flowerTextPrimary) }

    /// The "FlowerTextSecondary" asset catalog color.
    static var flowerTextSecondary: SwiftUI.Color { .init(.flowerTextSecondary) }

    /// The "FlowerTextTertiary" asset catalog color.
    static var flowerTextTertiary: SwiftUI.Color { .init(.flowerTextTertiary) }

    /// The "FlowerWarning" asset catalog color.
    static var flowerWarning: SwiftUI.Color { .init(.flowerWarning) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Icon Flowers" asset catalog image.
    static var iconFlowers: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iconFlowers)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Icon Flowers" asset catalog image.
    static var iconFlowers: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iconFlowers)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

