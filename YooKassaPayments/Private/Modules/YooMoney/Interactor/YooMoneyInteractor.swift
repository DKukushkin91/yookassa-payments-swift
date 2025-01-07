import YooKassaPaymentsApi

final class YooMoneyInteractor {

    // MARK: - VIPER

    weak var output: YooMoneyInteractorOutput?

    // MARK: - Init data

    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsTracking
    private let imageDownloadService: ImageDownloadService
    private let walletPaymentsMediator: WalletPaymentsMediator

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsTracking,
        imageDownloadService: ImageDownloadService,
        walletPaymentsMediator: WalletPaymentsMediator
    ) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.imageDownloadService = imageDownloadService
        self.walletPaymentsMediator = walletPaymentsMediator
    }
}

// MARK: - YooMoneyInteractorInput

extension YooMoneyInteractor: YooMoneyInteractorInput {
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
            moneySource: .wallet
        )
        .right { [weak self] data in
            self?.output?.didTokenizeData(data)
        }
        .left { [weak self] error in
            self?.output?.failTokenizeData(error)
        }
    }

    func loadAvatar() {
        guard let avatarURL = authorizationService.getWalletAvatarURL(),
              let url = URL(string: avatarURL) else {
            return
        }

        imageDownloadService.fetchImage(url: url) { [weak self] result in
            guard let output = self?.output else { return }

            switch result {
            case let .success(avatar):
                output.didLoadAvatar(avatar)
            case let .failure(error):
                output.didFailLoadAvatar(error)
            }
        }
    }

    func hasReusableWalletToken() -> Bool {
        return authorizationService.hasReusableWalletToken()
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authorizationService.analyticsAuthType()
    }

    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }

    func logout() {
        authorizationService.logout()
    }
}
