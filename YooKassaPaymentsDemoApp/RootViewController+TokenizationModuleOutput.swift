import UIKit
import YooKassaPayments

// MARK: - TokenizationModuleOutput

extension RootViewController: TokenizationModuleOutput {
    func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        self.token = token
        self.paymentMethodType = paymentMethodType

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let successViewController = SuccessViewController()
            successViewController.delegate = self
            successViewController.paymentMethodType = paymentMethodType
            self.presentedViewController?.present(successViewController, animated: true)
        }
    }

    func didFinish(
        on module: TokenizationModuleInput,
        with error: YooKassaPaymentsError?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }

    func didFailConfirmation(error: YooKassaPaymentsError?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let controller = UIAlertController(
                title: "Error",
                message: error?.localizedDescription ?? "no description",
                preferredStyle: .alert
            )
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(controller, animated: true)
        }
    }

    func didSuccessfullyConfirmation(
        paymentMethodType: PaymentMethodType
    ) {
        print("Please use new method instead - didFinishConfirmation()")
    }

    func didFinishConfirmation(paymentMethodType: PaymentMethodType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertController = UIAlertController(
                title: "Confirmation",
                message: "Confirmation process finished",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.dismiss(animated: true)
            self.present(alertController, animated: true)
        }
    }
}
