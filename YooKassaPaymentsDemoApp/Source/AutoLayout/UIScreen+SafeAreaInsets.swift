import UIKit

extension UIScreen {
    static var safeAreaInsets: UIEdgeInsets {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene } ) as? UIWindowScene,
            let window = windowScene.windows.first
        else { return .zero }

        return window.safeAreaInsets
    }
}
