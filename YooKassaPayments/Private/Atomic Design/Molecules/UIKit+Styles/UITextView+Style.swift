import UIKit
@_implementationOnly import YooMoneyUI

// MARK: - Styles

extension UITextView {

    enum Styles {
        enum YKSdk {

            private static let common = Style(name: "textView.common") { (textView: UITextView) in
                textView.isEditable = false
                textView.isScrollEnabled = false
                textView.textContainerInset = .zero
                textView.textContainer.lineFragmentPadding = 0
            }

            /// Linked style
            ///
            /// Text: Light font, 12pt size, Link:
            static let linked = common +
            Style(name: "linked") { (textView: UITextView) in
                textView.textColor = .YKSdk.secondary
                textView.font = .dynamicCaption1
                textView.linkTextAttributes = [
                    .foregroundColor: textView.tintColor ?? .YKSdk.mainScheme,
                ]
            }

            /// Linked style
            ///
            /// Text: Light font, 16pt size, Link:
            static let linkedBody = common +
            Style(name: "linkedBody") { (textView: UITextView) in
                textView.textColor = .YKSdk.primary
                textView.font = .dynamicBody
                textView.linkTextAttributes = [
                    .foregroundColor: textView.tintColor ?? .YKSdk.mainScheme,
                ]
            }
        }
    }
}
