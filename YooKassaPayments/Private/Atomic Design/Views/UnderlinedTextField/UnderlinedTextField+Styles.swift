import UIKit
@_implementationOnly import YooMoneyUI

extension UnderlinedTextField {
    enum Styles {
        static let `default` = Style(name: "UnderlinedTextField.default") { (view: UnderlinedTextField) in
            view.textField.setStyles(UITextField.Styles.default)
        }

        /// Phone style.
        /// Phone keyboard; Text content type phone number.
        static let phone = Style(name: "UnderlinedTextField.numeric") { (view: UnderlinedTextField) in
            view.textField.setStyles(UITextField.Styles.phone)
        }
    }
}
