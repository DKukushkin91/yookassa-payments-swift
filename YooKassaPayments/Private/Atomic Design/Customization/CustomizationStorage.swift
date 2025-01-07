import UIKit

/// Class for storing customization settings.
final class CustomizationStorage {

    /// Stored scheme to customize main interface, like,
    /// submit buttons, switches, text inputs.
    var mainScheme: UIColor = UIColor.YKSdk.mainScheme

    private init() {}

    /// Shared customization settings storage.
    static let shared = CustomizationStorage()
}
