final class BankCardDataInputInteractor {

    // MARK: - VIPER

    weak var output: BankCardDataInputInteractorOutput?

    // MARK: - Initialization

    private let cardService: CardService
    private let analyticsService: AnalyticsTracking

    init(
        cardService: CardService,
        analyticsService: AnalyticsTracking
    ) {
        self.cardService = cardService
        self.analyticsService = analyticsService
    }
}

// MARK: - BankCardDataInputInteractorInput

extension BankCardDataInputInteractor: BankCardDataInputInteractorInput {
    func validate(
        cardData: CardData,
        shouldMoveFocus: Bool
    ) {
        guard let errors = cardService.validate(
            cardData: cardData
        ) else {
            output?.didSuccessValidateCardData(cardData)
            return
        }
        output?.didFailValidateCardData(
            errors: errors,
            shouldMoveFocus: shouldMoveFocus
        )
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }
}
