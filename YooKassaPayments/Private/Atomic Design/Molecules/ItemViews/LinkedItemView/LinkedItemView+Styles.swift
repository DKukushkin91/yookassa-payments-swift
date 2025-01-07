import UIKit
@_implementationOnly import YooMoneyUI

extension LinkedItemView {

    enum Styles {

        /// Style for linked switch item view.
        ///
        /// Text: secondary color
        static let linked = Style(
            name: "LinkedItemView.linked"
        ) { (item: LinkedItemView) in
            item.linkedTextView.setStyles(UITextView.Styles.YKSdk.linked)
        }
    }
}
