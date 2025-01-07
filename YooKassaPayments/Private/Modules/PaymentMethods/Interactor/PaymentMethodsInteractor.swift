@_implementationOnly import MoneyAuth
import YooKassaPaymentsApi

class PaymentMethodsInteractor {

    // MARK: - VIPER

    weak var output: PaymentMethodsInteractorOutput?

    // MARK: - Init data

    private let paymentService: PaymentService
    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsTracking
    private let accountService: AccountService
    private let sessionProfiler: SessionProfiler
    private let amountNumberFormatter: AmountNumberFormatter
    private let appDataTransferMediator: AppDataTransferMediator
    private let configMediator: ConfigMediator

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let getSavePaymentMethod: Bool?
    private let customerId: String?

    // MARK: - Init

    init(
        paymentService: PaymentService,
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsTracking,
        accountService: AccountService,
        sessionProfiler: SessionProfiler,
        amountNumberFormatter: AmountNumberFormatter,
        appDataTransferMediator: AppDataTransferMediator,
        configMediator: ConfigMediator,
        clientApplicationKey: String,
        gatewayId: String?,
        amount: Amount,
        getSavePaymentMethod: Bool?,
        customerId: String?
    ) {
        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.accountService = accountService
        self.sessionProfiler = sessionProfiler
        self.amountNumberFormatter = amountNumberFormatter
        self.appDataTransferMediator = appDataTransferMediator
        self.configMediator = configMediator

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
        self.getSavePaymentMethod = getSavePaymentMethod
        self.customerId = customerId
    }
}

extension PaymentMethodsInteractor: PaymentMethodsInteractorInput {

    func unbindCard(id: String) {
        paymentService.unbind(authToken: clientApplicationKey, id: id) { [weak self] result in
            guard let output = self?.output else { return }

            switch result {
            case .success:
                output.didUnbindCard(id: id)
            case .failure(let error):
                output.didFailUnbindCard(
                    id: id,
                    error: ErrorMapper.mapPaymentError(error)
                )
            }
        }
    }

    func fetchShop() {
        let authorizationToken = self.authorizationService.getMoneyCenterAuthToken()

        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: authorizationToken,
            gatewayId: gatewayId,
            amount: amountNumberFormatter.string(from: amount.value),
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod,
            customerId: customerId
        ) { [weak self] result in
            guard let output = self?.output else { return }

            switch result {
            case let .success(data):
                output.didFetchShop(data)
            case let .failure(error):
                output.didFailFetchShop(error)
            }
        }
    }

    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String
    ) {
        authorizationService.setMoneyCenterAuthToken(moneyCenterAuthToken)

        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: moneyCenterAuthToken,
            gatewayId: gatewayId,
            amount: amountNumberFormatter.string(from: amount.value),
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod,
            customerId: customerId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchYooMoneyPaymentMethods(
                    data.options.filter { $0.paymentMethodType == .yooMoney },
                    shopProperties: data.properties
                )
            case let .failure(error):
                output.didFetchYooMoneyPaymentMethods(error)
            }
        }
    }

    func fetchAccount(
        oauthToken: String
    ) {
        accountService.fetchAccount(
            oauthToken: oauthToken
        ) { [weak self] in
            guard let output = self?.output else { return }
            $0.map {
                output.didFetchAccount($0)
            }.mapLeft {
                output.didFailFetchAccount($0)
            }
        }
    }

    func decryptCryptogram(
        _ cryptogram: String
    ) {
        appDataTransferMediator.decryptData(cryptogram) { [weak self] in
            guard let output = self?.output else { return }
            $0.map {
                output.didDecryptCryptogram($0)
            }.mapLeft {
                output.didFailDecryptCryptogram($0)
            }
        }
    }

    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }

    func setAccount(_ account: UserAccount) {
        authorizationService.setWalletDisplayName(account.displayName.title)
        authorizationService.setWalletPhoneTitle(account.phone.title)
        authorizationService.setWalletAvatarURL(account.avatar.url?.absoluteString)
        authorizationService.setAccountUid(account.uid)
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authorizationService.analyticsAuthType()
    }
}

extension PaymentMethodsInteractor {

    func tokenizeInstrument(
        instrument: PaymentInstrumentBankCard,
        savePaymentMethod: Bool,
        returnUrl: String?,
        amount: MonetaryAmount
    ) {
        sessionProfiler.profileApp()
            .right { [weak self] profiledSessionId in
                guard let self else { return }
                self.paymentService.tokenizeCardInstrument(
                    clientApplicationKey: self.clientApplicationKey,
                    amount: amount,
                    tmxSessionId: profiledSessionId,
                    confirmation: Confirmation(type: .redirect, returnUrl: returnUrl),
                    savePaymentMethod: savePaymentMethod,
                    instrumentId: instrument.paymentInstrumentId,
                    csc: nil
                ) { tokenizeResult in
                    switch tokenizeResult {
                    case .success(let tokens):
                        self.output?.didTokenizeInstrument(instrument: instrument, tokens: tokens)
                    case .failure(let error):
                        let mappedError = ErrorMapper.mapPaymentError(error)
                        self.output?.didFailTokenizeInstrument(error: mappedError)
                    }
                }
            }
            .left { [weak self] error in
                let mappedError = ErrorMapper.mapPaymentError(error)
                self?.output?.didFailTokenizeInstrument(error: mappedError)
            }
    }
}
