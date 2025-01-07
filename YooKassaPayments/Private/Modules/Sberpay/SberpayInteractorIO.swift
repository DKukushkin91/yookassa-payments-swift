import FunctionalSwift

protocol SberpayInteractorInput {
    func tokenizeSberpay(
        savePaymentMethod: Bool,
        returnUrl: String
    )

    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType

    func fetchConfirmationDetails(
        clientApplicationKey: String,
        confirmationUrl: String
    ) -> Promise<Error, (String, ConfirmationData)>
}

protocol SberpayInteractorOutput: AnyObject {
    func didTokenize(_ data: Tokens)
    func didFailTokenize(_ error: Error)
}
