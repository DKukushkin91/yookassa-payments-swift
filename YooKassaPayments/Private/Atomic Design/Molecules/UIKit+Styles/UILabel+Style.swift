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

extension UILabel {

    // MARK: - Styles

    enum Styles {
        /// Caption style.
        ///
        /// caption font, black50 color
        static let caption = makeStyle(name: "caption", attributes: [
            .font: UIFont.caption,
            .foregroundColor: UIColor.black50,
        ])

        // MARK: - Modifications

        /// Uppercasing all characters
        static let uppercased = Style(name: "uppercased") { (label: UILabel) in
            guard let text = label.text,
                  let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init)  else { return }
            let range = NSRange(location: 0, length: (text as NSString).length)
            attributedText.replaceCharacters(in: range, with: text.uppercased())
            label.attributedText = attributedText
        }

        /// Appling Ultralight face for fractional part of string representing decimal value
        static let ultralightFractionalPart
            = Style(name: "UILabel.ultralightFractionalPart") { (label: UILabel) in
                guard let text = label.text,
                      let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init) else { return }

                let decimalSeparator = Character(NSLocale.current.decimalSeparator ?? ".")
                let decimalParts = text.split(separator: decimalSeparator)
                guard decimalParts.count == 2, decimalParts[1].isEmpty == false else { return }

                let range = NSRange(location: decimalParts[0].count + 1, length: decimalParts[1].count)
                let descriptor = label.font.fontDescriptor
                    .withFamily(label.font.familyName)
                    .withFace("Ultralight")
                let font = UIFont(descriptor: descriptor, size: 0)
                attributedText.setAttributes([.font: font], range: range)
                label.attributedText = attributedText
            }

        // MARK: - ActionSheet

        /// Style for simple action sheet title label.
        static let simpleActionSheetItem = Styles.body1 + Styles.multiline

        /// Style for simple action sheet title label.
        static let actionSheetHeader = Styles.button + Styles.multiline

        // MARK: - Internal Styles

        /// Style for error toast.
        ///
        /// multiline, body2 font
        static let toast = Styles.multiline
            + makeStyle(
                name: "toast",
                attributes: [
                    .font: UIFont.body2,
                    .foregroundColor: UIColor.white90,
                ]
            )
            + UIView.Styles.heightAsContent
    }
}

private func makeStyle(name: String, attributes: [NSAttributedString.Key: Any]) -> Style {
    return Style(name: name) { (label: UILabel) in
        label.attributedText = label.attributedText.flatMap {
            makeAttributedString(attributedString: $0, attributes: attributes)
        }
    }
}

private func makeStyle(
    name: String,
    paragraphModifier: @escaping (NSMutableParagraphStyle) -> NSParagraphStyle
) -> Style {
    return Style(name: name) { (label: UILabel) in
        guard let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init),
              attributedText.length > 0 else { return }
        let range = NSRange(location: 0, length: (attributedText.string as NSString).length)
        var paragraph = (
            attributedText.attribute(
                .paragraphStyle,
                at: 0,
                effectiveRange: nil
            ) as? NSParagraphStyle) ?? .default
        // swiftlint:disable:next force_cast
        paragraph = paragraphModifier(paragraph.mutableCopy() as! NSMutableParagraphStyle)
        attributedText.addAttributes([.paragraphStyle: paragraph], range: range)
        label.attributedText = attributedText
    }
}

private func makeAttributedString(
    attributedString: NSAttributedString,
    attributes: [NSAttributedString.Key: Any]
) -> NSAttributedString {
    let range = NSRange(location: 0, length: (attributedString.string as NSString).length)
    let attributedString = NSMutableAttributedString(attributedString: attributedString)
    attributedString.addAttributes(attributes, range: range)
    return attributedString
}
