final class SberbankInteractor {

    // MARK: - VIPER

    weak var output: SberbankInteractorOutput?

    // MARK: - Init

    private let authService: AuthorizationService
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let customerId: String?

    init(
        authService: AuthorizationService,
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        customerId: String?
    ) {
        self.authService = authService
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.customerId = customerId
    }
}

// MARK: - SberbankInteractorInput

extension SberbankInteractor: SberbankInteractorInput {
    func tokenizeSberbank(phoneNumber: String, savePaymentMethod: Bool) {
        let confirmation = Confirmation(
            type: .external,
            returnUrl: nil
        )
        self.paymentService.tokenizeSberbank(
            clientApplicationKey: self.clientApplicationKey,
            phoneNumber: phoneNumber,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            amount: self.amount,
            tmxSessionId: Self.Constants.sberProfiledSessionId,
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
}

// MARK: - Constants

private extension SberbankInteractor {
    enum Constants {
        static let sberProfiledSessionId = "profilingSessionId"
    }
}
