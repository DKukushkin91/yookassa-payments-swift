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
import YooMoneyUI

// MARK: - Styles
extension UIView {
    enum Styles {
        /// Style for view with tint background.
        static let tintBackground = Style(name: "tintBackground") { (view: UIView) in
            view.backgroundColor = view.tintColor
        }

        /// Style for semi transparent view.
        ///
        /// black65 background color.
        static let semiTransparent = Style(name: "semiTransparent") { (view: UIView) in
            view.backgroundColor = .black65
        }

        /// Style for view with inverse background.
        ///
        /// inverse30 background color.
        static let inverse30 = Style(name: "inverse30") { (view: UIView) in
            view.backgroundColor = .inverse30
        }

        /// Style for view with rounded gray border.
        ///
        /// border: black12 color, 1pt width, 8pt corner radius.
        static let roundedGrayBorder = Style(name: "UIView.Styles.roundedGrayBorder") { (view: UIView) in
            view.layer.borderColor = UIColor.black12.cgColor
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 8
        }

        static let heightAsContent = Style(name: "heightAsContent") { (view: UIView) in
            view.setContentCompressionResistancePriority(.required, for: .vertical)
            view.setContentHuggingPriority(.required, for: .vertical)
        }

        static let widthAsContent = Style(name: "widthAsContent") { (view: UIView) in
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .horizontal)
        }

        /// Style for shadow
        static let shadow = Style(name: "shadow") { (view: UIView) in
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.12
            view.layer.shadowRadius = 4
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.masksToBounds = false
        }

        static let shadowOffsetToTop = Style(name: "shadowOffsetToTop") { (view: UIView) in
            view.layer.shadowOffset = CGSize(width: 0, height: -2)
        }

        /// Style for rounded view with shadow
        static let roundedShadow = Style(name: "UIView.roundedShadow") { (view: UIView) in
            view.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
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
            view.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
            view.layer.borderWidth = 1
        }

        /// Style for alert border
        static let alertBorder = Style(name: "UIView.alertBorder") { (view: UIView) in
            view.layer.borderColor = UIColor.redOrange.cgColor
            view.layer.borderWidth = 1
        }
    }
}
