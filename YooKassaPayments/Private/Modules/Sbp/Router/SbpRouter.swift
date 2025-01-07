import SafariServices
@_implementationOnly import YooMoneyUI

final class SbpRouter {
	weak var transitionHandler: TransitionHandler?
}

// MARK: - SbpRouterInput

extension SbpRouter: SbpRouterInput {
    func showBrowser(url: URL) {
        guard url.scheme == "http" || url.scheme == "https" else { return }
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }

    func showAutopayInfoDetails(title: String, body: String) {
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

    @objc
    func closeButtonDidPressed() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }

    func openSbpConfirmationModule(
        inputData: SbpConfirmationModuleInputData,
        moduleOutput: SbpConfirmationModuleOutput
    ) {
        let viewController = SbpConfirmationAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }
}
