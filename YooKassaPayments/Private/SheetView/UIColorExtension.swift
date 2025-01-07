import UIKit

extension UIColor {
    convenience init(white: CGFloat, alpha: CGFloat = 1, black: CGFloat, darkAlpha: CGFloat = 1) {
        self.init { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor(white: black, alpha: darkAlpha)
            default:
                return UIColor(white: white, alpha: alpha)
            }
        }
    }
}
