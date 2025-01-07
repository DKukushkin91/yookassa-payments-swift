import UIKit
@_implementationOnly import YooMoneyUI

final class SbpConfirmationRouter {
	weak var transitionHandler: TransitionHandler?
}

// MARK: - SbpConfirmationRouterInput

extension SbpConfirmationRouter: SbpConfirmationRouterInput {

    func openMoreBanks(
        inputData: SbpBankSelectionInputData,
        moduleOutput: SbpBankSelectionModuleOutput
    ) {
        let moduleView = SbpBankSelectionAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        ).view
        let container = UINavigationController(rootViewController: moduleView)
        moduleView.addCloseButtonIfNeeded(target: self, action: #selector(close))

        transitionHandler?.present(container, animated: true, completion: nil)
    }

    @objc
    private func close() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }

    func openBankApp(url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
