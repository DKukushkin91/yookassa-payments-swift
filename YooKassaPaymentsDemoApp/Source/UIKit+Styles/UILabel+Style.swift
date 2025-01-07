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

extension UILabel {
    // MARK: - Colors

    enum ColorStyle {
        static let black = Style(name: "color.black") { (label: UILabel) in
            label.textColor = .label
        }

        static let doveGray = Style(name: "color.doveGray") { (label: UILabel) in
            label.textColor = .secondaryLabel
        }

        static let nobel = Style(name: "color.nobel") { (label: UILabel) in
            label.textColor = .tertiaryLabel
        }

        enum Link {
            static let normal = Style(name: "color.link.normal") { (label: UILabel) in
                label.textColor = .link
            }

            static let highlighted = Style(name: "color.link.highlighted") { (label: UILabel) in
                label.textColor = UIColor.link.withAlphaComponent(0.5)
            }

            static let disabled = UILabel.ColorStyle.ghost
        }
    }
}

private func makeStyle(name: String, attributes: [NSAttributedString.Key: Any]) -> Style {
    return Style(name: name) { (label: UILabel) in
        label.attributedText = label.attributedText.flatMap {
            makeAttributedString(attributedString: $0, attributes: attributes)
        }
    }
}

private func makeStyle(name: String,
                       paragraphModifier: @escaping (NSMutableParagraphStyle) -> NSParagraphStyle) -> Style {
    return Style(name: name) { (label: UILabel) in
        guard let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init),
              attributedText.length > 0 else { return }
        let range = NSRange(location: 0, length: (attributedText.string as NSString).length)
        var paragraph = (attributedText
            .attribute(
                .paragraphStyle,
                at: 0,
                effectiveRange: nil
            ) as? NSParagraphStyle
        ) ?? .default

        // swiftlint:disable:next force_cast
        paragraph = paragraphModifier(paragraph.mutableCopy() as! NSMutableParagraphStyle)
        attributedText.addAttributes([.paragraphStyle: paragraph], range: range)
        label.attributedText = attributedText
    }
}

private func makeAttributedString(attributedString: NSAttributedString,
                                  attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {

    let range = NSRange(location: 0, length: (attributedString.string as NSString).length)
    let attributedString = NSMutableAttributedString(attributedString: attributedString)
    attributedString.addAttributes(attributes, range: range)
    return attributedString
}
