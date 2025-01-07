/* The MIT License
 *
 * Copyright © NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
@_implementationOnly import YooMoneyUI

// MARK: - Styles
extension UIView {
    enum Styles {
        enum YKSdk {
            static let defaultBackground = Style(name: "UIView.defaultBackground") { (view: UIView) in
                view.backgroundColor = UIColor.YKSdk.page
            }

            static let separator = Style(name: "separator") { (view: UIView) in
                view.backgroundColor = .YKSdk.divider
                view.heightConstraint.constant = 1 / UIScreen.main.scale
            }
        }

        /// Style for rounded view with shadow
        static let roundedShadow = Style(name: "UIView.roundedShadow") { (view: UIView) in
            view.layer.borderColor = UIColor.YKSdk.border.cgColor
            view.layer.borderWidth = 1
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.12
            view.layer.shadowRadius = 8
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.masksToBounds = false
            view.layer.cornerRadius = 8
        }

        /// Style for gray border
        static let grayBorder = Style(name: "UIView.grayBorder") { (view: UIView) in
            view.layer.borderColor = UIColor.YKSdk.border.cgColor
            view.layer.borderWidth = 1
        }

        /// Style for alert border
        static let alertBorder = Style(name: "UIView.alertBorder") { (view: UIView) in
            view.layer.borderColor = UIColor.YKSdk.redOrange.cgColor
            view.layer.borderWidth = 1
        }
    }
}
