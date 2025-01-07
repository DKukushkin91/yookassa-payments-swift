final class BankCardRepeatInteractor {

    // MARK: - VIPER

    weak var output: BankCardRepeatInteractorOutput?

    // MARK: - Init data

    private let authService: AuthorizationService
    private let analyticsService: AnalyticsTracking
    private let paymentService: PaymentService
    private let sessionProfiler: SessionProfiler
    private let amountNumberFormatter: AmountNumberFormatter

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount

    // MARK: - Init

    init(
        authService: AuthorizationService,
        analyticsService: AnalyticsTracking,
        paymentService: PaymentService,
        sessionProfiler: SessionProfiler,
        amountNumberFormatter: AmountNumberFormatter,
        clientApplicationKey: String,
        gatewayId: String?,
        amount: Amount
    ) {
        self.authService = authService
        self.analyticsService = analyticsService
        self.paymentService = paymentService
        self.sessionProfiler = sessionProfiler
        self.amountNumberFormatter = amountNumberFormatter

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
    }
}

// MARK: - BankCardRepeatInteractorInput

extension BankCardRepeatInteractor: BankCardRepeatInteractorInput {
    func fetchPaymentMethod(
        paymentMethodId: String
    ) {
        paymentService.fetchPaymentMethod(
            clientApplicationKey: clientApplicationKey,
            paymentMethodId: paymentMethodId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchPaymentMethod(data)
            case let .failure(error):
                output.didFailFetchPaymentMethod(error)
            }
        }
    }

    func tokenize(
        amount: MonetaryAmount,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String
    ) {
        sessionProfiler.profileApp(eventType: .payment)
            .right { [weak self] profiledSessionId in
                guard let self else { return }
                self.paymentService.tokenizeRepeatBankCard(
                    clientApplicationKey: self.clientApplicationKey,
                    amount: amount,
                    tmxSessionId: profiledSessionId,
                    confirmation: confirmation,
                    savePaymentMethod: savePaymentMethod,
                    paymentMethodId: paymentMethodId,
                    csc: csc
                ) { result in
                    switch result {
                    case let .success(data):
                        self.output?.didTokenize(data)
                    case let .failure(error):
                        let mappedError = ErrorMapper.mapPaymentError(error)
                        self.output?.didFailTokenize(mappedError)
                    }
                }
            }
            .left { [weak self] error in
                let mappedError = ErrorMapper.mapPaymentError(error)
                self?.output?.didFailTokenize(mappedError)
            }
    }

    func fetchPaymentMethods() {
        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: nil,
            gatewayId: gatewayId,
            amount: amountNumberFormatter.string(from: amount.value),
            currency: amount.currency.rawValue,
            getSavePaymentMethod: false,
            customerId: nil
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchPaymentMethods(
                    data.options,
                    shopProperties: data.properties
                )
            case let .failure(error):
                output.didFetchPaymentMethods(error)
            }
        }
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authService.analyticsAuthType()
    }
}
