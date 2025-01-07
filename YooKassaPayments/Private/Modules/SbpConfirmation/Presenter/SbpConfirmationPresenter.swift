import FunctionalSwift

final class SbpConfirmationPresenter {

    // MARK: - VIPER

    var interactor: SbpConfirmationInteractorInput!
    var router: SbpConfirmationRouterInput!
    weak var moduleOutput: SbpConfirmationModuleOutput?
	weak var view: SbpConfirmationViewInput?

    private var viewModelFactory: SbpBanksViewModelFactory
    private var appChecker: AppChecker

    private let confirmationUrl: String
    private var bankItems: [SbpBank] = []
    private var isWaitingForBankRedirect = false
    private let paymentId: String
    private let clientApplicationKey: String

    // MARK: - Init data

    init(
        appChecker: AppChecker,
        viewModelFactory: SbpBanksViewModelFactory,
        confirmationUrl: String,
        paymentId: String,
        clientApplicationKey: String
    ) {
        self.appChecker = appChecker
        self.viewModelFactory = viewModelFactory
        self.confirmationUrl = confirmationUrl
        self.paymentId = paymentId
        self.clientApplicationKey = clientApplicationKey
        YKSdk.shared.sbpConfirmationModuleInput = self
    }
}

// MARK: - SbpConfirmationViewOutput

extension SbpConfirmationPresenter: SbpConfirmationViewOutput {
    func setupView() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        fetchData()
    }

    func didSelectViewModel(_ model: SbpBankCellViewModel) {
        trackDidSelectBankAction(model)

        switch model {
        case .openBank(let bank), .openPriorityBank(let bank):
            isWaitingForBankRedirect = true
            router.openBankApp(url: bank.deeplink) { [weak self] isSuccess in
                if !isSuccess {
                    self?.view?.showMissedBankPlaceholder()
                }
            }
        case .openBanksList:
            let inputData = SbpBankSelectionInputData(banks: bankItems)
            router.openMoreBanks(
                inputData: inputData,
                moduleOutput: self
            )
        }
    }

    private func trackDidSelectBankAction(_ action: SbpBankCellViewModel) {
        DispatchQueue.global().async { [weak self] in
            switch action {
            case .openBank:
                self?.interactor.track(event: AnalyticsEvent.actionSelectOrdinaryBank)
            case .openPriorityBank:
                self?.interactor.track(event: AnalyticsEvent.actionSelectPriorityBank)
            case .openBanksList:
                self?.interactor.track(event: AnalyticsEvent.actionShowFullList)
            }
        }
    }

    @objc
    private func applicationDidBecomeActive() {
        fetchPaymentStatus()
    }
}

// MARK: - SbpModuleInput

extension SbpConfirmationPresenter: SbpConfirmationModuleInput {
    func checkSbpPaymentStatus() {
        fetchPaymentStatus()
    }
}

// MARK: - SbpBankSelectionModuleOutput

extension SbpConfirmationPresenter: SbpBankSelectionModuleOutput {

    func sbpBankSelectionModule(
        _ sbpBankSelectionModule: SbpBankSelectionModuleInput,
        didSelectItemAt index: Int
    ) {
        trackDidSelectBankAction(.openBank(bankItems[index]))

        isWaitingForBankRedirect = true
        router.openBankApp(url: bankItems[index].deeplink) { isSuccess in
            if !isSuccess {
                sbpBankSelectionModule.handleMissedBankError()
            }
        }
    }
}

private extension SbpConfirmationPresenter {

    func fetchPaymentStatus() {
        guard isWaitingForBankRedirect else { return }
        isWaitingForBankRedirect = false

        view?.showActivity()
        view?.hidePlaceholder()

        dispatchPromise { [weak self, clientApplicationKey, paymentId] in
            self?.interactor.fetchSbpPayment(
                clientApplicationKey: clientApplicationKey,
                paymentId: paymentId
            ) ?? .canceling
        }
        .right { [weak self] payment in
            guard let self = self else { return }

            if case .finished = payment.sbpUserPaymentProcessStatus {
                self.moduleOutput?.sbpConfirmationModule(self, didFinishWithStatus: payment.sbpPaymentStatus)
                self.interactor.track(
                    event: AnalyticsEvent.actionSBPConfirmation(success: true)
                )
            }
        }
        .left { [weak self] error in
            guard let self = self else { return }

            self.interactor.track(
                event: AnalyticsEvent.actionSBPConfirmation(success: false)
            )
            self.moduleOutput?.sbpConfirmationModule(self, didFinishWithError: error)
            self.handleFailedResponse(error)
        }
        .always { [weak self] _ in
            self?.view?.hideActivity()
        }
    }

    func handleFailedResponse(_ error: Error) {
        let message = makeErrorMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.showPlaceholder(message: message)
        }
    }

    func fetchData() {
        view?.showActivity()
        view?.hidePlaceholder()

        dispatchPromise { [weak self, confirmationUrl] in
            self?.interactor.fetchAllBanks(confirmationUrl: confirmationUrl) ?? .canceling
        }
        .right { [weak self] banks in
            guard let self else { return }

            self.bankItems = banks
            self.setBanks(banks)
        }
        .left { [weak self] error in
            guard let self = self, let view = self.view else { return }
            self.moduleOutput?.sbpConfirmationModule(self, didFinishWithError: error)
            view.showPlaceholder(message: self.makeErrorMessage(error))
        }
        .always { [weak self] _ in
            self?.view?.hideActivity()
        }
    }

    private func setBanks(_ banks: [SbpBank]) {
        let priorityBanksIds = interactor.fetchPrioriryBanks()

        let priorityBanks = banks.filter { bank in
            if let id = bank.memberId, priorityBanksIds.contains(id) {
                return appChecker.checkApplication(withScheme: bank.deeplink) == .installed
            }

            return false
        }

        var viewModels: [SbpBankCellViewModel] = []
        if !priorityBanks.isEmpty {
            view?.hideSearch()
            viewModels = viewModelFactory.makeViewModels(.priority(priorityBanks))
        } else {
            view?.showSearch()
            viewModels = viewModelFactory.makeViewModels(.all(banks))
        }

        view?.setViewModels(viewModels)

    }

    private func makeErrorMessage(_ error: Error) -> String {
        var errorMessage: String
        switch error {
        case let error as PresentableError:
            errorMessage = error.message
        default:
            errorMessage = CommonLocalized.Error.unknown
        }
        return errorMessage
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SbpConfirmationPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        fetchData()
    }
}

// MARK: - Localized

private extension SbpConfirmationPresenter {
    enum Localized {
    // swiftlint:disable:next superfluous_disable_command
    // swiftlint:disable line_length
    // swiftlint:enable line_length
    }
}

// MARK: - Constants

private extension SbpConfirmationPresenter {
    enum Constants { }
}
