final class LinkedCardInteractor {

    // MARK: - VIPER

    weak var output: LinkedCardInteractorOutput?

    // MARK: - Init data

    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsTracking
    private let walletPaymentsMediator: WalletPaymentsMediator

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsTracking,
        walletPaymentsMediator: WalletPaymentsMediator,
        clientApplicationKey: String,
        customerId: String?
    ) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.walletPaymentsMediator = walletPaymentsMediator
    }
}

// MARK: - LinkedCardInteractorInput

extension LinkedCardInteractor: LinkedCardInteractorInput {
    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authorizationService.analyticsAuthType()
    }

    func hasReusableWalletToken() -> Bool {
        return authorizationService.hasReusableWalletToken()
    }

    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool
    ) {
        walletPaymentsMediator.loginInWallet(
            amount: amount,
            reusableToken: reusableToken
        )
        .right { [weak self] data in
            self?.output?.didLoginInWallet(data)
        }
        .left { [weak self] error in
            self?.output?.failLoginInWallet(error)
        }
    }

    func tokenize(
        id: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount
    ) {
        walletPaymentsMediator.tokenize(
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodType: paymentMethodType,
            amount: amount,
            moneySource: .linkedCard(id: id, csc: csc)
        )
        .right { [weak self] data in
            self?.output?.didTokenizeData(data)
        }
        .left { [weak self] error in
            self?.output?.failTokenizeData(error)
        }
    }
}
