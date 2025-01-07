import UIKit
@_implementationOnly import YooMoneyUI

extension SwitchItemView {

    enum Styles {

        /// Style for primary switch item view.
        ///
        /// default background color, body multiline title, tint switch.
        static let primary =
            UIView.Styles.YKSdk.defaultBackground +
            Style(name: "SwitchItemView.primary") { (item: SwitchItemView) in
                item.linkedTextView.tintColor = item.tintColor
                item.linkedTextView.setStyles(
                    UITextView.Styles.YKSdk.linkedBody
                )
                item.linkedTextView.textColor = .YKSdk.primary
                item.switchControl.onTintColor = item.tintColor
            }

        /// Style for secondary switch item view.
        ///
        /// default background color, caption1 secondary multiline title, tint switch.
        static let secondary =
            UIView.Styles.YKSdk.defaultBackground +
            Style(name: "SwitchItemView.secondary") { (item: SwitchItemView) in
                item.titleLabel.setStyles(
                    UITextView.Styles.YKSdk.linked
                )
                item.linkedTextView.textColor = .YKSdk.secondary
                item.switchControl.onTintColor = item.tintColor
            }
    }
}
