protocol LinkedCardInteractorInput {
    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool
    )

    func tokenize(
        id: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount
    )

    func hasReusableWalletToken() -> Bool

    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

protocol LinkedCardInteractorOutput: AnyObject {
    func didLoginInWallet(
        _ response: WalletLoginResponse
    )
    func failLoginInWallet(
        _ error: Error
    )

    func didTokenizeData(
        _ token: Tokens
    )
    func failTokenizeData(
        _ error: Error
    )
}
