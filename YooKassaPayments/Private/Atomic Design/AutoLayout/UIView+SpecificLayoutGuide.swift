import UIKit

extension UIView {

    /// Returns the correct layout guide.
    var specificLayoutGuide: UILayoutGuide {
        safeAreaLayoutGuide
    }
}
