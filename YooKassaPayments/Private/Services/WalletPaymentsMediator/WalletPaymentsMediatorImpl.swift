import FunctionalSwift

final class WalletPaymentsMediatorImpl {

    // MARK: - Init data

    private let authorizationService: AuthorizationService
    private let paymentService: PaymentService
    private let sessionProfiler: SessionProfiler
    private let storage: KeyValueStoring

    private let clientApplicationKey: String
    private let customerId: String?

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        paymentService: PaymentService,
        sessionProfiler: SessionProfiler,
        storage: KeyValueStoring,
        clientApplicationKey: String,
        customerId: String?
    ) {
        self.authorizationService = authorizationService
        self.paymentService = paymentService
        self.sessionProfiler = sessionProfiler
        self.storage = storage

        self.clientApplicationKey = clientApplicationKey
        self.customerId = customerId
    }
}

// MARK: WalletPaymentsMediator

extension WalletPaymentsMediatorImpl: WalletPaymentsMediator {

    func tokenize(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        moneySource: WalletMoneySource
    ) -> Promise<Error, Tokens> {
        if let sessionId: String = try? storage.readValue(for: KeyValueStoringKeys.profiledSessionId) {
            return tokenizeWithSessionId(
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                paymentMethodType: paymentMethodType,
                amount: amount,
                profiledSessionId: sessionId,
                moneySource: moneySource
            )
        } else {
            return sessionProfiler.profileApp(eventType: .login)
                .flatMap { [weak self] sessionId in
                    guard let self else { return .canceling }
                    return self.tokenizeWithSessionId(
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        paymentMethodType: paymentMethodType,
                        amount: amount,
                        profiledSessionId: sessionId,
                        moneySource: moneySource
                    )
                }
                .flatMapLeft { error in
                    let mappedError = ErrorMapper.mapPaymentError(error)
                    return .left(mappedError)
                }
        }
    }

    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool
    ) -> Promise<Error, WalletLoginResponse> {
        return sessionProfiler.profileApp(eventType: .login)
            .flatMap { [weak self] sessionId in
                guard let self else { return .canceling }
                try? self.storage.write(
                    value: sessionId,
                    for: KeyValueStoringKeys.profiledSessionId
                )
                return self.loginInWalletWithProfiledSessionId(
                    amount: amount,
                    reusableToken: reusableToken,
                    profiledSessionId: sessionId
                )
            }
            .flatMapLeft { error in
                let mappedError = ErrorMapper.mapPaymentError(error)
                return .left(mappedError)
            }
    }
}

private extension WalletPaymentsMediatorImpl {

    func loginInWalletWithProfiledSessionId(
        amount: MonetaryAmount,
        reusableToken: Bool,
        profiledSessionId: String?
    ) -> Promise<Error, WalletLoginResponse> {
        let promise = Promise<Error, WalletLoginResponse>()

        authorizationService.loginInWallet(
            merchantClientAuthorization: clientApplicationKey,
            amount: amount,
            reusableToken: reusableToken,
            tmxSessionId: profiledSessionId
        ) { result in
            switch result {
            case let .success(response):
                promise.resolveRight(response)

            case let .failure(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                promise.resolveLeft(mappedError)
            }
        }

        return promise
    }

    func tokenizeWithSessionId(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        profiledSessionId: String,
        moneySource: WalletMoneySource
    ) -> Promise<Error, Tokens> {
        switch moneySource {
        case .wallet:
            return tokenizeWalletWithSessionId(
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                paymentMethodType: paymentMethodType,
                amount: amount,
                profiledSessionId: profiledSessionId
            )
        case .linkedCard(let id, let csc):
            return tokenizeLinkedCardWithSessionId(
                id: id,
                csc: csc,
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                paymentMethodType: paymentMethodType,
                amount: amount,
                profiledSessionId: profiledSessionId
            )
        }
    }

    func tokenizeLinkedCardWithSessionId(
        id: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        profiledSessionId: String
    ) -> Promise<Error, Tokens> {
        let promise = Promise<Error, Tokens>()

        guard let walletToken = authorizationService.getWalletToken() else {
            assertionFailure("You must be authorized in wallet")
            return .canceling
        }

        paymentService.tokenizeLinkedBankCard(
            clientApplicationKey: clientApplicationKey,
            walletAuthorization: walletToken,
            cardId: id,
            csc: csc,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodType: paymentMethodType,
            amount: amount,
            tmxSessionId: profiledSessionId,
            customerId: customerId) { [weak self] result in
                guard let self else { return }

                switch result {
                case let .success(data):
                    promise.resolveRight(data)
                case let .failure(error):
                    let mappedError = ErrorMapper.mapPaymentError(error)
                    promise.resolveLeft(mappedError)
                }

                self.revokeProfiledSessionId()
        }

        return promise
    }

    func tokenizeWalletWithSessionId(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        profiledSessionId: String
    ) -> Promise<Error, Tokens> {
        let promise = Promise<Error, Tokens>()

        guard let walletToken = authorizationService.getWalletToken() else {
            assertionFailure("You must be authorized in wallet")
            return .canceling
        }

        paymentService.tokenizeWallet(
            clientApplicationKey: clientApplicationKey,
            walletAuthorization: walletToken,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodType: paymentMethodType,
            amount: amount,
            tmxSessionId: profiledSessionId,
            customerId: customerId) { [weak self] result in
                guard let self else { return }

                switch result {
                case let .success(data):
                    promise.resolveRight(data)
                case let .failure(error):
                    let mappedError = ErrorMapper.mapPaymentError(error)
                    promise.resolveLeft(mappedError)
                }

                self.revokeProfiledSessionId()
        }

        return promise
    }

    func revokeProfiledSessionId() {
        let empty: String? = nil
        try? storage.write(
            value: empty,
            for: KeyValueStoringKeys.profiledSessionId
        )
    }
}
