import UIKit

final class NavigationController: UINavigationController {
    weak var moduleOutput: SheetViewModuleOutput?

    override func viewDidLoad() {
        presentationController?.delegate = self
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        func recapplyStyles(view: UIView) {
            view.applyStyles()
            view.subviews.forEach(recapplyStyles)
        }

        viewControllers.forEach { recapplyStyles(view: $0.view) }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension NavigationController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard UIScreen.main.traitCollection.userInterfaceIdiom == .pad else { return }

        moduleOutput?.didFinish(on: self, with: nil)
    }
}

// MARK: - TokenizationModuleInput

extension NavigationController: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String) {
        moduleOutput?.start3dsProcess(requestUrl: requestUrl)
    }

    func startConfirmationProcess(
        confirmationUrl: String,
        paymentMethodType: PaymentMethodType
    ) {
        moduleOutput?.startConfirmationProcess(
            confirmationUrl: confirmationUrl,
            paymentMethodType: paymentMethodType
        )
    }
}
