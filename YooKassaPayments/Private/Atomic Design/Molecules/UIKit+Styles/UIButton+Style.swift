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
extension UIButton {

    enum DynamicStyle {

        static let primaryLink = YooMoneyUI.Style(name: "button.dynamic.secondaryLink") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail

            let font = UIFont.dynamicBody
            let color = button.tintColor ?? UIColor.YKSdk.secondary

            let colors: [(UIControl.State, UIColor)] = [
                (.normal, color),
                (.highlighted, .highlighted(from: color)),
                (.disabled, UIColor.YKSdk.disable),
            ]

            colors.forEach { (state, textColor) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: textColor,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
            }
        }
    }

    enum Styles {
        /// Generate rounded image for button background.
        static func roundedBackground(color: UIColor, cornerRadius: CGFloat = 0) -> UIImage {
            let side = cornerRadius * 2 + 2
            let size = CGSize(width: side, height: side)
            return UIImage.image(color: color)
                .scaled(to: size)
                .rounded(cornerRadius: cornerRadius)
                .resizableImage(
                    withCapInsets: UIEdgeInsets(
                        top: cornerRadius,
                        left: cornerRadius,
                        bottom: cornerRadius,
                        right: cornerRadius
                    )
                )
        }

        static let primary = Style(name: "button.style.primary") { (button: UIButton) in
            setupButton(
                button,
                colors: [
                    (.normal, .inverse, button.tintColor),
                    (.highlighted, .inverse, .highlighted(from: button.tintColor)),
                    (.disabled, .YKSdk.ghost, .YKSdk.disable),
                ]
            )
        }

        static let alert = Style(name: "button.style.alert") { (button: UIButton) in
            setupButton(
                button,
                colors: [
                    (.normal, .YKSdk.redOrange, .YKSdk.redOrange15),
                    (.highlighted, .YKSdk.redOrange, .highlighted(from: .YKSdk.redOrange15)),
                ]
            )
        }

        private static func setupButton(
            _ button: UIButton,
            colors: [(UIControl.State, foreground: UIColor, background: UIColor)]
        ) {
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.contentEdgeInsets.left = Space.double
            button.contentEdgeInsets.right = Space.double

            let font = UIFont.dynamicBodySemibold
            let cornerRadius = Constants.cornerRadius

            colors
                .map { ($0, $1, Styles.roundedBackground(color: $2, cornerRadius: cornerRadius)) }
                .forEach { (state, foreground, backgroundImage) in
                    guard let title = button.title(for: state) else { return }
                    let attributedTitle = NSAttributedString(string: title, attributes: [
                        .foregroundColor: foreground,
                        .font: font,
                    ])
                    button.setAttributedTitle(attributedTitle, for: state)
                    button.setBackgroundImage(backgroundImage, for: state)
                }

            NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 56)])
        }
    }
}

// MARK: - Constants
private extension UIButton {
    enum Constants {
        static let cornerRadius: CGFloat = 8
    }
}
