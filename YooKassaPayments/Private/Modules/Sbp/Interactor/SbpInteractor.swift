import FunctionalSwift

final class SbpInteractor {

    // MARK: - VIPER

    weak var output: SbpInteractorOutput?

    // MARK: - Init

    private let authService: AuthorizationService
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let banksService: SbpBanksService
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let customerId: String?

    init(
        authService: AuthorizationService,
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        banksService: SbpBanksService,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        customerId: String?
    ) {
        self.authService = authService
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.banksService = banksService
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.customerId = customerId
    }
}

// MARK: - SbpInteractorInput

extension SbpInteractor: SbpInteractorInput {
    func tokenizeSbp(
        savePaymentMethod: Bool,
        returnUrl: String?
    ) {
        let confirmation = Confirmation(
            type: .mobileApplication,
            returnUrl: returnUrl
        )
        self.paymentService.tokenizeSbp(
            clientApplicationKey: self.clientApplicationKey,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            amount: self.amount,
            tmxSessionId: Self.Constants.sbpProfiledSessionId,
            customerId: self.customerId
        ) { [weak self] result in
            switch result {
            case .success(let data):
                self?.output?.didTokenize(data)
            case .failure(let error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                self?.output?.didFailTokenize(mappedError)
            }
        }
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authService.analyticsAuthType()
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func fetchConfirmationDetails(
        clientApplicationKey: String,
        confirmationUrl: String
    ) -> Promise<Error, (String, ConfirmationData)> {
        paymentService.fetchConfirmationDetails(
            clientApplicationKey: clientApplicationKey,
            confirmationData: confirmationUrl
        )
    }

    func fetchSbpPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment> {
        paymentService.fetchPayment(clientApplicationKey: clientApplicationKey, paymentId: paymentId)
    }
}

// MARK: - Constants

private extension SbpInteractor {
    enum Constants {
        static let sbpProfiledSessionId = "profilingSessionId"
    }
}
