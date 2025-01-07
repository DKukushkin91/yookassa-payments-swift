import SPaySdk
import UIKit

final class SberpayPresenter {

    // MARK: - VIPER

    weak var moduleOutput: SberpayModuleOutput?
    weak var view: SberpayViewInput?
    var interactor: SberpayInteractorInput!
    var router: SberpayRouterInput!

    // MARK: - Init

    private let shopName: String
    private let shopId: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: NSAttributedString
    private let isBackBarButtonHidden: Bool
    private let isSafeDeal: Bool
    private let clientSavePaymentMethod: SavePaymentMethod

    private var recurrencySectionSwitchValue: Bool?
    private let isSavePaymentMethodAllowed: Bool
    private let config: Config

    private var clientApplicationKey: String?
    private let applicationScheme: String?

    init(
        shopName: String,
        shopId: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: NSAttributedString,
        isBackBarButtonHidden: Bool,
        isSafeDeal: Bool,
        clientSavePaymentMethod: SavePaymentMethod,
        isSavePaymentMethodAllowed: Bool,
        config: Config,
        applicationScheme: String?
    ) {
        self.shopName = shopName
        self.shopId = shopId
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.isSafeDeal = isSafeDeal
        self.clientSavePaymentMethod = clientSavePaymentMethod
        self.isSavePaymentMethodAllowed = isSavePaymentMethodAllowed
        self.config = config
        self.applicationScheme = applicationScheme
    }
}

// MARK: - SberpayViewOutput

extension SberpayPresenter: SberpayViewOutput {
    func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String?
        if let feeViewModel = feeViewModel {
            feeValue = "\(CommonLocalized.Contract.fee) " + makePrice(feeViewModel)
        }

        var section: PaymentRecurrencyAndDataSavingView?
        if isSavePaymentMethodAllowed {
            switch clientSavePaymentMethod {
            case .userSelects:
                section = PaymentRecurrencyAndDataSavingViewFactory.makeView(
                    mode: .allowRecurring(.sberpay),
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
                recurrencySectionSwitchValue = section?.switchValue
            case .on:
                section = PaymentRecurrencyAndDataSavingViewFactory.makeView(
                    mode: .requiredRecurring(.sberpay),
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
                recurrencySectionSwitchValue = true
            case .off:
                section = nil
            }
        }

        let viewModel = SberpayViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfService,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            recurrencyAndDataSavingSection: section,
            paymentOptionTitle: config.paymentMethods.first { $0.kind == .sberbank }?.title
        )
        view.setupViewModel(viewModel)

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.track(event:
                .screenPaymentContract(
                    scheme: .sberpay,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
        }
    }

    func didTapActionButton() {
        guard let view = view else { return }
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard
                let self = self,
                let interactor = self.interactor,
                let returnUrl = self.makeSPayRedirectUri()
            else { return }

            interactor.tokenizeSberpay(
                savePaymentMethod: self.recurrencySectionSwitchValue ?? false,
                returnUrl: returnUrl
            )
        }
    }

    func didTapTermsOfService(_ url: URL) {
        router.showBrowser(url)
    }

    func didTapSafeDealInfo(_ url: URL) {
        router.showAutopayInfoDetails(
            title: HTMLUtils.htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnSberpayTitle),
            body: HTMLUtils.htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnSberpayText)
        )
    }
}

// MARK: - SberpayInteractorOutput

extension SberpayPresenter: SberpayInteractorOutput {
    func didTokenize(_ data: Tokens) {
        interactor.track(event:
            .actionTokenize(
                scheme: .sberpay,
                currentAuthType: interactor.analyticsAuthType()
            )
        )
        moduleOutput?.sberpayModule(self, didTokenize: data, paymentMethodType: .sberbank)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
        }
    }

    func didFailTokenize(_ error: Error) {
        interactor.track(
            event: .screenErrorContract(scheme: .sberpay, currentAuthType: interactor.analyticsAuthType())
        )

        let message = SberpayPresenter.makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SberpayPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard
                let self = self,
                let interactor = self.interactor,
                let returnUrl = self.makeSPayRedirectUri()
            else { return }

            interactor.track(
                event: .actionTryTokenize(scheme: .sberpay, currentAuthType: interactor.analyticsAuthType())
            )
            interactor.tokenizeSberpay(
                savePaymentMethod: self.recurrencySectionSwitchValue ?? false,
                returnUrl: returnUrl
            )
        }
    }
}

