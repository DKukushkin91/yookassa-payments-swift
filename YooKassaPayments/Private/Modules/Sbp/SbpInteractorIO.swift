import FunctionalSwift

/// Sbp interactor input
protocol SbpInteractorInput {
    func tokenizeSbp(
        savePaymentMethod: Bool,
        returnUrl: String?
    )
    func analyticsAuthType() -> AnalyticsEvent.AuthType
    func track(event: AnalyticsEvent)
    func fetchConfirmationDetails(
        clientApplicationKey: String,
        confirmationUrl: String
    ) -> Promise<Error, (String, ConfirmationData)>
    func fetchSbpPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment>
}

/// Sbp interactor output
protocol SbpInteractorOutput: AnyObject {
    func didTokenize(_ data: Tokens)
    func didFailTokenize(_ error: Error)
}
