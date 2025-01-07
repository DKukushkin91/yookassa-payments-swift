import SafariServices

final class BankCardRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - BankCardRouterInput

extension BankCardRouter: BankCardRouterInput {
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
        presentSavePaymentMethodInfo(inputData: .init(headerValue: title, bodyValue: body))
    }

    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData) {
        let viewController = SavePaymentMethodInfoAssembly.makeModule(
            inputData: inputData
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        transitionHandler?.present(
            navigationController,
            animated: true,
            completion: {
                viewController.addCloseButtonIfNeeded(target: self, action: #selector(self.closeButtonDidPressed))
            }
        )
    }

    @objc
    func closeButtonDidPressed() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }
}
