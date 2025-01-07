final class BankCardInteractor {

    // MARK: - VIPER

    weak var output: BankCardInteractorOutput?

    // MARK: - Initialization

    private let authService: AuthorizationService
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let sessionProfiler: SessionProfiler
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let returnUrl: String
    private let customerId: String?

    init(
        authService: AuthorizationService,
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        sessionProfiler: SessionProfiler,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        returnUrl: String,
        customerId: String?
    ) {
        self.authService = authService
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.sessionProfiler = sessionProfiler
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.returnUrl = returnUrl
        self.customerId = customerId
    }
}

// MARK: - BankCardInteractorInput

extension BankCardInteractor: BankCardInteractorInput {
    func tokenizeInstrument(id: String, csc: String?, savePaymentMethod: Bool) {
        sessionProfiler.profileApp(eventType: .payment)
            .right { [weak self] profiledSessionId in
                guard let self else { return }
                self.paymentService.tokenizeCardInstrument(
                    clientApplicationKey: self.clientApplicationKey,
                    amount: self.amount,
                    tmxSessionId: profiledSessionId,
                    confirmation: self.makeConfirmation(returnUrl: self.returnUrl),
                    savePaymentMethod: savePaymentMethod,
                    instrumentId: id,
                    csc: csc
                ) { tokenizeResult in
                    switch tokenizeResult {
                    case .success(let tokens):
                        self.output?.didTokenize(tokens)
                    case .failure(let error):
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

    func tokenizeBankCard(
        cardData: CardData,
        savePaymentMethod: Bool,
        savePaymentInstrument: Bool?
    ) {
        sessionProfiler.profileApp(eventType: .payment)
            .right { [weak self] profiledSessionId in
                guard
                    let self = self,
                    let bankCard = self.makeBankCard(cardData)
                else { return }
                let confirmation = self.makeConfirmation(
                    returnUrl: self.returnUrl
                )
                self.paymentService.tokenizeBankCard(
                    clientApplicationKey: self.clientApplicationKey,
                    bankCard: bankCard,
                    confirmation: confirmation,
                    savePaymentMethod: savePaymentMethod,
                    amount: self.amount,
                    tmxSessionId: profiledSessionId,
                    customerId: self.customerId,
                    savePaymentInstrument: savePaymentInstrument
                ) { result in
                    switch result {
                    case .success(let data):
                        self.output?.didTokenize(data)
                    case .failure(let error):
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

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authService.analyticsAuthType()
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }
}

// MARK: - Private helpers

private extension BankCardInteractor {
    func makeBankCard(_ cardData: CardData) -> BankCard? {
        guard let number = cardData.pan,
              let expiryDateComponents = cardData.expiryDate,
              let expiryYear = expiryDateComponents.year.flatMap(String.init),
              let expiryMonth = expiryDateComponents.month.flatMap(String.init),
              let csc = cardData.csc else {
            return nil
        }
        let bankCard = BankCard(
            number: number,
            expiryYear: expiryYear,
            expiryMonth: makeCorrectExpiryMonth(expiryMonth),
            csc: csc,
            cardholder: nil
        )
        return bankCard
    }

    func makeCorrectExpiryMonth(_ month: String) -> String {
        month.count > 1 ? month : "0" + month
    }

    func makeConfirmation(returnUrl: String) -> Confirmation {
        Confirmation(type: .redirect, returnUrl: returnUrl)
    }
}
