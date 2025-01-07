import UIKit

/// Settings to customize SDK interface.
public struct CustomizationSettings {

    /// Scheme to customize main interface, like,
    /// submit buttons, switches, text inputs.
    public let mainScheme: UIColor

    /// A Boolean value that determines whether YooKassa
    /// logo will be displayed on the screen of available payment methods.
    public let showYooKassaLogo: Bool

    /// Creates instance of `CustomizationSettings`.
    ///
    /// - Parameters:
    ///     - mainScheme: Scheme to customize main interface, like,
    ///                   submit buttons, switches, text inputs.
    ///     - showYooKassaLogo: A Boolean value that determines whether YooKassa
    ///                   logo will be displayed on the screen of available payment methods.
    public init(
        mainScheme: UIColor = CustomizationColors.mainScheme,
        showYooKassaLogo: Bool = true
    ) {
        self.mainScheme = mainScheme
        self.showYooKassaLogo = showYooKassaLogo
    }
}