// MARK: - PaymentRecurrencyAndDataSavingViewOutput

extension SberpayPresenter: PaymentRecurrencyAndDataSavingViewOutput {

    func didTapInfoUrl(url: URL) {
        router.showBrowser(url)
    }

    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyMode) {
        recurrencySectionSwitchValue = newValue
    }

    func didTapInfoLink(mode: PaymentRecurrencyMode) {
        switch mode {
        case .allowRecurring, .requiredRecurring:
            router.showAutopayInfoDetails(
                title: HTMLUtils.htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnSberpayTitle),
                body: HTMLUtils.htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnSberpayText)
            )
        default:
        break
        }
    }
}

// MARK: - SberpayModuleInput

extension SberpayPresenter: SberpayModuleInput {
    func hideActivity() {}

    func confirmPayment(clientApplicationKey: String, confirmationUrl: String) {
        self.clientApplicationKey = clientApplicationKey

        DispatchQueue.main.async { [weak self, clientApplicationKey, confirmationUrl] in
            guard let self = self, let view = self.view else { return }
            view.showActivity()
            view.hidePlaceholder()

            dispatchPromise { [weak self] in
                self?.interactor.fetchConfirmationDetails(
                    clientApplicationKey: clientApplicationKey,
                    confirmationUrl: confirmationUrl
                ) ?? .canceling
            }
            .right { [weak self] in
                if case let .sberbank(merchantLogin: merchantLogin, orderId: orderId, orderNumber: orderNumber, apiKey: apiKey) = $0.1 {
                    self?.makePaymentOrder(
                        merchantLogin: merchantLogin,
                        orderId: orderId,
                        orderNumber: orderNumber,
                        apiKey: apiKey)
                }
            }
            .left { [weak self] error in
                guard let self else { return }
                self.view?.showPlaceholder(with: SberpayPresenter.makeMessage(error))
                self.moduleOutput?.didFinish(self, with: error)
            }
            .always { [weak self] _ in
                self?.view?.hideActivity()
            }
        }
    }

    func makePaymentOrder(
        merchantLogin: String,
        orderId: String,
        orderNumber: String,
        apiKey: String
    ) {
        guard
            let viewController = view as? UIViewController,
            let redirectUri = makeSPayRedirectUri()
        else { return }

        let req = SBankInvoicePaymentRequest(
            merchantLogin: merchantLogin,
            bankInvoiceId: orderId,
            orderNumber: orderNumber,
            redirectUri: redirectUri,
            apiKey: apiKey
        )

        SPay.payWithBankInvoiceId(
            with: viewController,
            paymentRequest: req
        ) { [weak self] _, _,_  in
            guard let self else { return }
            self.moduleOutput?.sberpayModule(self, didFinishConfirmation: .sberbank)
            self.interactor.track(event: .actionSberPayConfirmation(success: true))
        }
    }
}

// MARK: - Private helpers

private extension SberpayPresenter {

    func makeSPayRedirectUri() -> String? {
        guard let applicationScheme = applicationScheme else {
            assertionFailure("Application scheme should be")
            return nil
        }
        return applicationScheme + DeepLinkFactory.sberSdkHost
    }

    func makePrice(
        _ priceViewModel: PriceViewModel
    ) -> String {
        priceViewModel.integerPart
            + priceViewModel.decimalSeparator
            + priceViewModel.fractionalPart
            + priceViewModel.currency
    }

    static func makeMessage(
        _ error: Error
    ) -> String {
        let message: String

        switch error {
        case let error as PresentableError:
            message = error.message
        default:
            message = CommonLocalized.Error.unknown
        }

        return message
    }
}
