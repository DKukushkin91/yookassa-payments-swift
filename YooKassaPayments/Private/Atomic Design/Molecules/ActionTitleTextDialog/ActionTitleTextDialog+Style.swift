import UIKit
@_implementationOnly import YooMoneyUI

// MARK: - Styles

extension ActionTitleTextDialog {

    enum Styles {

        /// Style for `default` ActionTitleTextDialog.
        static let `default` = UIView.Styles.transparent +
            Style(name: "ActionTitleTextDialog.default") { (view: ActionTitleTextDialog) in
                view.titleLabel.setStyles(
                    UILabel.DynamicStyle.title2,
                    UILabel.Styles.multiline,
                    UILabel.Styles.alignCenter
                )
                view.titleLabel.textColor = .YKSdk.primary
                view.textLabel.setStyles(
                    UILabel.DynamicStyle.body,
                    UILabel.Styles.multiline,
                    UILabel.Styles.alignCenter
                )
                view.textLabel.textColor = .YKSdk.secondary
                view.button.setStyles(UIButton.DynamicStyle.flat)
            }

        /// Style for a ActionTitleTextDialog to represent fail state.
        ///
        /// default style
        /// icon: fail with tintColor
        static let fail = ActionTitleTextDialog.Styles.`default` +
            Style(name: "ActionTitleTextDialog.fail") { (view: ActionTitleTextDialog) in
                view.iconView.image = UIImage.PlaceholderView.commonFail
            }
    }
}
