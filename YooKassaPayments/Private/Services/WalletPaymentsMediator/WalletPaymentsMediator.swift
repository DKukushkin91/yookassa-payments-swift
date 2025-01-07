import FunctionalSwift

enum WalletMoneySource {
    case wallet
    case linkedCard(id: String, csc: String)
}

protocol WalletPaymentsMediator {
    func tokenize(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        moneySource: WalletMoneySource
    ) -> Promise<Error, Tokens>

    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool
    ) -> Promise<Error, WalletLoginResponse>
}
