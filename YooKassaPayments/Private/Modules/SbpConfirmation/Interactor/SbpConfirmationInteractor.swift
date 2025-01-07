import FunctionalSwift

final class SbpConfirmationInteractor {

    private let banksService: SbpBanksService
    private let paymentService: PaymentService
    private let clientApplicationKey: String
    private let analyticsService: AnalyticsTracking

    // MARK: - Init

	init(
        banksService: SbpBanksService,
        paymentService: PaymentService,
        clientApplicationKey: String,
        analyticsService: AnalyticsTracking
    ) {
        self.banksService = banksService
        self.paymentService = paymentService
        self.clientApplicationKey = clientApplicationKey
        self.analyticsService = analyticsService
    }
}

// MARK: - SbpConfirmationInteractorInput

extension SbpConfirmationInteractor: SbpConfirmationInteractorInput {

    func fetchPrioriryBanks() -> [String] {
        banksService.priorityBanksMemberIds
    }

    func fetchAllBanks(confirmationUrl: String) -> Promise<Error, [SbpBank]> {
        banksService.fetchBanks(
            clientApplicationKey: clientApplicationKey,
            confirmationUrl: confirmationUrl
        )
    }

    func fetchSbpPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment> {
        paymentService.fetchPayment(clientApplicationKey: clientApplicationKey, paymentId: paymentId)
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func trackAsync(event: AnalyticsEvent) async {
        _ = Task.detached {
            self.analyticsService.track(event: event)
        }
    }
}
