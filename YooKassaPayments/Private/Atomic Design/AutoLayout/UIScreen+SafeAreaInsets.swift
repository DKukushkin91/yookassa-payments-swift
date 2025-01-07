import UIKit

extension UIScreen {
    static var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
}
