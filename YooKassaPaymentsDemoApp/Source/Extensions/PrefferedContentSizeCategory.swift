import UIKit

extension UIContentSizeCategory {
    private static let accessibilityCategories: [UIContentSizeCategory] = [
        .accessibilityExtraExtraExtraLarge,
        .accessibilityExtraExtraLarge,
        .accessibilityExtraLarge,
        .accessibilityLarge,
        .accessibilityMedium,
    ]

    var isAccessibilitySizeCategory: Bool {
        isAccessibilityCategory
    }
}
