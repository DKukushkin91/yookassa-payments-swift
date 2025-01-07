import SafariServices

final class LinkedCardRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - LinkedCardRouterInput

extension LinkedCardRouter: LinkedCardRouterInput {
    func showBrowser(_ url: URL) {
        guard url.scheme == "http" || url.scheme == "https" else { return }
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }

    func presentSafeDealInfo(title: String, body: String) {
        let viewController = SavePaymentMethodInfoAssembly.makeModule(
            inputData: .init(headerValue: title, bodyValue: body)
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        transitionHandler?.present(
            navigationController,
            animated: true,
            completion: {
                viewController.addCloseButtonIfNeeded(target: self, action: #selector(self.closeButtonDidPressed))
            }
        )
    }

    func presentPaymentAuthorizationModule(
        inputData: PaymentAuthorizationModuleInputData,
        moduleOutput: PaymentAuthorizationModuleOutput?
    ) {
        let viewController = PaymentAuthorizationAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func closePaymentAuthorization() {
        transitionHandler?.popTopViewController(animated: true)
    }

    @objc
    func closeButtonDidPressed() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }
}
