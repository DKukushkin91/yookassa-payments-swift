import UIKit

// MARK: - Decorator

extension LargeActionInformer {
    struct Style {
        private let target: LargeActionInformer
        // Decorate target with default setup
        @discardableResult
        static func `default`(_ target: LargeActionInformer) -> Style {
            Style(target: target)
        }

        private init(target: LargeActionInformer) {
            self.target = target
            self.default()
        }

        @discardableResult
        private func `default`() -> Style {
            target.iconView.setStyles(IconView.Styles.Tint.normal)
            target.backgroundColor = .YKSdk.divider
            target.buttonLabel.setStyles(UILabel.DynamicStyle.bodySemibold)
            target.buttonLabel.textColor = target.tintColor
            target.messageLabel.setStyles(
                UILabel.DynamicStyle.body,
                UILabel.Styles.quadrupleLine
            )
            target.messageLabel.textColor = .YKSdk.secondary
            return self
        }

        @discardableResult
        func alert() -> Style {
            target.iconView.image = UIImage.named("ic_attention_m").colorizedImage(color: .YKSdk.redOrange)
            target.buttonLabel.textColor = .YKSdk.ghost
            return self
        }
    }
}
