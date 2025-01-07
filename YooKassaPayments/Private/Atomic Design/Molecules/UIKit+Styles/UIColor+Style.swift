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

extension UIColor {

    static func highlighted(from color: UIColor) -> UIColor {
        return color.withAlphaComponent(0.5)
    }

    /// FadeTint from tint color
    static func fadeTint(from color: UIColor) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getHue(&hue,
                           saturation: &saturation,
                           brightness: &brightness,
                           alpha: &alpha) else { return color }
        saturation *= 0.5
        brightness *= 0.9
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    static func ghostTint(from color: UIColor) -> UIColor {
        var colors: (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        color.getRed(&colors.0, green: &colors.1, blue: &colors.2, alpha: &colors.3)
        return UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: 0.15)
    }
}
