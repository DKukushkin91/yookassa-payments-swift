final class CardSecPresenter: WebBrowserPresenter {

    // MARK: - VIPER

    var cardSecInteractor: CardSecInteractorInput!
    weak var cardSecModuleOutput: CardSecModuleOutput?

    // MARK: - Business logic properties

    private var shouldCallDidSuccessfullyPassedCardSec = true

    // MARK: - Overridden funcs

    override func setupView() {
        super.setupView()
        trackAnalyticsEvent()
    }

    override func didPressCloseButton() {
        cardSecModuleOutput?.didPressCloseButton(on: self)
        if shouldCallDidSuccessfullyPassedCardSec {
            cardSecInteractor.track(event: .actionClose3dsScreen(success: false))
        }
    }

    override func viewDidDisappear() {
        cardSecModuleOutput?.viewDidDisappear()
    }

    private func trackAnalyticsEvent() {
        cardSecInteractor.track(event: .actionOpen3dsScreen)
    }
}

// MARK: - CardSecInteractorOutput

extension CardSecPresenter: CardSecInteractorOutput {
    func didSuccessfullyPassedCardSec() {
        guard shouldCallDidSuccessfullyPassedCardSec else { return }
        shouldCallDidSuccessfullyPassedCardSec = false
        cardSecInteractor.track(event: .actionClose3dsScreen(success: true))
        cardSecModuleOutput?.didSuccessfullyPassedCardSec(on: self)
    }
}

// MARK: - CardSecModuleInput

extension CardSecPresenter: CardSecModuleInput {}
