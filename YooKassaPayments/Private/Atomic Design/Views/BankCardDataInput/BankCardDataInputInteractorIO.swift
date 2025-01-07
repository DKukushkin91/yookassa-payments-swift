protocol BankCardDataInputInteractorInput {
    func validate(cardData: CardData, shouldMoveFocus: Bool)
    func track(event: AnalyticsEvent)
}

protocol BankCardDataInputInteractorOutput: AnyObject {
    func didSuccessValidateCardData(_ cardData: CardData)
    func didFailValidateCardData(errors: [CardService.ValidationError], shouldMoveFocus: Bool)
}
