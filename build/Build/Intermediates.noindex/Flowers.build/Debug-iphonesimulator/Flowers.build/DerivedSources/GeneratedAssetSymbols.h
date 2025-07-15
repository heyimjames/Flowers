#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"OCTOBER.Flowers";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "FlowerBackground" asset catalog color resource.
static NSString * const ACColorNameFlowerBackground AC_SWIFT_PRIVATE = @"FlowerBackground";

/// The "FlowerBackgroundSecondary" asset catalog color resource.
static NSString * const ACColorNameFlowerBackgroundSecondary AC_SWIFT_PRIVATE = @"FlowerBackgroundSecondary";

/// The "FlowerButtonBackground" asset catalog color resource.
static NSString * const ACColorNameFlowerButtonBackground AC_SWIFT_PRIVATE = @"FlowerButtonBackground";

/// The "FlowerCardBackground" asset catalog color resource.
static NSString * const ACColorNameFlowerCardBackground AC_SWIFT_PRIVATE = @"FlowerCardBackground";

/// The "FlowerDivider" asset catalog color resource.
static NSString * const ACColorNameFlowerDivider AC_SWIFT_PRIVATE = @"FlowerDivider";

/// The "FlowerError" asset catalog color resource.
static NSString * const ACColorNameFlowerError AC_SWIFT_PRIVATE = @"FlowerError";

/// The "FlowerInputBackground" asset catalog color resource.
static NSString * const ACColorNameFlowerInputBackground AC_SWIFT_PRIVATE = @"FlowerInputBackground";

/// The "FlowerPrimary" asset catalog color resource.
static NSString * const ACColorNameFlowerPrimary AC_SWIFT_PRIVATE = @"FlowerPrimary";

/// The "FlowerSecondary" asset catalog color resource.
static NSString * const ACColorNameFlowerSecondary AC_SWIFT_PRIVATE = @"FlowerSecondary";

/// The "FlowerSheetBackground" asset catalog color resource.
static NSString * const ACColorNameFlowerSheetBackground AC_SWIFT_PRIVATE = @"FlowerSheetBackground";

/// The "FlowerSuccess" asset catalog color resource.
static NSString * const ACColorNameFlowerSuccess AC_SWIFT_PRIVATE = @"FlowerSuccess";

/// The "FlowerTextPrimary" asset catalog color resource.
static NSString * const ACColorNameFlowerTextPrimary AC_SWIFT_PRIVATE = @"FlowerTextPrimary";

/// The "FlowerTextSecondary" asset catalog color resource.
static NSString * const ACColorNameFlowerTextSecondary AC_SWIFT_PRIVATE = @"FlowerTextSecondary";

/// The "FlowerTextTertiary" asset catalog color resource.
static NSString * const ACColorNameFlowerTextTertiary AC_SWIFT_PRIVATE = @"FlowerTextTertiary";

/// The "FlowerWarning" asset catalog color resource.
static NSString * const ACColorNameFlowerWarning AC_SWIFT_PRIVATE = @"FlowerWarning";

#undef AC_SWIFT_PRIVATE
