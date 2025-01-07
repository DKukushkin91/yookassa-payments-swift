import UIKit

extension KeyboardObserver where Self: UIViewController {

    /// Add self to keyboard changes observers. Starts receiving notifications implemented in KeyboardObserver.
    func startKeyboardObserving() {
        KeyboardObservable.shared.addKeyboardObserver(self)
    }

    /// Remove self from keyboard changes observers. Stops receiving notifications implemented in KeyboardObserver.
    func stopKeyboardObserving() {
        KeyboardObservable.shared.removeKeyboardObserver(self)
    }

    /// - Parameter keyboardFrame: raw keyboard frame from Keyboard Notification info
    /// - Returns: Keyboard Y offset
    func keyboardYOffset(from keyboardFrame: CGRect) -> CGFloat? {
        let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
        let intersectionViewFrame = convertedKeyboardFrame.intersection(view.bounds)
        let intersectionSafeFrame = convertedKeyboardFrame.intersection(view.safeAreaLayoutGuide.layoutFrame)
        let safeOffset = intersectionViewFrame.height - intersectionSafeFrame.height
        let intersectionOffset = intersectionViewFrame.size.height
        guard convertedKeyboardFrame.minY.isInfinite == false else {
            return nil
        }
        let keyboardOffset = intersectionOffset - safeOffset
        return keyboardOffset
    }

    /// Returns a Boolean value indicating whether the observer is subscribed to keyboard notifications
    var isSubscribedToKeyboardNotifications: Bool {
        return KeyboardObservable.shared.isSubscribed(self)
    }
}

extension UIViewController {
    func removeKeyboardObservers() {
        if let observer = self as? KeyboardObserver {
            KeyboardObservable.shared.removeKeyboardObserver(observer)
        }

        children.forEach {
            $0.removeKeyboardObservers()
        }
    }

    func appendKeyboardObservers() {
        if let observer = self as? KeyboardObserver {
            KeyboardObservable.shared.addKeyboardObserver(observer)
        }

        children.forEach {
            $0.appendKeyboardObservers()
        }
    }
}
