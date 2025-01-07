import FunctionalSwift

/// SbpConfirmation interactor input
protocol SbpConfirmationInteractorInput {
    func fetchPrioriryBanks() -> [String]
    func fetchAllBanks(confirmationUrl: String) -> Promise<Error, [SbpBank]>
    func fetchSbpPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment>
    func track(event: AnalyticsEvent)
    func trackAsync(event: AnalyticsEvent) async
}
