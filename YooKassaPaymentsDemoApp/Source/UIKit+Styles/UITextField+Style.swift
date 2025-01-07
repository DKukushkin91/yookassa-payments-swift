import UIKit
import YooMoneyUI

// MARK: - Styles

extension UITextField {
    enum Styles {

        /// Default style
        /// Dynamic body font; Autocapitalization type none;
        /// Autocorrection type no; Clear button mode never;
        /// Spell checking type no.
        static let `default` = Style(name: "UITextField.default") { (textField: UITextField) in
            textField.font = .dynamicBody
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
            textField.spellCheckingType = .no
        }

        /// Secure style
        /// Default + isSecureTextEntry true.
        static let secure = UITextField.Styles.default
            + Style(name: "UITextField.secure") { (textField: UITextField) in
            textField.isSecureTextEntry = true
            }

        /// Numeric style.
        /// Numeric keyboard.
        static let numeric = Style(name: "UITextField.numeric") { (textField: UITextField) in
            textField.keyboardType = .numberPad
        }

        /// Phone style.
        /// Phone keyboard; Text content type phone number.
        static let phone = Style(name: "UITextField.phone") { (textField: UITextField) in
            textField.keyboardType = .phonePad
            textField.textContentType = .telephoneNumber
        }

        /// Center alignment.
        static let center = Style(name: "UITextField.center") { (textField: UITextField) in
            textField.textAlignment = .center
        }

        /// Left alignment.
        static let left = Style(name: "UITextField.left") { (textField: UITextField) in
            textField.textAlignment = .left
        }

        /// Style with title3 font.
        static let title3 = Style(name: "UITextField.title3") { (textField: UITextField) in
            textField.font = .dynamicTitle3
        }
    }
}
