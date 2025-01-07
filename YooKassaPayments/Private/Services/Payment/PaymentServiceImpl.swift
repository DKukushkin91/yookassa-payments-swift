import FunctionalSwift
import YooKassaPaymentsApi
import YooMoneyCoreApi

final class PaymentServiceImpl {

    // MARK: - Init data

    private let session: ApiSession
    private let paymentMethodHandlerService: PaymentMethodHandlerService

    // MARK: - Init

    init(
        session: ApiSession,
        paymentMethodHandlerService: PaymentMethodHandlerService
    ) {
        self.session = session
        self.paymentMethodHandlerService = paymentMethodHandlerService
    }
}

// MARK: - PaymentService

extension PaymentServiceImpl: PaymentService {
    func fetchPaymentOptions(
        clientApplicationKey: String,
        authorizationToken: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?,
        customerId: String?,
        completion: @escaping (Swift.Result<Shop, Error>) -> Void
    ) {
        let apiMethod = PaymentOptions.Method(
            oauthToken: clientApplicationKey,
            authorization: authorizationToken,
            gatewayId: gatewayId,
            amount: amount,
            currency: currency,
            savePaymentMethod: getSavePaymentMethod,
            merchantCustomerId: customerId
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                let items = self.paymentMethodHandlerService.filterPaymentMethods(data.items)
                if items.isEmpty {
                    completion(.failure(PaymentProcessingError.emptyList))
                } else {
                    completion(.success(Shop(options: items, properties: data.shopProperties)))
                }
            }
        }
    }

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String,
        completion: @escaping (Swift.Result<PaymentMethod, Error>) -> Void
    ) {
        let apiMethod = YooKassaPaymentsApi.PaymentMethod.Method(
            oauthToken: clientApplicationKey,
            paymentMethodId: paymentMethodId
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeBankCard(
        clientApplicationKey: String,
        bankCard: BankCard,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        customerId: String?,
        savePaymentInstrument: Bool?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentMethodDataBankCard(bankCard: bankCard.paymentsModel)
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData,
            merchantCustomerId: customerId,
            savePaymentInstrument: savePaymentInstrument
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeWallet(
        clientApplicationKey: String,
        walletAuthorization: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        customerId: String?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentInstrumentDataYooMoneyWallet(
            instrumentType: .wallet,
            walletAuthorization: walletAuthorization,
            paymentMethodType: paymentMethodType.paymentsModel
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData,
            merchantCustomerId: customerId,
            savePaymentInstrument: nil
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeLinkedBankCard(
        clientApplicationKey: String,
        walletAuthorization: String,
        cardId: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        customerId: String?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentInstrumentDataYooMoneyLinkedBankCard(
            instrumentType: .linkedBankCard,
            cardId: cardId,
            csc: csc,
            walletAuthorization: walletAuthorization,
            paymentMethodType: paymentMethodType.paymentsModel
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData,
            merchantCustomerId: customerId,
            savePaymentInstrument: nil
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeSberbank(
        clientApplicationKey: String,
        phoneNumber: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        customerId: String?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentMethodDataSberbank(
            phone: phoneNumber
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData,
            merchantCustomerId: customerId,
            savePaymentInstrument: nil
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeSberpay(
        clientApplicationKey: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        customerId: String?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentMethodDataSberbank(
            phone: nil
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData,
            merchantCustomerId: customerId,
            savePaymentInstrument: nil
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeRepeatBankCard(
        clientApplicationKey: String,
        amount: MonetaryAmount,
        tmxSessionId: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let tokensRequest = TokensRequestPaymentMethodId(
            amount: amount.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodId: paymentMethodId,
            csc: csc
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeCardInstrument(
        clientApplicationKey: String,
        amount: MonetaryAmount,
        tmxSessionId: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        instrumentId: String,
        csc: String?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let request = TokensRequestPaymentInstrumentId(
            amount: .init(amount),
            tmxSessionId: tmxSessionId,
            confirmation: .init(confirmation),
            savePaymentMethod: savePaymentMethod,
            paymentInstrumentId: instrumentId,
            csc: csc
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: request
        )
        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeSbp(
        clientApplicationKey: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        customerId: String?,
        completion: @escaping (Swift.Result<Tokens, Error>) -> Void
    ) {
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: .init(paymentMethodType: .sbp),
            merchantCustomerId: customerId,
            savePaymentInstrument: nil
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
            switch result {
            case let .left(error):
                let mappedError = ErrorMapper.mapPaymentError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func unbind(authToken: String, id: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        session.perform(apiMethod: PaymentInstruments.Method(oauthToken: authToken, paymentInstrumentId: id))
            .responseApi(queue: .global()) { result in
                switch result {
                case .left(let error):
                    completion(.failure(ErrorMapper.mapPaymentError(error)))
                case .right:
                    completion(.success(()))
                }
            }
    }

    func fetchConfirmationDetails(
        clientApplicationKey: String,
        confirmationData: String
    ) -> Promise<Error, (String, ConfirmationData)> {
        let apiMethod = ConfirmationDetails.Method(
            oauthToken: clientApplicationKey,
            confirmationData: confirmationData
        )
        return session.perform(apiMethod: apiMethod)
            .responsePromise()
            .map {
                return ($0.paymentId, ConfirmationData($0.confirmationData))
            }
    }

    func fetchPayment(
        clientApplicationKey: String,
        paymentId: String
    ) -> Promise<Error, SbpPayment> {
        let apiMethod = Payment.Method(
            oauthToken: clientApplicationKey,
            paymentId: paymentId
        )
        return session.perform(apiMethod: apiMethod)
            .responsePromise()
            .map(SbpPayment.init)
    }

    func fetchApiKey(clientApplicationKey: String) -> Promise<Error, String> {
        let apiMethod = ApiKey.Method(oauthToken: clientApplicationKey)
        return session.perform(apiMethod: apiMethod)
            .responsePromise()
            .map {
                $0.key
            }
    }

}
