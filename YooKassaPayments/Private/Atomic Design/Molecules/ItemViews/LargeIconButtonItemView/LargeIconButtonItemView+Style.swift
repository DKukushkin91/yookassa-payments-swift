import UIKit
@_implementationOnly import YooMoneyUI

extension LargeIconButtonItemView {
    enum Styles {

        static let secondary = Style(
            name: "LargeIconButtonItemView.secondary"
        ) { (item: LargeIconButtonItemView) in
            item.titleLabel.setStyles(UILabel.DynamicStyle.body)
            item.titleLabel.textColor = .YKSdk.primary

            item.subtitleLabel.setStyles(UILabel.DynamicStyle.bodyMedium)
            item.subtitleLabel.textColor = .YKSdk.secondary

            item.rightButton.tintColor = item.tintColor
        }
    }
}
